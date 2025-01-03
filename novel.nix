{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./remote-build-client.nix
#     <nixos-hardware/microsoft/surface/surface-pro-intel>``
    ./nvidia.nix
    ./unity-editor-support.nix
  ];

#   microsoft-surface = {
#     ipts.enable = true;
#     surface-control.enabled = true;
#   };

  services.iptsd = {
    enable = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  services.udev.packages = with pkgs; [
    iptsd
    surface-control
  ];
  systemd.packages = with pkgs; [
    iptsd
  ];

  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  time.hardwareClockInLocalTime = true;

  networking = {
    hostName = "novel-nixos"; # Define your hostname.
#     wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;
  };

  hardware = {
    keyboard.uhk.enable = true;

    enableAllFirmware = true;

    bluetooth = {
      enable = true;
    };
  };

  # Enable fwupd, mainly for Info Center at the moment
  services.fwupd.enable = true;

  users.users.willem = {
    extraGroups = [ "surface-control" ];
  };

  # Nvidia support
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
#     pci@0000:00:02.0
    intelBusId = "PCI:2:0:0";
#     pci@0000:02:00.0
    nvidiaBusId = "PCI:0:2:0";
  };

  environment.systemPackages = with pkgs; [
    libcamera
    libwacom-surface
    kdePackages.wacomtablet
    surface-control
    # UHK Agent support
    uhk-agent
    # Also mainly for System Info
    fwupd-efi
  ];
}
