{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Add unstable branch
  nixpkgs.overlays = [
    (self: super: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    })
    (import ./overlays/with-copilot.nix)
  ];

  # Enable Flakes and the new command-line tool
  nix = {
  package = pkgs.nixFlakes;
  extraOptions = ''
    experimental-features = nix-command flakes
  '';
};

  # File systems
  boot.supportedFilesystems = [ "ntfs" ];

  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
    useOSProber = true;
  };

  # Swap
  boot.kernel.sysctl = {
    "vm.swappiness" = 60;
  };

  # Enable OpenGL
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Enable networking
  networking.hostName = "TLM-NixOS"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall = {
    enable = false;
    checkReversePath = "loose";
  };

  # Set your time zone and locale
  time.timeZone = "Asia/Colombo";
  i18n.defaultLocale = "en_US.UTF-8";
  time.hardwareClockInLocalTime = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # fwupd is a simple daemon allowing you to update some devices' firmware, including UEFI for several machines.
  services.fwupd.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Xdg portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # Docker
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "tlm" ];

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

  # Android
  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  # GnuPg
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  # kdeconnect
  programs.kdeconnect.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    os-prober
    wget
    curl
    aria2
    gitFull
    gh
    lshw
    pciutils
    fwupd
    gnupg
    pinentry-gtk2
    docker
    docker-compose
    python312
    nodejs_18
    jdk17
  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "IosevkaTerm" ]; })
  ];

  system.stateVersion = "23.05";

}
