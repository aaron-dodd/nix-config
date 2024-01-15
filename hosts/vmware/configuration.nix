# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ lib, ... }:
let
  hostId = "deadbeef";
  hostName = "vmware";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./disks.nix { })
    ../_common/services/sd-bootloader.nix

    ../_common/global
    ../_common/desktop/gnome.nix
    ../_common/services/amnesia.nix
    ../_common/services/dns-security.nix
    ../_common/services/flatpak.nix
    ../_common/services/localisation.nix
    ../_common/services/mosh.nix
    ../_common/services/oci-containers.nix
    ../_common/services/pipewire.nix
    ../_common/services/secrets-service.nix
    ../_common/services/tailscale.nix
    ../_common/users/aaron
  ];

  networking = {
    # Define your hostname and hostid.
    inherit hostId hostName;

    # Disable firewall (this is fine because its a VM)
    firewall.enable = false;

    # Enable networking
    networkmanager.enable = true;
  };

  # Enable guest additions
  virtualisation.vmware.guest.enable = true;

  # Enable amnesia
  nixos.amnesia = {
    enable = true;
    fileSystem = "zfs";
  };

  boot = {
    supportedFilesystems = [ "zfs" ];

    # Enable zfs for virtual machines
    zfs.devNodes = lib.mkDefault "/dev/disk/by-path";
  };

  # Enable secrets
  sops.defaultSopsFile = ../../secrets/hosts/${hostName}/secrets.yaml;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

