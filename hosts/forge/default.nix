lib:
lib.nixosSystem' (
  {
    lib,
    pkgs,
    config,
    nixos-hardware,
    ...
  }:
  let
    inherit (lib) collectNix remove mkDefault;
  in
  {
    imports = (collectNix ./. |> remove ./default.nix) ++ [
      nixos-hardware.nixosModules.framework-amd-ai-300-series
    ];

    users.users.rohit = {
      isNormalUser = true;
      home = "/home/rohit";
      shell = pkgs.nushell;
      hashedPassword = "$6$9JrLHgKEaJieS/Gn$aUDwvLENKq17IglfQN9tAqqRCVTQQEs43LUZTARt13BDC5tdEjCDb.rS2O6Bf8u/8HdHqdjOQfgbqO0.0vvJa1";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
      ];
      uid = 1000;
    };

    home-manager.users.rohit = { };

    networking.hostName = "forge";

    wayland-desktop.enable = true;
    kuro.enable = true;

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    hardware.graphics.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

    # TODO: replace these UUIDs after installing NixOS via the graphical installer
    # run `lsblk -f` or check /etc/nixos/hardware-configuration.nix on the new machine
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/CHANGE-ME";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/CHANGE-ME";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/CHANGE-ME"; }
    ];

    system.stateVersion = "25.11";
    home-manager.sharedModules = [
      {
        home.stateVersion = "25.11";
      }
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
  }
)
