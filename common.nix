{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./appimage-support.nix
    ./rider.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import <nixos-unstable> {
      config = config.nixpkgs.config;
    };
  };

  # Try out the new rebuild script
  system.rebuild.enableNg = true;

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.willem = {
    isNormalUser = true;
    description = "Willem Toorenburgh";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "gamemode" "dialout"];
    packages = with pkgs; [
      # Switching to unstable for work, to be compatible with BuildGraph extension
      unstable.vscodium
      # Nix language server
      nixd
      # Nix code formatter
      alejandra
      # Nix package version diff tool
      nvd
      thunderbird
      tldr
      transmission_4-qt
      obs-studio
      fastfetch
      discord
      ungit
      # Mypaint is breaking builds while upgrading to 24.11
      # mypaint
      bottles
      vlc
      ktailctl
      # Epson printer support
#       epson-escpr
      # Try out these and eliminate whichever I don't want to use
#       kdePackages.kleopatra
      kdePackages.kgpg
#       kdePackages.isoimagewriter
      kdePackages.minuet
      # Remote Desktop client
      kdePackages.krdc
      # KDE audio tag editor
      kid3-kde
      kmymoney
      skrooge
      # Trying out alternative RDP client
      freerdp
      # Another alternative! Sunshine + Moonlight
      moonlight-qt
      # Borg Backup UI
      vorta
      bitwarden-desktop
      bitwarden-cli
      virt-viewer
      # For HDR videos
      mpv
      # Clipboard interaction on CLI
      wl-clipboard-x11
      # Trying out waypipe, which lets you Wayland across SSH
      unstable.waypipe
      # Allows waypipe's --xwls flag to work, forwarding xwayland clients
      xwayland-satellite
      # Trying out the Zed editor
      zed-editor-fhs
    ];
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    config.credential.helper = "libsecret";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Nix-specific command not found helper
  programs.command-not-found.enable = true;

  # General monitoring tool; ol' reliable
  programs.htop.enable = true;

  # Disk monitoring tool
  programs.iotop.enable = true;

  # Network monitoring tool
  programs.iftop.enable = true;

  # Precise monitoring tool
  programs.atop = {
    enable = true;
    setuidWrapper.enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow Powershell to be a login shell
  environment.shells = [pkgs.powershell pkgs.zsh];

  # Enable virtualization
  virtualisation = {
    libvirtd.enable = true;
    # Allow USB passthrough. Turn this off when not needed as it allows
    # arbitrary USB access to all users
    spiceUSBRedirection.enable = false;
  };
  programs.virt-manager.enable = true;

  programs.nano = {
    enable = true;
    syntaxHighlight = true;
  };

  programs.vscode = {
    enable = false;
    package = pkgs.unstable.vscode-fhs;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.powershell
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    zsh
    easyeffects
    gparted
    # Powershell my beloved
    powershell
    oh-my-posh
    aha
    p7zip
    lm_sensors
    borgbackup
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    startWhenNeeded = true;
    settings = {
      UseDns = true;
    };
  };

  # Accompanying SSH client settings
  # from https://wiki.nixos.org/wiki/SSH_public_key_authentication
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
  };

  # Make things actually use the ask password setting
  environment.variables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  networking.networkmanager.plugins = with pkgs; [
    # Provides OpenVPN support to the Plasma network settings interface
    networkmanager-openvpn
  ];

  # Open ports in the firewall.
  networking.firewall = {
    allowPing = true;
    pingLimit = "--limit 1/minute --limit-burst 5";

    allowedTCPPorts = [
      # Allow Spotify access to local network (TCP)
      57621
    ];
    allowedTCPPortRanges = [
      # Allow KDE Connect (TCP)
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPorts = [
      # Allow Spotify access to local network (UDP)
      57621
    ];
    allowedUDPPortRanges = [
      # Allow KDE Connect (UDP)
      {
        from = 1714;
        to = 1764;
      }
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

  #   networking.nameservers = ["100.100.100.100" "10.0.0.6" "10.0.0.1"];
  networking.search = ["bear-draconis.ts.net" "couchlan"];

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
