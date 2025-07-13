lib:
lib.nixosSystem' (
  { lib, pkgs, ... }:
  let
    inherit (lib) collectNix remove;
  in
  {
    imports = collectNix ./. |> remove ./default.nix;

    users.users.ro = {
      isNormalUser = true;
      home = "/home/ro";
      shell = pkgs.nushell;
      hashedPassword = "$6$9JrLHgKEaJieS/Gn$aUDwvLENKq17IglfQN9tAqqRCVTQQEs43LUZTARt13BDC5tdEjCDb.rS2O6Bf8u/8HdHqdjOQfgbqO0.0vvJa1";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "docker"
      ];
      uid = 1000;
    };

    home-manager.users.ro = { };

    networking.hostName = "thanatos";

    # Enable wayland desktop environment
    wayland-desktop.enable = true;

    boot.initrd.availableKernelModules = [
      "ata_piix"
      "ohci_pci"
      "ehci_pci"
      "ahci"
      "sd_mod"
      "sr_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];
    boot.loader = {
        efi.canTouchEfiVariables = true;
        grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        };
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    hardware.graphics = {
      enable = true;
    };

    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    boot.loader.systemd-boot.consoleMode = "0";

    system.stateVersion = "25.11";
    home-manager.sharedModules = [
      {
        home.stateVersion = "25.11";
      }
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
  }
) 