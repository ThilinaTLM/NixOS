{
  description = "My NixOS System";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      userName = "tlm";
    in {
      nixosConfigurations = {
        "TLM-NixOS" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware.nix
            ./system.nix
            (import "${home-manager}/nixos")
            ./home.nix
          ];
        };
      };
    };
}
