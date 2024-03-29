{ config, lib, pkgs, unstablePkgs, self, nixvim, ... }:
let username = "tlm";
in {
  
  imports = [
    ./configs/neovim
  ];

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # Utilities
    nixpkgs-fmt
    nixfmt
    aria2
    anydesk
    gnome.gnome-disk-utility
    direnv
    cloudflared
    qpwgraph

    # Multimedia
    stremio
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
    mongodb-compass
    gh
    unstablePkgs.android-studio
    (unstablePkgs.jetbrains.plugins.addPlugins
      unstablePkgs.jetbrains.idea-ultimate [ "17718" ])
    (unstablePkgs.jetbrains.plugins.addPlugins unstablePkgs.jetbrains.webstorm
      [ "17718" ])
    (unstablePkgs.jetbrains.plugins.addPlugins
      unstablePkgs.jetbrains.pycharm-professional [ "17718" ])
    (unstablePkgs.jetbrains.plugins.addPlugins unstablePkgs.jetbrains.rust-rover
      [ "17718" ])
    postman

    # Languages and Runtimes
    gcc_multi
    rustup
    trunk
    bun
    unstablePkgs.flutter

    # Python with packages
    (python311.withPackages (ps:
      with ps; [
        pip
        pipenv
        black
        isort
        flake8
        mypy
        pylint
        autopep8
        yapf
        pynvim
        numpy
        pandas
        matplotlib
        faker
      ]))

  ];

  # Git Configuration
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userName = "Thilina Lakshan";
    userEmail = "thilina.18@cse.mrt.ac.lk";
    extraConfig = { init.defaultBranch = "main"; };
  };
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-dash ];
  };

  # Aria2 Configuration
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
        ExecStart =
          "${pkgs.aria2}/bin/aria2c --conf-path=${config.home.homeDirectory}/.config/aria2/aria2.conf";
        Restart = "on-failure";
      };
    };
  };

  # VsCode Configuration
  programs.vscode = {
    enable = true;
    package = unstablePkgs.vscode;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with unstablePkgs.vscode-extensions; [
      # essentials
      github.copilot
      github.copilot-chat
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh

      # themes
      pkief.material-icon-theme
      github.github-vscode-theme

      # formatters & linters
      dbaeumer.vscode-eslint
      foxundermoon.shell-format
      esbenp.prettier-vscode
      formulahendry.auto-rename-tag

      # nix support
      jnoortheen.nix-ide
      arrterian.nix-env-selector
      mkhl.direnv

      # python
      ms-python.python
      ms-python.black-formatter
      ms-python.vscode-pylance
      ms-python.isort
      ms-toolsai.jupyter
      ms-toolsai.vscode-jupyter-slideshow
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.jupyter-renderers
      ms-toolsai.jupyter-keymap

      # rust
      rust-lang.rust-analyzer
      vadimcn.vscode-lldb
      serayuzgur.crates
      tamasfe.even-better-toml

      # Cpp
      ms-vscode.cpptools
    ];
    userSettings =
      builtins.fromJSON (builtins.readFile ./configs/vscode/settings.json);
    keybindings =
      builtins.fromJSON (builtins.readFile ./configs/vscode/keybindings.json);
  };

  # Neovim Configuration
  # programs.neovim = {
  #   enable = true;
  #   package = pkgs.neovim-unwrapped;
  #   defaultEditor = true;
  #   viAlias = true;
  #   vimAlias = true;
  #   vimdiffAlias = true;
  #   withNodeJs = true;
  #   withPython3 = true;
  #   plugins = with pkgs.vimPlugins; [
  #     plenary-nvim
  #     nvim-web-devicons
  #     nui-nvim
  #     nvim-treesitter.withAllGrammars
  #     gruvbox-material
  #     copilot-lua
  #     telescope-nvim
  #     telescope-file-browser-nvim
  #     neo-tree-nvim
  #     bufferline-nvim
  #   ];
  #   extraConfig = let
  #     vimFiles = lib.filterAttrs (name: type: lib.hasSuffix ".vim" name)
  #       (builtins.readDir ./configs/neovim);
  #     vimFileNames = lib.attrNames vimFiles;
  #     vimConfigs = builtins.map builtins.readFile (map (path:
  #       builtins.path {
  #         name = path;
  #         path = ./configs/neovim + "/${path}";
  #       }) vimFileNames);
  #   in lib.concatStringsSep "\n"
  #   (vimConfigs ++ [ "colorscheme gruvbox-material" ]);
  #   extraLuaConfig = let
  #     luaFiles = lib.filterAttrs (name: type: lib.hasSuffix ".lua" name)
  #       (builtins.readDir ./configs/neovim);
  #     luaFileNames = lib.attrNames luaFiles;
  #     luaConfigs = builtins.map builtins.readFile (map (path:
  #       builtins.path {
  #         name = path;
  #         path = ./configs/neovim + "/${path}";
  #       }) luaFileNames);
  #   in lib.concatStringsSep "\n" (luaConfigs);
  # };

  # Shell Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    enableVteIntegration = true;
    historySubstringSearch.enable = true;
    shellAliases = {
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
    plugins = [{
      name = "zsh-nix-shell";
      file = "nix-shell.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "chisui";
        repo = "zsh-nix-shell";
        rev = "v0.7.0";
        sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
      };
    }];
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.starship;
    settings = (import ./configs/shell/starship.nix lib).settings;
  };

  # MPV Configuration
  programs.mpv = {
    enable = true;
    config = {
      save-position-on-quit = true;
      cache = "yes";
      cache-on-disk = "yes";
      demuxer-max-bytes = "4096MiB";
      demuxer-max-back-bytes = "20MiB";
      demuxer-readahead-secs = "3600";
    };
  };
}
