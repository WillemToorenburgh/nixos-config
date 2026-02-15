{
  config,
  pkgs,
  lib,
  ...
}: {

  imports = [
    ./plasma-discover-flatpak.nix
  ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland = {
    enable = true;
    compositor = "kwin";
  };
  services.desktopManager.plasma6.enable = true;

  # Tell Chromium/Electron applications to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable colour management, to later be managed with colord-kde
  services.colord.enable = true;

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      roboto
      roboto-slab
      roboto-mono
      roboto-serif
      nerd-fonts.roboto-mono
    ];
    fontconfig.useEmbeddedBitmaps = true;
    fontconfig.defaultFonts.monospace = ["RobotoMono Nerd Font [GOOG]"];
  };

  ## KDE applications and themeing
  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "kde";
  };

  programs = {
    kdeconnect.enable = true;
    partition-manager.enable = true;
    kde-pim = {
      # Calendar and contacts programs
      merkuro = true;
      # Email suite; Disabling as I'm not fond of the interface
      kontact = false;
      kmail = false;
    };
  };

  # Packages to install on a system-level
  environment.systemPackages = with pkgs.kdePackages; [
    ## Plugins for various Plasma elements
    kcoreaddons
    colord-kde
    sddm-kcm
    ksystemlog
    kaccounts-providers
    kaccounts-integration
    kio
    kio-fuse
    kio-gdrive
    kio-admin
    kio-extras
    kio-zeroconf
    kdeplasma-addons
    plasma-disks

    # Plasma helper for SSH authentication
    ksshaskpass

    # Packages for email support
    kmail-account-wizard
    kdepim-addons
  ] ++ (with pkgs; [

    # For unpacking RAR archives in Ark
    unrar

    ## Utilities for the KDE Info Center
    clinfo
    pciutils
    wayland-utils
    # Replaced by mesa-demos in 25.11. Not sure if this means KDE doesn't need it anymore, or what. Removing for now.
    # glxinfo
    vulkan-tools
    # Shows info about firmware in Info Center, but not sure if needed anymore
    # fwupd
    # fwupd-efi
  ]);

  # Packages on the user level
  users.users.willem.packages = with pkgs.kdePackages; [
    # Powerful text editor
    kate

    # Calculator
    kcalc

    # Quake-style terminal manager
    yakuake

    # Disk usage visualizer
    filelight

    # Search utility
    kfind

    # Download managers
    kget
    ktorrent
  ] ++ (with pkgs; [
    # PDF editor
    karp

    # Raster image editor
    krita

    # KDE office suite
    kdePackages.calligra
  ]);
}
