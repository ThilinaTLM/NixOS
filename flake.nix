{
  description = "My NixOS System";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-stable.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }@attrs:
    let
      system = "x86_64-linux";
      userName = "tlm";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      stablePkgs = import nixpkgs-stable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (import ./jetbrains/with-copilot.nix)
        ];
      };
    in {
      nixosConfigurations = {
        "TLM-NixOS" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit stablePkgs unstablePkgs;
          };
          modules = [
            ./hardware.nix
            ./system.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${userName} = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit stablePkgs unstablePkgs;
              };
            }
          ];
        };
      };
    };
}
