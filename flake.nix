{
  description = "My NixOS System";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: 
  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs { 
      inherit system;
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
          "/home/tlm/Projets/NixOS/nixos/configuration.nix" 
        ];
      };
    };
  };
}
