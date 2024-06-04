{
  description = "My NixOS System";

  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # nixpkgs channels
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    # home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-alien,
      ...
    }@attrs:
    let
      system = "x86_64-linux";
      userName = "tlm";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
        overlays = [
          (final: prev: {
            postman = prev.postman.overrideAttrs (old: rec {
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
      nixAlien = import nix-alien {  };
    in
    {
      packages = {
        postmanCustom = import ./modules/postman/default.nix { inherit pkgs; };
      };
      nixosConfigurations = {
        "TLM-NixOS" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs nixAlien;
          };
          modules = [
            ./hosts/hardware.nix
            ./hosts/system.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${userName} = import ./hosts/home.nix;
                extraSpecialArgs = {
                  inherit pkgs nixAlien self;
                };
              };
            }
          ];
        };
      };
    };
}
