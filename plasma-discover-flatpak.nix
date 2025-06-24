 { pkgs, config, libs, ... }:

 with libs; let
   discover-wrapped = pkgs.symlinkJoin
    {
      name = "discover-flatpak-backend";
      paths = [ pkgs.kdePackages.discover ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/plasma-discover --add-flags "--backends flatpak"
      '';
    };
in
 {
    # Allow flatpaks
    services.flatpak.enable = true;
    # Supporting configs for enabling flatpaks on Plasma - https://nixos.org/manual/nixos/stable/#module-services-flatpak
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    xdg.portal.config.common.default = "gtk";
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
        discover-wrapped
        kdePackages.packagekit-qt
        libportal
    ];
 }
