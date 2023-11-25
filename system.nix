{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (import ./overlays/with-copilot.nix)
    (self: super: {
      unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
    })
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
  boot.kernel.sysctl = { "vm.swappiness" = 60; };

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
    gnumake
  ];

  fonts.fonts = with pkgs;
    [ (nerdfonts.override { fonts = [ "FiraCode" "IosevkaTerm" ]; }) ];

  system.stateVersion = "23.05";

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
      # Basics
      # starship
      libsForQt5.yakuake

      # Browsers
      firefox
      brave
      google-chrome

      # Editors & IDEs
      kate
      unstable.android-studio
      (pkgs.with-copilot unstable.jetbrains.idea-ultimate)
      (pkgs.with-copilot unstable.jetbrains.goland)
      (pkgs.with-copilot unstable.jetbrains.pycharm-professional)
      (pkgs.with-copilot unstable.jetbrains.webstorm)
    ];
  };

}
