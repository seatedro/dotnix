{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.darkman = {
    enable = mkEnableOption "darkman dark/light mode switching daemon";

    latitude = mkOption {
      type = types.nullOr types.float;
      default = 37.7749; # San Francisco
      description = "Latitude for sunrise/sunset calculation";
    };

    longitude = mkOption {
      type = types.nullOr types.float;
      default = -122.4194; # San Francisco
      description = "Longitude for sunrise/sunset calculation";
    };

    useGeoclue = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use geoclue for automatic location detection";
    };
  };

  config = mkIf config.darkman.enable {
    services.geoclue2.enable = mkIf config.darkman.useGeoclue true;

    services.dbus.enable = true;
    programs.dconf.enable = true;

    home-manager.sharedModules = [
      {
        xdg.configFile."darkman/config.yaml".text = ''
          ${optionalString (config.darkman.latitude != null) "lat: ${toString config.darkman.latitude}"}
          ${optionalString (config.darkman.longitude != null) "lng: ${toString config.darkman.longitude}"}
          usegeoclue: ${if config.darkman.useGeoclue then "true" else "false"}
          dbusserver: true
          portal: true
        '';

        xdg.dataFile."dark-mode.d/00-pywal.sh" = {
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash


            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true

            ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.portal.Desktop \
              --type=signal /org/freedesktop/portal/desktop \
              org.freedesktop.portal.Settings.SettingChanged \
              string:'org.freedesktop.appearance' string:'color-scheme' variant:uint32:1 2>/dev/null || true

            if [ -f ~/.cache/wal/dark-wallpaper ]; then
              WALLPAPER=$(cat ~/.cache/wal/dark-wallpaper)
              if [ -f "$WALLPAPER" ]; then
                ${pkgs.pywal}/bin/wal -q -i "$WALLPAPER"
                ${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type center --transition-step 10 --transition-fps 30
              fi
            else
              ${pkgs.pywal}/bin/wal -q --theme base16-gruvbox-dark-hard
            fi

            cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css 2>/dev/null || true
            cp ~/.cache/wal/colors-mako ~/.config/mako/colors 2>/dev/null || true
            cp ~/.cache/wal/colors-vicinae.toml ~/.config/vicinae/colors.toml 2>/dev/null || true

            # Update Ghostty theme
            echo '# Managed by darkman - Dark mode' > ~/.config/ghostty/theme
            if [ -f ~/.cache/wal/dark-ghostty-theme ]; then
              echo "theme = \"$(cat ~/.cache/wal/dark-ghostty-theme)\"" >> ~/.config/ghostty/theme
            else
              echo 'theme = "GruvboxDarkHard"' >> ~/.config/ghostty/theme
            fi

            # Reload applications
            # Only restart waybar if it's running and colors actually changed
            if pgrep waybar >/dev/null; then
              pkill -SIGUSR2 waybar 2>/dev/null || true  # Try to reload config first
            fi
            ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
          '';
        };

        xdg.dataFile."light-mode.d/00-pywal.sh" = {
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash

            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true

            ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.portal.Desktop \
              --type=signal /org/freedesktop/portal/desktop \
              org.freedesktop.portal.Settings.SettingChanged \
              string:'org.freedesktop.appearance' string:'color-scheme' variant:uint32:2 2>/dev/null || true

            if [ -f ~/.cache/wal/light-wallpaper ]; then
              WALLPAPER=$(cat ~/.cache/wal/light-wallpaper)
              if [ -f "$WALLPAPER" ]; then
                ${pkgs.pywal}/bin/wal -l -q -i "$WALLPAPER"
                ${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type center --transition-step 10 --transition-fps 30
              fi
            else
              # Fallback to a light preset theme
              ${pkgs.pywal}/bin/wal -l -q --theme base16-gruvbox-light-soft
            fi

            cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css 2>/dev/null || true
            cp ~/.cache/wal/colors-mako ~/.config/mako/colors 2>/dev/null || true
            cp ~/.cache/wal/colors-vicinae.toml ~/.config/vicinae/colors.toml 2>/dev/null || true

            # Update Ghostty theme
            echo '# Managed by darkman - Light mode' > ~/.config/ghostty/theme
            if [ -f ~/.cache/wal/light-ghostty-theme ]; then
              echo "theme = \"$(cat ~/.cache/wal/light-ghostty-theme)\"" >> ~/.config/ghostty/theme
            else
              echo 'theme = "rose-pine-dawn"' >> ~/.config/ghostty/theme
            fi

            # Only restart waybar if it's running and colors actually changed
            if pgrep waybar >/dev/null; then
              pkill -SIGUSR2 waybar 2>/dev/null || true  # Try to reload config first
            fi
            ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
          '';
        };

        systemd.user.services.darkman = {
          Unit = {
            Description = "Darkman - dark mode manager";
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.darkman}/bin/darkman run";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      }
    ];

    environment.systemPackages = with pkgs; [
      darkman
      (pkgs.writeShellScriptBin "wal-set-mode" ''

        if [ $# -lt 2 ]; then
          echo "Usage: wal-set-mode <dark|light> <image-path>"
          echo ""
          echo "Sets a wallpaper for a specific mode that darkman will use"
          exit 1
        fi

        MODE="$1"
        IMAGE="$2"

        if [ ! -f "$IMAGE" ]; then
          echo "Error: File not found: $IMAGE"
          exit 1
        fi

        # Ensure wal cache directory exists
        mkdir -p ~/.cache/wal

        # Save the wallpaper path for the mode
        echo "$IMAGE" > ~/.cache/wal/"$MODE"-wallpaper

        # If this is the current mode, apply it immediately
        CURRENT_MODE=$(${pkgs.darkman}/bin/darkman get 2>/dev/null || echo "dark")
        if [ "$MODE" = "$CURRENT_MODE" ]; then
          if [ "$MODE" = "dark" ]; then
            ${pkgs.pywal}/bin/wal -q -i "$IMAGE"
          else
            ${pkgs.pywal}/bin/wal -l -q -i "$IMAGE"
          fi
          ${pkgs.swww}/bin/swww img "$IMAGE" --transition-type center --transition-step 10 --transition-fps 30

          # Copy generated configs
          cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css 2>/dev/null || true
          cp ~/.cache/wal/colors-mako ~/.config/mako/colors 2>/dev/null || true
          cp ~/.cache/wal/colors-vicinae.toml ~/.config/vicinae/colors.toml 2>/dev/null || true

          # Reload applications
          pkill waybar 2>/dev/null || true
          sleep 0.5
          waybar & disown
          ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
        fi

        echo "$MODE mode wallpaper set to: $IMAGE"
      '')

      (pkgs.writeShellScriptBin "theme-toggle" ''
        # Toggle between dark and light mode
        ${pkgs.darkman}/bin/darkman toggle
      '')

      (pkgs.writeShellScriptBin "theme-status" ''
        # Show current theme mode
        MODE=$(${pkgs.darkman}/bin/darkman get 2>/dev/null || echo "unknown")
        echo "Current mode: $MODE"

        if [ -f ~/.cache/wal/"$MODE"-wallpaper ]; then
          echo "Wallpaper: $(cat ~/.cache/wal/"$MODE"-wallpaper)"
        fi

        if [ -f ~/.cache/wal/"$MODE"-ghostty-theme ]; then
          echo "Ghostty theme: $(cat ~/.cache/wal/"$MODE"-ghostty-theme)"
        fi
      '')

      (pkgs.writeShellScriptBin "theme-set-ghostty" ''
        # Set Ghostty theme for a specific mode

        if [ $# -lt 2 ]; then
          echo "Usage: theme-set-ghostty <dark|light> <theme-name>"
          echo ""
          echo "Example Ghostty themes:"
          echo "  Dark:  GruvboxDark, TokyoNight, Dracula, OneDark"
          echo "  Light: GruvboxLight, Solarized Light, GitHub Light"
          exit 1
        fi

        MODE="$1"
        THEME="$2"

        # Ensure wal cache directory exists
        mkdir -p ~/.cache/wal

        # Save the theme for the mode
        echo "$THEME" > ~/.cache/wal/"$MODE"-ghostty-theme

        # If this is the current mode, apply it immediately
        CURRENT_MODE=$(${pkgs.darkman}/bin/darkman get 2>/dev/null || echo "dark")
        if [ "$MODE" = "$CURRENT_MODE" ]; then
          echo "# Managed by darkman - $MODE mode" > ~/.config/ghostty/theme
          echo "theme = \"$THEME\"" >> ~/.config/ghostty/theme
        fi

        echo "Ghostty $MODE mode theme set to: $THEME"
      '')
    ];
  };
}
