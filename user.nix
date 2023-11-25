{ config, pkgs, ... }:

{
  # Git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      init.defaultBranch = "main";
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    configure = {
      customRC = ''
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set autoindent
        set smartindent
        set smarttab
        set number
        set relativenumber
        set showmatch
        set incsearch
        set hlsearch
        set ignorecase
        set smartcase
      '';
    };
  };

  # Shell configuration, ZSH
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      # nix
      configure = "sudo nvim /etc/nixos/configuration.nix";
      update = "sudo nix-channel --update";
      rebuild = "sudo nixos-rebuild switch";

      # system
      cat = "bat";
      ls = "exa --icons";

      # git 
      gcm = "git commit -m ";
      gaa = "git add .";
      gss = "git status";
      gc = "git_checkout ";
      gnn = "git_new_branch ";

      # programs
      vim = "nvim";
    };
    interactiveShellInit = ''
      # z plugin for jumps around
      source ${pkgs.fetchurl {url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh"; sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";}}

      # create a new git branch
      function git_new_branch() {
        from_branch="$(git branch | fzf)"
      }

      # git choose branch
      function git_checkout() {
        branch_name=$(echo $1 | tr -d ' ')
        branches=$(git branch | tr -d ' \t*')

        if [[ ! -z "$branch_name" ]]; then  # Check if branch_name is not empty
          if echo "$branches" | grep -Fxq "$branch_name"; then
              # If the branch exists, checkout directly
              git checkout "$branch_name"
          else
              # If the branch does not exist, use fzf with branch_name as initial query
              git branch | tr -d ' \t*' | fzf --query="$branch_name " | xargs git checkout
          fi
        else
            # If branch_name is empty, use fzf without initial query
            git branch | tr -d ' \t*' | fzf | xargs git checkout
        fi
      }

      # git new branch
      function git_new_branch() {
        branch_name=$(echo $1 | tr -d ' ')
        if [ -z "$branch_name" ]; then
          echo "Branch name is required"
          echo "Usage: git_new_branch <branch_name>"
          return
        fi

        from_branch="$(git branch | tr -d ' \t*' | fzf)"
        if [ -z "$from_branch" ]; then
          echo "Canceled"
          return
        fi

        git checkout -b $branch_name $from_branch
      }

      # prompt init
      eval "$(starship init zsh)"
    '';
    promptInit = "";
  };

  # User configuration and packages
  users.users.tlm = {
    isNormalUser = true;
    description = "Thilina Lakshan";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # Basics
      starship
      libsForQt5.yakuake

      # Browsers
      firefox
      brave
      google-chrome

      # Editors & IDEs
      kate
      unstable.vscode-fhs
      unstable.android-studio
      (pkgs.with-copilot unstable.jetbrains.idea-ultimate)
      (pkgs.with-copilot unstable.jetbrains.goland)
      (pkgs.with-copilot unstable.jetbrains.pycharm-professional)
      (pkgs.with-copilot unstable.jetbrains.webstorm)

      # Dev Tools
      unstable.dbeaver
      postman
      unstable.bun

      # Other
      stremio
      mpv
      obs-studio
      zoom-us
      slack
      discord

      # CLI tools
      bat
      exa
      fzf
      megacmd
    ];
  };
}