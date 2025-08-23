{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.theme = {
    name = mkOption {
      type = types.enum [
        "gruvbox"
        "catppuccin"
        "nord"
        "tokyo-night"
        "kanagawa"
      ];
      default = "kanagawa";
      description = "Theme to use for the desktop environment";
    };
  };

  config = {
    home-manager.sharedModules = [
      {
        xdg.configFile."themes/gruvbox/waybar.css" = {
          source = lib.configFile "themes/gruvbox/waybar.css";
        };
        xdg.configFile."themes/gruvbox/hyprland.conf" = {
          source = lib.configFile "themes/gruvbox/hyprland.conf";
        };
        xdg.configFile."themes/gruvbox/hyprlock.conf" = {
          source = lib.configFile "themes/gruvbox/hyprlock.conf";
        };
        xdg.configFile."themes/gruvbox/wofi.css" = {
          source = lib.configFile "themes/gruvbox/wofi.css";
        };

        xdg.configFile."themes/catppuccin/waybar.css" = {
          source = lib.configFile "themes/catppuccin/waybar.css";
        };
        xdg.configFile."themes/catppuccin/hyprland.conf" = {
          source = lib.configFile "themes/catppuccin/hyprland.conf";
        };
        xdg.configFile."themes/catppuccin/hyprlock.conf" = {
          source = lib.configFile "themes/catppuccin/hyprlock.conf";
        };
        xdg.configFile."themes/catppuccin/wofi.css" = {
          source = lib.configFile "themes/catppuccin/wofi.css";
        };

        xdg.configFile."themes/kanagawa/waybar.css" = {
          source = lib.configFile "themes/kanagawa/waybar.css";
        };
        xdg.configFile."themes/kanagawa/hyprland.conf" = {
          source = lib.configFile "themes/kanagawa/hyprland.conf";
        };
        xdg.configFile."themes/kanagawa/hyprlock.conf" = {
          source = lib.configFile "themes/kanagawa/hyprlock.conf";
        };
        xdg.configFile."themes/kanagawa/wofi.css" = {
          source = lib.configFile "themes/kanagawa/wofi.css";
        };

        xdg.configFile."current-theme" = {
          source = lib.configFile "themes/${config.theme.name}";
        };

        xdg.configFile."waybar/theme.css" = {
          source = lib.configFile "themes/${config.theme.name}/waybar.css";
        };
        xdg.configFile."hypr/theme.conf" = {
          source = lib.configFile "themes/${config.theme.name}/hyprland.conf";
        };
        xdg.configFile."hypr/theme-hyprlock.conf" = {
          source = lib.configFile "themes/${config.theme.name}/hyprlock.conf";
        };
        xdg.configFile."wofi/theme.css" = {
          source = lib.configFile "themes/${config.theme.name}/wofi.css";
        };
      }
    ];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "switch-theme" ''
        #!/bin/bash
        THEME=$1
        if [ -z "$THEME" ]; then
          echo "Available themes: gruvbox catppuccin nord tokyo-night kanagawa"
          echo "Usage: switch-theme <theme-name>"
          exit 1
        fi

        THEME_DIR="$HOME/.config/themes/$THEME"
        if [ ! -d "$THEME_DIR" ]; then
          echo "Theme '$THEME' not found!"
          exit 1
        fi

        ln -sf "$THEME_DIR" "$HOME/.config/current-theme"
        ln -sf "$THEME_DIR/waybar.css" "$HOME/.config/waybar/theme.css"
        ln -sf "$THEME_DIR/hyprland.conf" "$HOME/.config/hypr/theme.conf"
        ln -sf "$THEME_DIR/hyprlock.conf" "$HOME/.config/hypr/theme-hyprlock.conf"
        ln -sf "$THEME_DIR/wofi.css" "$HOME/.config/wofi/theme.css"

        pkill -SIGUSR1 waybar

        echo "Switched to $THEME theme"
      '')
    ];
  };
}
