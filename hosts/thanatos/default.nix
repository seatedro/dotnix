lib:
lib.nixosSystem' (
  {
    lib,
    pkgs,
    config,
    ...
  }:
  let
    inherit (lib) collectNix remove mkDefault;
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

    wayland-desktop.enable = true;

    services.protonvpn = {
      enable = true;
      interface = {
        privateKeyFile = "/root/secrets/protonvpn-private-key";
        ip = "10.2.0.2/32";
        dns.ip = "10.2.0.1";
      };
      endpoint = {
        publicKey = "2xvxhMK0AalXOMq6Dh0QMVJ0Cl3WQTmWT5tdeb8SpR0=";
        ip = "79.127.185.166";
      };
    };

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        extraEntries = ''
          menuentry "Windows" {
            chainloader (hd1)+1
          }
        '';
      };
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

    hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/91e42d49-54b3-48a0-bd56-37cf1b9a72c3";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/1C91-CBB0";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/11bd10e3-c4a2-41b7-8695-b71d16b7ed1f"; }
    ];

    #boot.loader.systemd-boot.consoleMode = "0";

    system.stateVersion = "25.11";
    home-manager.sharedModules = [
      {
        home.stateVersion = "25.11";
      }
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
  }
)
