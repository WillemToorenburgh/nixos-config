{ config, pkgs, lib, ... }:

{
  imports = [
      ./plasma-discover-flatpak.nix
      ./appimage-support.nix
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import <nixos-unstable> {
      config = config.nixpkgs.config;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Tell Chromium/Electron applications to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable colour management, to later be managed with colord-kde
  services.colord.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Try making Parsec run with ffmpeg7
#   nixpkgs.overlays = [
#     (self: super: {
#       parsec-bin = super.parsec-bin.overrideAttrs {
#         runtimeDependenciesPath = lib.makeLibraryPath [
#             pkgs.stdenv.cc.cc
#             pkgs.libglvnd
#             pkgs.openssl
#             pkgs.udev
#             pkgs.alsa-lib
#             pkgs.libpulseaudio
#             pkgs.libva
#             pkgs.ffmpeg
#             pkgs.libpng
#             pkgs.libjpeg8
#             pkgs.curl
#             pkgs.xorg.libX11
#             pkgs.xorg.libXcursor
#             pkgs.xorg.libXi
#             pkgs.xorg.libXrandr
#             pkgs.xorg.libXfixes
#             pkgs.vulkan-loader
#         ];};
#     })
#   ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.willem = {
    isNormalUser = true;
    description = "Willem Toorenburgh";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "gamemode" ];
    packages = with pkgs; [
      kdePackages.kate
      vscodium
      nixd
      thunderbird
      lutris
      protonup-qt
      unstable.parsec-bin
      krita
      tldr
      mangohud
      goverlay
      transmission_4-qt
      obs-studio
      fastfetch
      discord
      ungit
      mypaint
      bottles
      vlc
      ktailctl
      # Epson printer support
      epson-escpr
      # Try out these and eliminate whichever I don't want to use
      kdePackages.yakuake
      kdePackages.ktorrent
      kdePackages.merkuro
      kdePackages.kleopatra
      kdePackages.kgpg
      kdePackages.kcalc
      kdePackages.kalk
      kdePackages.kbackup
      kdePackages.isoimagewriter
      kdePackages.filelight
      kdePackages.plasma-disks
      kdePackages.minuet
      kdePackages.kontact
      kdePackages.kmail-account-wizard
      kdePackages.kdepim-addons
      # KDE office suite
      unstable.kdePackages.calligra
      kmymoney
      skrooge
      # Borg Backup UI
      vorta
      unstable.jetbrains.rider
    ];
  };

  # Temporarily allow insecure qtwebkit
  # TODO: remove this as soon as Calligra is upgraded to 4.0
#   nixpkgs.config.permittedInsecurePackages = [
#     "qtwebkit-5.212.0-alpha4"
#   ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config.credential.helper = "libsecret";
  };

  programs.steam = {
    # This also enables Steam hardware support, including the Index
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Set up GameMode, which runs various enhancements to improve gaming
  # https://nixos.wiki/wiki/Gamemode
  programs.gamemode = {
    enable = true;
    #TODO: configure this if need be (things like the renice level)
#     settings = {
#
#     };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.gamescope.enable = true;

  # Font configs
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      roboto
      roboto-slab
      roboto-mono
      roboto-serif
      (nerdfonts.override { fonts = [ "RobotoMono" ]; })
    ];
    fontconfig.defaultFonts.monospace = [ "RobotoMono Nerd Font [GOOG]" ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow Powershell to be a login shell
  environment.shells = [ pkgs.powershell pkgs.zsh ];

  # Enable virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # KDE applications and themeing
  programs = {
    kdeconnect.enable = true;
    partition-manager.enable = true;
  };
  # Disabling as it's using libsForQt5 and not plasma6-friendly things
#   qt = {
#     style = "breeze";
#     platformTheme = "kde";
#   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    htop
    kdePackages.kcoreaddons
    kdePackages.colord-kde
    kdePackages.sddm-kcm
    kdePackages.ksystemlog
    kdePackages.kaccounts-providers
    kdePackages.kaccounts-integration
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-gdrive
    kdePackages.kio-admin
    kdePackages.kio-extras
    kdePackages.kio-zeroconf
    kdePackages.kdeplasma-addons
    git
    zsh
    easyeffects
    gparted
    # Powershell my beloved
    powershell
    oh-my-posh
    # Utilities for the KDE Info Center
    clinfo
    glxinfo
    vulkan-tools
#     fwupd
#     fwupd-efi
    pciutils
    wayland-utils
    aha
    p7zip
    lm_sensors
    borgbackup
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

#   Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    startWhenNeeded = true;
    settings = {
      UseDns = true;
    };
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
    # Allow Spotify access to local network (TCP)
      57621
      # Phasmophobia
      27015
      27036
    ];
    allowedTCPPortRanges = [
      # Allow KDE Connect (TCP)
      { from = 1714; to = 1764; }
    ];
    allowedUDPPorts = [
    # Allow Spotify access to local network (UDP)
      57621
      # Phasmophobia
      27015
    ];
    allowedUDPPortRanges = [
      # Allow KDE Connect (UDP)
      { from = 1714; to = 1764; }
      # Phasmophobia
      { from = 27031; to = 27036; }
    ];
    # Allow Spotify access to multicast DNS
    # NOTE: this needs to be replaced with extraInputRules if switching to nftables
    # NOTE: 10.0.0.198 is Screen's IP, should reserve that in DHCP
    # NOTE: 239.255.255.250 is a special multicast address
    extraCommands = ''
      iptables -A INPUT -p udp --sport 1900 --dport 1025:65535 -j ACCEPT -m comment --comment spotify
      iptables -A INPUT -p udp --sport 5353 --dport 1025:65535 -j ACCEPT -m comment --comment spotify
      iptables -A INPUT -s 10.0.0.198/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (inbound)" -j ACCEPT
      iptables -A OUTPUT -d 10.0.0.198/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (outbound)" -j ACCEPT
      iptables -A OUTPUT -d 10.0.0.198/32 -p tcp -m multiport --dports 8008:8009 -m comment --comment "Allow Chromecast TCP data (outbound)" -j ACCEPT
      iptables -A OUTPUT -d 239.255.255.250/32 -p udp --dport 1900 -m comment --comment "Allow Chromecast SSDP" -j ACCEPT
    '';
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };

  networking.nameservers = ["100.100.100.100" "10.0.0.1"];
  networking.search = ["bear-draconis.ts.net" ".couchlan"];

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
