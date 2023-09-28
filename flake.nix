{
  description = "Aaron's NixOS and Home Manager configuration";

  inputs = {
    # Pick a release channel from here
    # https://status.nixos.org
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-23.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-master = {
      url = "github:nixos/nixpkgs";
    };

    # Disk configuration and partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home directory configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Code formatting
    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-formatter-pack
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;

      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./packages nixpkgs.legacyPackages.${system});

      # Custom development environment templates
      # Accessible through 'nix flake init', 'nix flake new' etc
      # You can find many examples here: https://github.com/the-nix-way/dev-templates
      templates = import ./templates;

      # Formatter for your nix files
      # Accessible through 'nix fmt'
      formatter = forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );

      # Custom checker for your nix files
      # Accessible through 'nix flake check'
      checks = forAllSystems (system: {
        nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
          };

          checkFiles = [ ./. ];
        };
      }
      );

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs outputs; };

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;

      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        vmware = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/vmware
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "aaron@vmware" = home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home/aaron/vmware.nix
          ];
          extraSpecialArgs = { inherit inputs outputs; };
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      };
    };
}
