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
    hyprLidClose = pkgs.writeShellApplication {
      name = "hypr-lid-close";
      runtimeInputs = [
        pkgs.hyprland
        pkgs.jq
      ];
      text = ''
        external_monitor="$(hyprctl monitors -j | jq -r 'first(.[] | select(.name != "eDP-1") | .name) // empty')"

        if [[ -z "$external_monitor" ]]; then
          exit 0
        fi

        while IFS= read -r workspace; do
          hyprctl dispatch moveworkspacetomonitor "$workspace $external_monitor"
        done < <(hyprctl workspaces -j | jq -r '.[] | select(.monitor == "eDP-1") | .name')

        hyprctl dispatch focusmonitor "$external_monitor"
        hyprctl keyword monitor "eDP-1, disable"
      '';
    };
    hyprLidOpen = pkgs.writeShellApplication {
      name = "hypr-lid-open";
      runtimeInputs = [ pkgs.hyprland ];
      text = ''
        if [[ -f "$HOME/.config/hypr/dms/outputs.conf" ]]; then
          hyprctl keyword source "$HOME/.config/hypr/dms/outputs.conf"
        else
          hyprctl keyword monitor "eDP-1, 2880x1920@120.00, auto, 1.5"
        fi
      '';
    };
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
      xdg.configFile."Deskflow/Deskflow.conf" = {
        force = true;
        text = ''
          [core]
          coreMode=1
          lastVersion=1.25.0.0
          port=24800
          screenName=forge
          startedBefore=true

          [client]
          remoteHost=macbook

          [security]
          checkPeerFingerprints=false
          tlsEnabled=false

          [log]
          level=6

          [gui]
          enableUpdateCheck=false
          logExpanded=true
        '';
      };

    };

    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };

    networking.hostName = "forge";

    services.fprintd.enable = true;
    security.pam.services.greetd.fprintAuth = false;

    virtualisation.docker.enable = true;

    programs.nix-index-database.comma.enable = true;
    programs.mosh = {
      enable = true;
      openFirewall = true;
    };

    environment.systemPackages = [
      pkgs.deskflow
    ];

    systemd.user.services.deskflow = {
      description = "Deskflow Client";
      bindsTo = [ "graphical-session.target" ];
      wants = [
        "graphical-session-pre.target"
      ];
      after = [
        "graphical-session-pre.target"
      ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Environment = [ "XDG_SESSION_TYPE=x11" ];
        ExecStart = "${pkgs.deskflow}/bin/deskflow-core client -s /home/rohit/.config/Deskflow/Deskflow.conf";
        Restart = "always";
        RestartSec = 5;
      };
    };

    systemd.tmpfiles.rules = [
      "d /usr/share 0755 root root -"
      "d /usr/share/X11 0755 root root -"
      "L+ /usr/share/X11/xkb - - - - ${pkgs.xkeyboard_config}/share/X11/xkb"
    ];

    wayland-desktop.enable = true;
    hyprland = {
      enable = true;
      extraConfig = ''
        animations {
          enabled = false
        }

        bindl = , switch:on:Lid Switch, exec, ${lib.getExe hyprLidClose}
        bindl = , switch:off:Lid Switch, exec, ${lib.getExe hyprLidOpen}
      '';
    };
    niri.enable = true;
    dms.enable = true;
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
    boot.kernelPackages = pkgs.linuxPackages_latest;
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
