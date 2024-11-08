{ config, pkgs, ... }:

{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [{
    hostName = "pattern-nixos";
    sshUser = "nixremote";
    system = builtins.currentSystem;
#     systems = [
#       builtins.currentSystem
#       "i686-linux"
#     ];
    maxJobs = 16;
    protocol = "ssh-ng";
    speedFactor = 2;
    supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
  }];

}
