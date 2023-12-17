{ config, lib, pkgs, stablePkgs, unstablePkgs, self, ... }:
let 
  username = "tlm";
in
{
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # Utilities
    nixpkgs-fmt
    nixfmt
    aria2

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
    pipenv

    # Dev Tools
    dbeaver
    self.packages.postmanCustom
    mongodb-compass
    gh
    unstablePkgs.android-studio
    (with-copilot self.packages.jetbrainsCustom.idea-ultimate)
    (with-copilot self.packages.jetbrainsCustom.webstorm) 
    # (with-copilot unstablePkgs.jetbrains.rust-rover)
    # (with-copilot jetbrains.goland)
    # jetbrains.pycharm-professional

    # Languages and Runtimes
    rustup
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

  programs.aria2 = {
    enable = true;
    settings = {
      enable-rpc = true;
      rpc-listen-all = true;
      max-concurrent-downloads = 4;
      dir = "/home/${username}/Downloads";
    };
  };

  systemd.user.services = {
    aria2 = {
      Unit = {
        Description = "Aria2c Daemon";
        After = "network.target";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=${config.home.homeDirectory}/.config/aria2/aria2.conf";
        Restart = "on-failure";
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = unstablePkgs.vscode;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with unstablePkgs.vscode-extensions; [
      github.copilot
      github.copilot-chat
      jnoortheen.nix-ide
      pkief.material-icon-theme
      ms-vscode.makefile-tools
      foxundermoon.shell-format
      ms-python.python
      ms-azuretools.vscode-docker
      esbenp.prettier-vscode
      streetsidesoftware.code-spell-checker
      dbaeumer.vscode-eslint
      formulahendry.auto-rename-tag
      # visualstudioexptteam.vscodeintellicode
      formulahendry.code-runner
    ];
    userSettings = builtins.fromJSON (builtins.readFile ./configs/vscode/settings.json);
    keybindings = builtins.fromJSON (builtins.readFile ./configs/vscode/keybindings.json);
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
        vimFiles = lib.filterAttrs (name: type: lib.hasSuffix ".vim" name) (builtins.readDir ./configs/neovim);
        vimFileNames = lib.attrNames vimFiles;
        vimConfigs = builtins.map builtins.readFile (map (path: builtins.path { name = path; path = ./configs/neovim + "/${path}"; }) vimFileNames);
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
    settings = (import ./configs/shell/starship.nix lib).settings;
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
      ${builtins.readFile ./configs/shell/functions.zsh}

      # prompt init
      eval "$(starship init zsh)"
    '';
  };
}
