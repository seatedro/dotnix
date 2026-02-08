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
      shell = pkgs.zsh;
      hashedPassword = "$6$9JrLHgKEaJieS/Gn$aUDwvLENKq17IglfQN9tAqqRCVTQQEs43LUZTARt13BDC5tdEjCDb.rS2O6Bf8u/8HdHqdjOQfgbqO0.0vvJa1";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "input"
        "docker"
      ];
      uid = 1000;
    };

    home-manager.users.rohit = {
      xdg.configFile."hypr/monitors.conf" = {
        text = ''
          env = GDK_SCALE,1.25
          monitor = eDP-1, 2880x1920@120.00, auto, 1.5
          monitor = desc:Dell Inc. DELL S3425DW, 3440x1440@120.00, auto-up, 1

          # Lid switch: disable laptop screen when closed, re-enable when opened
          bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor "eDP-1, disable"
          bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1, 2880x1920@120.00, auto, 1.5"
        '';
        force = true;
      };
    };

    services.logind = {
      lidSwitch = "ignore";
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
    };

    networking.hostName = "forge";

    virtualisation.docker.enable = true;

    wayland-desktop.enable = true;
    kuro.enable = true;

    age.secrets.vanta-agent-key = {
      file = ../../secrets/vanta-agent-key.age;
      mode = "0400";
    };

    services.vanta = {
      enable = true;
      agentKeyFile = config.age.secrets.vanta-agent-key.path;
      ownerEmail = "rohit@exa.ai";
      region = "us";
    };

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

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/bf0b1979-b529-4fe6-a9f5-00b9a765554e";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/A558-1735";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/ae230551-7e22-4f72-8d35-460a29b2fde3"; }
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
