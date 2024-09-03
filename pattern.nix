{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };

  # Kernel modules identified on the system by lm_sensors' sensors-detect
  boot.kernelModules = [ "jc42" "nct6775" ];
#   Breaks on boot
#   boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.etc = {
    "sysconfig/lm_sensors".text = ''
    # Generated by sensors-detect on Tue Jul 16 12:27:01 2024
    # This file is sourced by /etc/init.d/lm_sensors and defines the modules to
    # be loaded/unloaded.
    #
    # The format of this file is a shell script that simply defines variables:
    # HWMON_MODULES for hardware monitoring driver modules, and optionally
    # BUS_MODULES for any required bus driver module (for example for I2C or SPI).

    HWMON_MODULES="jc42 nct6775"
    '';
  };

  hardware = {
    keyboard.uhk.enable = true;

    enableAllFirmware = true;

    bluetooth = {
      enable = true;
    };
  };

  networking = {
    hostName = "pattern-nixos"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Make displays behave as expected at login screen
  services.displayManager.sddm.setupScript = ''
  ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --auto --primary --output DP-1 --left-of DP-1 --rotate left --noprimary --output HDMI-A-1 --right-of DP-2 --noprimary
  '';
  #TODO: not working
  services.xserver.displayManager.setupCommands =
  ''
  ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --auto --primary --output DP-1 --left-of DP-1 --rotate left --noprimary --output HDMI-A-1 --right-of DP-2 --noprimary
  '';

  # Support for UPS
  services.apcupsd.enable = false;

  # Enable fwupd, mainly for Info Center at the moment
  services.fwupd.enable = true;

  # Enable OpenRGB features
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
  };

  # Mount shared NTFS disks in read/write mode
  boot.supportedFilesystems = [ "ntfs" ];

  environment.systemPackages = with pkgs; [
    # Make NTFS-3G utilities available, even though the above line installs it
    ntfs3g
    # UHK Agent support
    uhk-agent
    # Also mainly for System Info
    fwupd-efi
  ];

  fileSystems = {
    "/run/media/willem/Windows" = {
      device = "/dev/nvme0n1p4";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "nofail" ];
    };
    "/run/media/willem/Files" = {
      device = "/dev/sda4";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "nofail" ];
    };
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 32*1024;
  } ];

  time.hardwareClockInLocalTime = true;

#     # Monitor setup using XRandR configs
#     services.xserver.xrandrHeads = [
#         "DP-3"
#         {
#
#         }
#     ];

}
