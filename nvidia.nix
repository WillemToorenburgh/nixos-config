{ pkgs, config, libs, lib, ... }:

{
#     Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    # Ensure the nvidia module is loaded early in boot
    boot.initrd.kernelModules = [ "nvidia" ];

    # Prevent the noveau drivers from being loaded
    boot.blacklistedKernelModules = [ "nouveau" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
#         libva-vdpau-driver
        nvidia-vaapi-driver
      ];
    };

    hardware.nvidia = {

        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials.
        powerManagement.enable = true;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        # No longer unstable: https://wiki.nixos.org/wiki/NVIDIA
        open = true;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Enable persistence to allow the GPU to run in a headless mode if need be
        nvidiaPersistenced = true;

        # Values grabbed from https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
        # Optionally, you may need to select the appropriate driver version for your specific GPU.

        package = config.boot.kernelPackages.nvidiaPackages.production;

        # This patching is unique to Linux 6.19.0 and Nvidia driver 590.48.01. Remove once upstream issues are resolved.
#         package = let
#           base = config.boot.kernelPackages.nvidiaPackages.mkDriver {
#             version = "595.58.03";
#             sha256_64bit = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
#             sha256_aarch64 = "sha256-hzzIKY1Te8QkCBWR+H5k1FB/HK1UgGhai6cl3wEaPT8=";
#             openSha256 = "sha256-6LvJyT0cMXGS290Dh8hd9rc+nYZqBzDIlItOFk8S4n8=";
#             settingsSha256 = "sha256-2vLF5Evl2D6tRQJo0uUyY3tpWqjvJQ0/Rpxan3NOD3c=";
#             persistencedSha256 = "sha256-AtjM/ml/ngZil8DMYNH+P111ohuk9mWw5t4z7CHjPWw=";
#           };
#           cachyos-nvidia-patch = [];
# #           cachyos-nvidia-patch = pkgs.fetchpatch {
# #             url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
# #             sha256 = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
# #           };
#           # Patch the appropriate driver based on config.hardware.nvidia.open
#           driverAttr = if config.hardware.nvidia.open then "open" else "bin";
#         in
#         base
#         // {
#           ${driverAttr} = base.${driverAttr}.overrideAttrs (oldAttrs: {
#             patches = (oldAttrs.patches or [ ]) ++ [ cachyos-nvidia-patch ];
#           });
#         };
        # Manual build at 555.58.02
        # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        #     version = "555.58.02";
        #     sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
        #     sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
        #     openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
        #     settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        #     persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
        # };
        # Manual build at 560.35.03
#         package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
#             version = "560.35.03";
#             sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
#             sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
#             openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
#             settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
#             persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
# #             patchesOpen = [ fbdev_linux_611_patch ];
#         };
#         package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
#             version = "565.57.01";
#             sha256_64bit = "sha256-buvpTlheOF6IBPWnQVLfQUiHv4GcwhvZW3Ks0PsYLHo=";
#             sha256_aarch64 = "sha256-aDVc3sNTG4O3y+vKW87mw+i9AqXCY29GVqEIUlsvYfE=";
#             openSha256 = "sha256-/tM3n9huz1MTE6KKtTCBglBMBGGL/GOHi5ZSUag4zXA=";
#             settingsSha256 = "sha256-H7uEe34LdmUFcMcS6bz7sbpYhg9zPCb/5AmZZFTx1QA=";
#             persistencedSha256 = "sha256-hdszsACWNqkCh8G4VBNitDT85gk9gJe1BlQ8LdrYIkg=";
#             patchesOpen = [ drm_fop_flags_linux_612_patch ];
#         };
    };

    # Some extra kernel things found here: https://discourse.nixos.org/t/nvidia-open-breaks-hardware-acceleration/58770/3
    boot.extraModprobeConfig = "options nvidia NVreg_UsePageAttributeTable=1";

    environment.variables = {
      MOZ_DISABLE_RDD_SANDBOX = "1";
    };

    environment.systemPackages = with pkgs; [
        nvtopPackages.full
        zenith-nvidia
        libva-utils
        nvidia-modprobe
    ];
 }
