{ pkgs, config, ... }:

{
  users.groups.nixremote = {};
  users.users.nixremote = {
    isNormalUser = true;
    description = "Remote Nix build user";
    group = "nixremote";
    shell = "/bin/false";
    createHome = true;
  };

  nix.settings.trusted-users = ["nixremote"];
}
