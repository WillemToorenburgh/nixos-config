{ pkgs, config, libs, lib, ... }:

let
#   # Fixes framebuffer with linux 6.11
#   fbdev_linux_611_patch = fetchpatch {
#     url = "https://patch-diff.githubusercontent.com/raw/NVIDIA/open-gpu-kernel-modules/pull/692.patch";
#     hash = "sha256-OYw8TsHDpBE5DBzdZCBT45+AiznzO9SfECz5/uXN5Uc=";
#   };

    # Fixes drm device not working with linux 6.12
    # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/712
    drm_fop_flags_linux_612_patch  = pkgs.fetchpatch {
    url = "https://github.com/Binary-Eater/open-gpu-kernel-modules/commit/8ac26d3c66ea88b0f80504bdd1e907658b41609d.patch";
    hash = "sha256-+SfIu3uYNQCf/KXhv4PWvruTVKQSh4bgU1moePhe57U=";
    };

in

{
#     Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

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
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = false;

        # Values grabbed from https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        # Stable at 550.x.x
#         package = config.boot.kernelPackages.nvidiaPackages.production;
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
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
            version = "565.57.01";
            sha256_64bit = "sha256-buvpTlheOF6IBPWnQVLfQUiHv4GcwhvZW3Ks0PsYLHo=";
            sha256_aarch64 = "sha256-aDVc3sNTG4O3y+vKW87mw+i9AqXCY29GVqEIUlsvYfE=";
            openSha256 = "sha256-/tM3n9huz1MTE6KKtTCBglBMBGGL/GOHi5ZSUag4zXA=";
            settingsSha256 = "sha256-H7uEe34LdmUFcMcS6bz7sbpYhg9zPCb/5AmZZFTx1QA=";
            persistencedSha256 = "sha256-hdszsACWNqkCh8G4VBNitDT85gk9gJe1BlQ8LdrYIkg=";
            patchesOpen = [ drm_fop_flags_linux_612_patch ];
        };
    };

    environment.systemPackages = with pkgs; [
        nvtopPackages.full
        zenith-nvidia
    ];

 }
