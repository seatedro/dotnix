{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.hyprland = {
    enable = mkEnableOption "Hyprland wayland compositor";
  };

  config = mkIf config.hyprland.enable {
    #---Hyprland------
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    #---Packages------
    environment.systemPackages = with pkgs; [
      #---Core------
      hyprland
      hyprpicker
      hyprshot

      #---Utils------
      wl-clipboard
      wl-clip-persist
      grim
      slurp
      swaybg

      #---Controls------
      wireplumber
      brightnessctl
      playerctl

      #---System------
      hyprpolkitagent
    ];

    #---PipeWire------
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    #---Bluetooth------
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    #---Home Manager------
    home-manager.sharedModules = [
      {
        #---Polkit Agent------
        systemd.user.services.hyprpolkitagent = {
          Unit = {
            Description = "Hyprland Polkit Authentication Agent";
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        #---Config Files------
        xdg.configFile."hypr/hyprland.conf" = {
          source = lib.configFile "hypr/hyprland.conf";
        };
        xdg.configFile."hypr/monitors.conf" = {
          source = lib.configFile "hypr/monitors.conf";
        };
        xdg.configFile."hypr/autostart.conf" = {
          source = lib.configFile "hypr/autostart.conf";
        };
        xdg.configFile."hypr/bindings.conf" = {
          source = lib.configFile "hypr/bindings.conf";
        };
        xdg.configFile."hypr/envs.conf" = {
          source = lib.configFile "hypr/envs.conf";
        };
        xdg.configFile."hypr/looknfeel.conf" = {
          source = lib.configFile "hypr/looknfeel.conf";
        };
        xdg.configFile."hypr/input.conf" = {
          source = lib.configFile "hypr/input.conf";
        };
        xdg.configFile."hypr/windows.conf" = {
          source = lib.configFile "hypr/windows.conf";
        };
        xdg.configFile."wallpaper.png" = {
          source = ../../../wallpapers/3840x2160-dark-lines.png;
        };
      }
    ];
  };
}
