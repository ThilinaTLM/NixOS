{ config, pkgs, lib, ... }:
let unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in {
  home-manager.useUserPackages = true;

  home-manager.users.tlm = { config, pkgs, ... }: {
    home.stateVersion = "23.05";

    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (self: super: {
          vscode = unstable.vscode;
          vscode-extensions = unstable.vscode-extensions;
          eza = unstable.eza;
        })
      ];
    };

    home.packages = with pkgs; [
      # Utilities
      nixpkgs-fmt
      nixfmt

      # Multimedia
      stremio
      mpv
      obs-studio
      zoom-us
      slack
      discord

      # CLI tools
      bat
      eza
      fzf
      megacmd
    ];

    # programs.eza = {
    #   enable = true;
    #   git = true;
    #   icons = true;
    #   enableAliases = true;
    # };

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userName = "Thilina Lakshan";
      userEmail = "thilina.18@cse.mrt.ac.lk";
      extraConfig = { 
        init.defaultBranch = "main";
      };
    };

    programs.gh = {
      enable = true;
      extensions = [ pkgs.gh-dash ];
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        yzhang.markdown-all-in-one
        github.copilot
        bbenoist.nix
        jnoortheen.nix-ide
        pkief.material-icon-theme
        foxundermoon.shell-format
      ];
      userSettings = {
        "workbench.colorTheme" = "Default Dark Modern";
        "workbench.iconTheme" = "material-icon-theme";
        "editor.inlineSuggest.enabled" = true;
        "files.autoSave" = "afterDelay";
        "editor.fontFamily" =
          "'IosevkaTerm Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      package = pkgs.starship;
      settings = (import ./shell/starship.nix lib).settings;
    };

    # Shell configuration, ZSH
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      enableVteIntegration = true;
      historySubstringSearch.enable = true;
      shellAliases = {
        # nix
        configure = "sudo nvim /etc/nixos/configuration.nix";
        update = "sudo nix-channel --update";
        rebuild = "sudo nixos-rebuild switch";

        # system
        cat = "bat";
        ls = "eza --icons --git-repos --group-directories-first";

        # git 
        gcm = "git commit -m ";
        gaa = "git add .";
        gss = "git status";
        gc = "git_checkout ";
        gnn = "git_new_branch ";

        # programs
        vim = "nvim";
      };
      initExtra = ''
        # z plugin for jumps around
        source ${
          pkgs.fetchurl {
            url =
              "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh";
            sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";
          }
        }

        # utility functions
        ${builtins.readFile ./shell/functions.zsh}

        # prompt init
        eval "$(starship init zsh)"
      '';
    };

  };
}
