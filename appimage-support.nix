{ pkgs, config, libs, ... }:

{
  # Supporting bits for running AppImages
  # From the wiki - https://nixos.wiki/wiki/Appimage

  # TODO: check out programs.appimage.* to see if that replaces any of this

  environment.systemPackages = with pkgs; [
    appimage-run
  ];

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };
}
