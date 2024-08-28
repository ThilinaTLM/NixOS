{
  config,
  lib,
  pkgs,
  unstablePkgs,
  self,
  nixvim,
  ...
}:
let
  username = "tlm";
in
{

  imports = [ ./configs/neovim ];

  home.stateVersion = "23.11";
  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    # Utilities
    nixfmt-rfc-style
    aria2
    gnome.gnome-disk-utility
    direnv
    cloudflared
    qpwgraph
    shellify
    appimage-run

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
    fd
    megacmd
    pipenv

    # Dev Tools
    dbeaver-bin
    gh
    android-studio
    (unstablePkgs.jetbrains.plugins.addPlugins unstablePkgs.jetbrains.idea-ultimate [ "17718" ])
    (unstablePkgs.jetbrains.plugins.addPlugins unstablePkgs.jetbrains.webstorm [ "17718" ])
    (unstablePkgs.jetbrains.plugins.addPlugins unstablePkgs.jetbrains.goland [ "17718" ])
    (unstablePkgs.jetbrains.plugins.addPlugins unstablePkgs.jetbrains.rust-rover [ "17718" ])
    postman
    unstablePkgs.vscode-fhs
    unstablePkgs.zed-editor

    # Languages and Runtimes
    gcc_multi
    rustup
    trunk
    bun
    flutter

    # Python with packages
    (python311.withPackages (
      ps: with ps; [
        pip
        pipenv
        black
        isort
        flake8
        mypy
        pylint
        autopep8
        yapf
      ]
    ))
  ];

  # Git Configuration
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userName = "Thilina Lakshan";
    userEmail = "thilina.18@cse.mrt.ac.lk";
    extraConfig = {
      init.defaultBranch = "main";
    };
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
        ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=${config.home.homeDirectory}/.config/aria2/aria2.conf";
        Restart = "on-failure";
      };
    };
  };

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
      # lazy directory completion
      zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'

      # z plugin for jumps around
      source ${
        pkgs.fetchurl {
          url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh";
          sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";
        }
      }

      # utility functions
      ${builtins.readFile ./configs/shell/functions.zsh}

      # prompt init
      eval "$(starship init zsh)"

      # sync clipboard
      function push_clipboard() {
        wl-paste | ssh laptop_g_via_repeater 'pbcopy'
      }
      function pull_clipboard() {
        ssh laptop_g_via_repeater 'pbpaste' | wl-copy
      }
    '';
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
        };
      }
    ];
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
