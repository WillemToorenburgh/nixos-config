{
  config,
  pkgs,
  lib,
  ...
}: let
  exitGamescopeSessionScript = pkgs.writeTextFile {
    name = "steamos-session-select";
    executable = true;
    destination = "/usr/bin/steamos-session-select";
    text = ''
      #!${pkgs.stdenv.shell}
      steam -shutdown
    '';
    # No idea why this is here or what it does
    checkPhase = ''
      ${pkgs.stdenv.shell} -n $out/usr/bin/steamos-session-select
    '';
  };
#   exitGamescopeSessionScript =
#     pkgs.writeShellScriptBin
#     "steamos-session-select"
#     ''
#       steam -shutdown
#     '';

  bizHawkRepo = pkgs.fetchFromGitHub {
    owner = "TASEmulators";
    repo = "BizHawk";
    # Tagged version doesn't include Nix updates for 2.11
    # Using master instead
    # tag = "2.11";
    rev = "ce5fe4e3fa521fb66f223f07b2de1a52bdc0818c";
    hash = "sha256-YDL9kNlvkIXQUAZDUyPloSRsakVvmZrE4I22YlPkBpo=";
    fetchSubmodules = true;
  };

  bizHawkImport = import bizHawkRepo { system = builtins.currentSystem; };
in {

  # Allow unfree packages, required for Steam
  nixpkgs.config.allowUnfree = true;

  users.users.willem.packages = with pkgs; [
      (lutris.override {
        extraPkgs = pkgs: [
          # All notes as of 24.11
          wineWowPackages.full # 32-bit Wine 9.0
          wineWowPackages.stagingFull # 32-bit Wine 9.20 with staging packages
        ];
      })
      protonup-qt
      mangohud
      goverlay
      # Another alternative! Sunshine + Moonlight
      moonlight-qt
      #unstable.path-of-building
      gpu-screen-recorder-gtk
      # For mucking around with Flash things
      ruffle
      # PS4 emulator
      unstable.shadps4
      ] ++ [ bizHawkImport.emuhawk-2_11-bin ];
#     ] ++ [ bizHawkImport.emuhawk-latest ];

  nixpkgs.overlays = [
    (final: prev: {
      gamescope-wsi = prev.gamescope-wsi.override {enableExecutable = true;};
    })
  ];

  programs.gamescope = {
    enable = true;
    package = pkgs.gamescope-wsi;
    capSysNice = true;
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

  programs.steam = {
    # This also enables Steam hardware support, including the Index
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };
    # Helps Steaminput on Wayland
    extest.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraPackages = [ exitGamescopeSessionScript ];
    # Try to enable a gamescope login session
    # TODO: perhaps move this to pattern.nix
    gamescopeSession = {
      enable = true;
      args = [
        "-O DP-1 -W 2560 -H 1440 -r 360"
        "--mouse-sensitivity 2"
        "--hdr-enabled"
        "--hdr-itm-enable"
        "--hdr-sdr-content-nits=250"
        #         "--hdr-debug-force-output"
        #         "--hdr-debug-force-support"
        #         "--rt"
        "--expose-wayland"
      ];
      env = {
        "WLR_RENDERER" = "vulkan";
        "ENABLE_GAMESCOPE_WSI" = "1";
        "ENABLE_HDR_WSI" = "1";
        "DXVK_HDR" = "1";
        "DISABLE_HDR_WSI" = "0";
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      # Phasmophobia
      27015
      27036
      # Red Alert 3 community server
      3783
      4321
      28900
      29900
      29901
      16000
    ];
    allowedUDPPorts = [
      # Phasmophobia
      27015
      # Red alert 3 community server
      6500
      6515
      13139
      27900
      16000
    ];
    allowedUDPPortRanges = [
      # Phasmophobia
      {
        from = 27031;
        to = 27036;
      }
    ];
  };

}
