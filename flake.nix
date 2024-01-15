{
  description = "My NixOS System";

  inputs = {
    # nixpkgs channels
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-stable.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # home manager
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
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in {
      packages = {
        postmanCustom = import ./modules/postman/default.nix {
          inherit pkgs;
        };
      };
      nixosConfigurations = {
        "TLM-NixOS" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs unstablePkgs;
          };
          modules = [
            ./hosts/hardware.nix ./hosts/system.nix
            home-manager.nixosModules.home-manager {
               home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${userName} = import ./hosts/home.nix;
                extraSpecialArgs = {
                  inherit pkgs unstablePkgs self;
                };
              };
            }
          ];
        };
      };
    };
}
