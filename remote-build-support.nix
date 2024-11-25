{ pkgs, config, ... }:

{
  users.groups.nixremote = {};
  users.users.nixremote = {
    isNormalUser = true;
    description = "Remote Nix build user";
    group = "nixremote";
    createHome = true;
  };

  nix.settings.trusted-users = ["nixremote"];

  services.displayManager.sddm.settings = {
    Users = {
      HideUsers = "nixremote";
    };
  };
}
