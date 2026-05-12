# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <apple-silicon-support/apple-silicon-support>
      ./common.nix
      ./desktop-environment.nix
    ];

  nix.settings = {
    substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };

  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=0
  '';

  hardware = {
    bluetooth.enable = true;

  };

  # Configure network connections interactively with nmcli or nmtui.
  networking = {
    hostName = "macrelige-nixos";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    wireless.iwd = {
      enable = true;
#       settings.General.EnableNetworkConfiguration = true;
#       settings.Network.NameResolvingService = "resolvconf";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
}
