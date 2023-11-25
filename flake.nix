{
  description = "My NixOS System";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: 
  let 
    system = "x86_64-linux";
    overlays = [
      (import ./overlays/with-copilot.nix)
      (self: super: {
        unstable = import <nixos-unstable> {
          config = config.nixpkgs.config;
        };
      })
    ];
    pkgs = import nixpkgs { 
      inherit system;
      inherit overlays;
      config = { 
        allowUnfree = true; 
      };
    };
  in
  {
    nixosConfigurations = {
      "TLM-NixOS" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };
        modules = [ 
          ./hardware.nix 
          ./system.nix
        ];
      };
    };
  };
}
