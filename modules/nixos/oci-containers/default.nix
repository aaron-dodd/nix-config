{ config, lib, pkgs, ... }:
with lib;
let
  mkPortDef = { host, inner }: "127.0.0.1:${toString host}:${toString inner}";

  mkVolumeDef = container: { name, host, inner }:
    if host != null
    then "${host}:${inner}"
    else "${cfg.volumeBaseDir}/${container.volumeSubDir}/${name}:${inner}";

  shouldPreStart = _name: container: container.pullOnStart;
  mkPreStart = name: container: nameValuePair "${cfg.backend}-${name}" {
    preStart = if container.pullOnStart then "${cfg.backend} pull ${container.image}" else "";
  };

  shouldNetworkService = _name: container: container.network != null;
  mkNetworkService = _name: container:
    let package = if cfg.backend == "docker" then pkgs.docker else pkgs.podman;
    in nameValuePair "${cfg.backend}-net-${container.network}" {
      description = "Manage the ${container.network} network for ${cfg.backend}";
      preStart = "${package}/bin/${cfg.backend} network rm ${container.network} || true";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${package}/bin/${cfg.backend} network create -d bridge ${container.network}";
        ExecStop = "${package}/bin/${cfg.backend} network rm ${container.network}";
        RemainAfterExit = "yes";
      };
    };

  mkPodService = name: pod:
    let
      package = if cfg.backend == "podman" then pkgs.podman else throw "mkPodService only supports podman";
      aliases = map (cn: "${name}-${cn}") (attrNames pod.containers);
      ports = concatLists (catAttrs "ports" (attrValues pod.containers));
    in
    nameValuePair "${cfg.backend}-pod-${name}" {
      description = "Manage the ${name} pod for ${cfg.backend}";
      preStart = "${package}/bin/${cfg.backend} pod rm --force --ignore ${name} || true";
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let args = map (n: "--network-alias=${n}") aliases ++ map (pd: "-p ${mkPortDef pd}") ports;
          in "${package}/bin/${cfg.backend} pod create ${concatStringsSep " " args} ${name}";
        ExecStop = "${package}/bin/${cfg.backend} pod rm ${name}";
        RemainAfterExit = "yes";
      };
    };

  mkContainer = _name: container: with container;
    let
      hasNetwork = container.network != null;
      hasPod = container.pod != null;
    in
    {
      inherit autoStart cmd environment environmentFiles image login;
      dependsOn =
        container.dependsOn ++
        (if hasNetwork then [ "net-${container.network}" ] else [ ]) ++
        (if hasPod then [ "pod-${container.pod}" ] else [ ]);
      extraOptions =
        container.extraOptions ++
        (if hasNetwork then [ "--network=${container.network}" ] else [ ]) ++
        (if hasPod then [ "--pod=${container.pod}" ] else [ ]);
      /* ports are defined at the pod level */
      ports = if hasPod then [ ] else map mkPortDef ports;
      volumes = map (mkVolumeDef container) volumes;
    };

  portOptions = {
    host = mkOption {
      type = types.int;
    };
    inner = mkOption {
      type = types.int;
    };
  };

  volumeOptions = {
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    host = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    inner = mkOption {
      type = types.str;
    };
  };

  containerOptions = {
    autoStart = mkOption {
      type = types.bool;
      default = true;
    };
    cmd = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    dependsOn = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
    environmentFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
    };
    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    image = mkOption {
      type = types.str;
    };
    login = {
      passwordFile = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      registry = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      username = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
    ports = mkOption {
      type = types.listOf (types.submodule {
        options = portOptions;
      });
      default = [ ];
    };
    pullOnStart = mkOption {
      type = types.bool;
      default = true;
    };
    volumes = mkOption {
      type = types.listOf (types.submodule {
        options = volumeOptions;
      });
      default = [ ];
    };
  };

  cfg = config.nixos.oci-containers;

  allContainers =
    let
      mkPodContainer = podName: pod: containerName: container: nameValuePair "${podName}-${containerName}" (
        container //
        {
          network = if cfg.backend == "docker" then podName else null;
          pod = if cfg.backend == "docker" then null else podName;
          inherit (pod) volumeSubDir;
        }
      );
      podContainers = concatMapAttrs (podName: pod: mapAttrs' (mkPodContainer podName pod) pod.containers) cfg.pods;
    in
    attrsets.unionOfDisjoint cfg.containers podContainers;
in
{
  options.nixos.oci-containers = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    backend = mkOption {
      type = types.enum [ "docker" "podman" ];
      default = "podman";
    };
    containers = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options =
          containerOptions //
          {
            pod = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            network = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            volumeSubDir = mkOption {
              type = types.str;
              default = name;
            };
          };
      }));
      default = { };
    };
    pods = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          containers = mkOption {
            type = types.attrsOf (types.submodule {
              options = containerOptions;
            });
            default = { };
          };
          volumeSubDir = mkOption {
            type = types.str;
            default = name;
          };
        };
      }));
      default = { };
    };
    volumeBaseDir = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.${cfg.backend} = {
      enable = true;
      autoPrune.enable = true;
    } // (if cfg.backend == "podman"
    then {
      defaultNetwork.settings.dns_enabled = true;
    }
    else { });

    virtualisation.oci-containers = {
      inherit (cfg) backend;
      containers = mapAttrs mkContainer allContainers;
    };
    systemd.services = mkMerge [
      (mapAttrs' mkPreStart (filterAttrs shouldPreStart allContainers))
      (mapAttrs' mkNetworkService (filterAttrs shouldNetworkService allContainers))
      (if cfg.backend == "podman"
      then mapAttrs' mkPodService cfg.pods
      else { })
    ];
  };
}

