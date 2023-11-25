{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> {
    config = config.nixpkgs.config;
  };
in
{
  home-manager.users.tlm = { config, pkgs, ... }: {
    home.stateVersion = "23.05";

    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (self: super: {
          vscode = unstable.vscode;
          vscode-extensions = unstable.vscode-extensions;
        })
      ];
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        yzhang.markdown-all-in-one
        github.copilot
        bbenoist.nix
      ];
      userSettings = ''
        {
            "workbench.colorTheme": "Default Dark Modern",
            "editor.inlineSuggest.enabled": true,
            "extensions.autoUpdate": false,
            "files.autoSave": "afterDelay",
            "editor.fontFamily": "'IosevkaTerm Nerd Font', 'Droid Sans Mono', 'monospace', monospace"
        }
      '';
    };


    home.packages = [
      
    ];
    
  };
}
