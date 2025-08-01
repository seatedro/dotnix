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
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Essential wayland packages
    environment.systemPackages = with pkgs; [
      # Core wayland tools
      hyprland
      hypridle
      hyprlock
      hyprpicker
      hyprshot

      # Wayland utilities
      wl-clipboard
      wl-clip-persist
      grim
      slurp
      swaybg

      # Audio and brightness control
      wireplumber
      brightnessctl
      playerctl

      # System utilities
      polkit_gnome

    ];

    # Enable sound with PipeWire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Home Manager configuration
    home-manager.sharedModules = [
      {
        # Hyprland config files
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
        xdg.configFile."hypr/hypridle.conf" = {
          source = lib.configFile "hypr/hypridle.conf";
        };
        xdg.configFile."hypr/hyprlock.conf" = {
          source = lib.configFile "hypr/hyprlock.conf";
        };

        xdg.configFile."wallpaper.png" = {
          source = ../../../wallpapers/3840x2160-dark-lines.png;
        };
      }
    ];
  };
}
