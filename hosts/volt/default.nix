lib:
lib.nixosSystem' (
  { lib, pkgs, ... }:
  let
    inherit (lib) collectNix remove;
  in
  {
    imports = collectNix ./. |> remove ./default.nix;

    disabledModules = [ "virtualisation/vmware-guest.nix" ];

    users.users.ro = {
      isNormalUser = true;
      home = "/home/ro";
      shell = pkgs.nushell;
      hashedPassword = "$6$9JrLHgKEaJieS/Gn$aUDwvLENKq17IglfQN9tAqqRCVTQQEs43LUZTARt13BDC5tdEjCDb.rS2O6Bf8u/8HdHqdjOQfgbqO0.0vvJa1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILosTv7oLEvrh4JvIBOYxwXYCqlWnu/o/dz7KdUtt9ah ro"
      ];
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
      ];
      uid = 1000;
    };

    home-manager.users.ro = { };

    networking.hostName = "volt";

    # Enable bspwm desktop environment
    desktop.enable = true;

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

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    virtualisation.vmware.guest = {
      enable = true;
      headless = false;
    };

    hardware.graphics = {
      enable = true;
    };

    boot.loader.systemd-boot.consoleMode = "0";

    system.stateVersion = "25.11";
    home-manager.sharedModules = [
      {
        home.stateVersion = "25.11";
      }
    ];
    nixpkgs.hostPlatform = "aarch64-linux";
  }
)
