{ config, lib, pkgs, stablePkgs, unstablePkgs, ... }:

{
  home.stateVersion = "23.11";

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

    # Dev Tools
    dbeaver
    stablePkgs.postman
    bun
  ];

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
      github.copilot-chat
      bbenoist.nix
      jnoortheen.nix-ide
      pkief.material-icon-theme
      ms-vscode.makefile-tools
      foxundermoon.shell-format
    ];
    userSettings = (import ./vscode).userSettings;
    keybindings = (import ./vscode).keybindings;
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    extraConfig =
      let
        vimFiles = lib.filterAttrs (name: type: lib.hasSuffix ".vim" name) (builtins.readDir ./neovim);
        vimFileNames = lib.attrNames vimFiles;
        vimConfigs = builtins.map builtins.readFile (map (path: builtins.path { name = path; path = ./neovim + "/${path}"; }) vimFileNames);
      in
      lib.concatStringsSep "\n" (vimConfigs ++ [
        "colorscheme gruvbox-material"
      ]);
    extraLuaConfig = ''
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
        indent = {
          enable = true  -- Enable Tree-sitter-based indentation
        }
      }
    '';
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      gruvbox-material
    ];
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
    syntaxHighlighting.enable = true;
    enableVteIntegration = true;
    historySubstringSearch.enable = true;
    shellAliases = {
      # nix
      configure = "sudo nvim /etc/nixos/configuration.nix";
      update = "sudo nix-channel --update";
      rebuild = "sudo nixos-rebuild switch";

      # system
      cat = "bat";
      ls = "eza --icons --group-directories-first";

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
}
