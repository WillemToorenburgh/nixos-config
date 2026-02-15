{ config, lib, pkgs, ... }:

let
  extra-path = with pkgs; [
    dotnetCorePackages.sdk_9_0
    dotnetCorePackages.runtime_9_0
#     mono
    msbuild
    avalonia
  ];

in

{
  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import <nixos-unstable> {
      config = config.nixpkgs.config;
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      rider = super.unstable.jetbrains.rider.overrideAttrs ( attrs: {
        postInstall = ''
      # Wrap rider with extra tools and libraries
      mv $out/bin/rider $out/bin/.rider-toolless
      makeWrapper $out/bin/.rider-toolless $out/bin/rider \
        --argv0 rider \
        --prefix PATH : "${lib.makeBinPath extra-path}"

      # Making Unity Rider plugin work!
      # The plugin expects the binary to be at /rider/bin/rider,
      # with bundled files at /rider/
      # It does this by going up two directories from the binary path
      # Our rider binary is at $out/bin/rider, so we need to link $out/rider/ to $out/
      shopt -s extglob
      ln -s $out/rider/!(bin) $out/
      shopt -u extglob
    '' + attrs.postInstall or "";
      });
    })
  ];

  users.users.willem.packages = with pkgs; [
    unstable.jetbrains.rider
  ] ++ extra-path;
}
