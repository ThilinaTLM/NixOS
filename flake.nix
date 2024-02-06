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
        overlays = [
          (final: prev: {
            postman = prev.postman.overrideAttrs(old: rec {
              version = "20230716100528";
              src = final.fetchurl {
                url = "https://web.archive.org/web/${version}/https://dl.pstmn.io/download/latest/linux_64";
                sha256 = "sha256-svk60K4pZh0qRdx9+5OUTu0xgGXMhqvQTGTcmqBOMq8=";
                name = "${old.pname}-${version}.tar.gz";
              };
            });
          })
        ];
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
