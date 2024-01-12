{ config, pkgs, unstablePkgs, ... }:
{
  # Enable Flakes and the new command-line tool
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Kernel & Filesystems
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernel.sysctl = { "vm.swappiness" = 60; };
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
    useOSProber = true;
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

  # Android
  programs.adb.enable = true;
  services.udev.packages = [ pkgs.android-udev-rules ];

  # GnuPg
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  # kdeconnect
  programs.kdeconnect.enable = true;

  # KVM Virtualisation
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  programs.virt-manager.enable = true;
  services.spice-vdagentd.enable = true;
  programs.dconf.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    os-prober
    wget
    curl
    gitFull
    lshw
    pciutils
    fwupd
    gnupg
    pinentry-gtk2
    openssl
    nix-index
    cachix

    # clipboard tools
    xclip 
    xsel
    wl-clipboard
    
    # Development tools
    docker
    docker-compose
    python311
    python311Packages.pip
    nodejs_18
    jdk17
    gnumake
    gcc-unwrapped

    # Virtualisation
    virt-manager
    virt-viewer
    spice 
    spice-gtk
    win-virtio 
    win-spice
    gnome.adwaita-icon-theme
  ];

  fonts = {
    packages = with pkgs; [ 
      (nerdfonts.override { fonts = [ "FiraCode" "IosevkaTerm" ]; }) 
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk
      open-sans
      corefonts
      vistafonts
      ubuntu_font_family
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "full";
        autohint = true;
      };
      subpixel = {
        rgba = "rgb";
      };
    };
  };

  system.stateVersion = "23.11";

  # USER CONFIGURATION ---------------------------------------------------------

  # Zsh
  programs.zsh.enable = true;
  users.users.tlm.shell = pkgs.zsh;

  # User configuration and packages
  users.users.tlm = {
    isNormalUser = true;
    description = "Thilina Lakshan";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
      libsForQt5.yakuake
      libsForQt5.plasma-browser-integration
      firefox
      brave
      google-chrome
      kate
      libreoffice-qt
    ];
  };

}
