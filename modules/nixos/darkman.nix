{
  config,
  lib,
  pkgs,
  vicinae,
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

    #---D-Bus------
    services.dbus.enable = true;

    #---GTK------
    programs.dconf.enable = true;

    #---Override darkman portal to work with Hyprland------
    environment.etc."xdg/xdg-desktop-portal/portals/darkman-hyprland.portal".text = ''
      [portal]
      DBusName=org.freedesktop.impl.portal.desktop.darkman
      Interfaces=org.freedesktop.impl.portal.Settings
      UseIn=hyprland
    '';

    home-manager.sharedModules = [
      {
        #---Config------
        xdg.configFile."darkman/config.yaml".text = ''
          ${optionalString (config.darkman.latitude != null) "lat: ${toString config.darkman.latitude}"}
          ${optionalString (config.darkman.longitude != null) "lng: ${toString config.darkman.longitude}"}
          usegeoclue: ${if config.darkman.useGeoclue then "true" else "false"}
          dbusserver: true
          portal: true
        '';

        #---Dark Mode Script------
        xdg.dataFile."dark-mode.d/00-pywal.sh" = {
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash

            #---GTK Settings------
            for dir in ~/.config/gtk-3.0 ~/.config/gtk-4.0; do
              if [ -f "$dir/settings.ini" ]; then
                ${pkgs.gnused}/bin/sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=true/' "$dir/settings.ini"
              fi
            done

            #---GNOME/Browser Theme------
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true

            #---D-Bus Notification------
            ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.portal.Desktop \
              --type=signal /org/freedesktop/portal/desktop \
              org.freedesktop.portal.Settings.SettingChanged \
              string:'org.freedesktop.appearance' string:'color-scheme' variant:uint32:1 2>/dev/null || true

            #---Pywal Colors------
            if [ -f ~/.cache/wal/dark-theme ]; then
              THEME=$(${pkgs.coreutils}/bin/cat ~/.cache/wal/dark-theme)
              ${pkgs.pywal}/bin/wal -n -q --theme "$THEME"
            else
              ${pkgs.pywal}/bin/wal -n -q --theme base16-gruvbox-hard
            fi

            #---Wallpaper------
            if [ -f ~/.cache/wal/dark-wallpaper ]; then
              WALLPAPER=$(${pkgs.coreutils}/bin/cat ~/.cache/wal/dark-wallpaper)
              if [ -f "$WALLPAPER" ]; then
                ${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type center --transition-step 10 --transition-fps 30
              fi
            fi

            #---Application Configs------
            ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css 2>/dev/null || true
            ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-mako ~/.config/mako/colors 2>/dev/null || true
            ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-wofi.css ~/.config/wofi/colors.css 2>/dev/null || true

            #---Vicinae Theme------
            vicinae-pywal-converter 2>/dev/null || true
            if [ -f ~/.config/vicinae/vicinae.json ]; then
              ${pkgs.jq}/bin/jq '.theme.name = "pywal-theme"' ~/.config/vicinae/vicinae.json > ~/.config/vicinae/vicinae.json.tmp
              ${pkgs.coreutils}/bin/mv ~/.config/vicinae/vicinae.json.tmp ~/.config/vicinae/vicinae.json
            fi

            #---Vicinae config updated------
            # Vicinae will pick up the new theme on next launch
            # (managed by systemd, no restart needed)

            #---Ghostty Theme------
            echo '# Managed by darkman - Dark mode' > ~/.config/ghostty/theme
            if [ -f ~/.cache/wal/dark-ghostty-theme ]; then
              echo "theme = $(${pkgs.coreutils}/bin/cat ~/.cache/wal/dark-ghostty-theme)" >> ~/.config/ghostty/theme
            else
              echo 'theme = Gruvbox Dark Hard' >> ~/.config/ghostty/theme
            fi

            #---Reload Services------
            if ${pkgs.procps}/bin/pgrep waybar >/dev/null; then
              ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true  # Try to reload config first
            fi
            ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true

            #---Notify Neovim instances------
            for socket in /run/user/1000/nvim.*.0; do
              if [ -S "$socket" ]; then
                ${pkgs.neovim}/bin/nvim --server "$socket" --remote-send ":lua vim.cmd.colorscheme('gruvbox'); vim.o.background='dark'<CR>" 2>/dev/null || true
              fi
            done
          '';
        };

        #---Light Mode Script------
        xdg.dataFile."light-mode.d/00-pywal.sh" = {
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash

            #---GTK Settings------
            for dir in ~/.config/gtk-3.0 ~/.config/gtk-4.0; do
              if [ -f "$dir/settings.ini" ]; then
                ${pkgs.gnused}/bin/sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=false/' "$dir/settings.ini"
              fi
            done

            #---Browser Theme------
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true

            #---D-Bus Notification------
            ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.portal.Desktop \
              --type=signal /org/freedesktop/portal/desktop \
              org.freedesktop.portal.Settings.SettingChanged \
              string:'org.freedesktop.appearance' string:'color-scheme' variant:uint32:2 2>/dev/null || true

            #---Pywal Colors------
            if [ -f ~/.cache/wal/light-theme ]; then
              THEME=$(${pkgs.coreutils}/bin/cat ~/.cache/wal/light-theme)
              ${pkgs.pywal}/bin/wal -n -l -q --theme "$THEME"
            else
              ${pkgs.pywal}/bin/wal -n -l -q --theme rose-pine-dawn
            fi

            #---Wallpaper------
            if [ -f ~/.cache/wal/light-wallpaper ]; then
              WALLPAPER=$(${pkgs.coreutils}/bin/cat ~/.cache/wal/light-wallpaper)
              if [ -f "$WALLPAPER" ]; then
                ${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type center --transition-step 10 --transition-fps 30
              fi
            fi

            #---Application Configs------
            ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css 2>/dev/null || true
            ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-mako ~/.config/mako/colors 2>/dev/null || true
            ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-wofi.css ~/.config/wofi/colors.css 2>/dev/null || true

            #---Vicinae Theme------
            vicinae-pywal-converter 2>/dev/null || true
            if [ -f ~/.config/vicinae/vicinae.json ]; then
              ${pkgs.jq}/bin/jq '.theme.name = "pywal-theme"' ~/.config/vicinae/vicinae.json > ~/.config/vicinae/vicinae.json.tmp
              ${pkgs.coreutils}/bin/mv ~/.config/vicinae/vicinae.json.tmp ~/.config/vicinae/vicinae.json
            fi

            #---Vicinae config updated------
            # Vicinae will pick up the new theme on next launch
            # (managed by systemd, no restart needed)

            #---Ghostty Theme------
            echo '# Managed by darkman - Light mode' > ~/.config/ghostty/theme
            if [ -f ~/.cache/wal/light-ghostty-theme ]; then
              echo "theme = $(${pkgs.coreutils}/bin/cat ~/.cache/wal/light-ghostty-theme)" >> ~/.config/ghostty/theme
            else
              echo 'theme = Rose Pine Dawn' >> ~/.config/ghostty/theme
            fi

            #---Reload Services------
            if ${pkgs.procps}/bin/pgrep waybar >/dev/null; then
              ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true  # Try to reload config first
            fi
            ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true

            #---Notify Neovim instances------
            for socket in /run/user/1000/nvim.*.0; do
              if [ -S "$socket" ]; then
                ${pkgs.neovim}/bin/nvim --server "$socket" --remote-send ":lua vim.cmd.colorscheme('rose-pine-dawn'); vim.o.background='light'<CR>" 2>/dev/null || true
              fi
            done
          '';
        };

        #---Systemd Service------
        systemd.user.services.darkman = {
          Unit = {
            Description = "Darkman - dark mode manager";
            # Start after graphical session and swww daemon
            After = [
              "graphical-session.target"
              "swww-daemon.service"
            ];
            PartOf = [ "graphical-session.target" ];
            Wants = [ "swww-daemon.service" ];
          };
          Service = {
            Type = "simple";
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
            ExecStart = "${pkgs.darkman}/bin/darkman run";
            Restart = "on-failure";
            RestartSec = 5;
            Environment = [
              "PATH=${
                lib.makeBinPath [
                  pkgs.swww
                  pkgs.procps
                  pkgs.coreutils
                  vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
                ]
              }:\${PATH}"
            ];
          };
          Install = {
            WantedBy = [ ];
          };
        };

        #---SWWW Daemon Service------
        systemd.user.services.swww-daemon = {
          Unit = {
            Description = "SWWW wallpaper daemon";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
            ExecStart = "${pkgs.swww}/bin/swww-daemon";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ ];
          };
        };

      }
    ];

    #---Helper Scripts------
    environment.systemPackages = with pkgs; [
      darkman
      (pkgs.writeShellScriptBin "wallpaper-set" ''

        if [ $# -lt 2 ]; then
          echo "Usage: wallpaper-set <dark|light> <image-path>"
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

        mkdir -p ~/.cache/wal

        echo "$IMAGE" > ~/.cache/wal/"$MODE"-wallpaper

        CURRENT_MODE=$(${pkgs.darkman}/bin/darkman get 2>/dev/null || echo "dark")
        if [ "$MODE" = "$CURRENT_MODE" ]; then
          ${pkgs.swww}/bin/swww img "$IMAGE" --transition-type center --transition-step 10 --transition-fps 30
        fi

        echo "$MODE mode wallpaper set to: $IMAGE"
      '')

      (pkgs.writeShellScriptBin "theme-set" ''

        if [ $# -lt 2 ]; then
          echo "Usage: theme-set <dark|light> <theme-name>"
          echo ""
          echo "Sets a pywal color theme for a specific mode"
          echo "Use 'wal --theme' to list available themes"
          exit 1
        fi

        MODE="$1"
        THEME="$2"

        mkdir -p ~/.cache/wal

        echo "$THEME" > ~/.cache/wal/"$MODE"-theme

        CURRENT_MODE=$(${pkgs.darkman}/bin/darkman get 2>/dev/null || echo "dark")
        if [ "$MODE" = "$CURRENT_MODE" ]; then
          if [ "$MODE" = "dark" ]; then
            ${pkgs.pywal}/bin/wal -n -q --theme "$THEME"
          else
            ${pkgs.pywal}/bin/wal -n -l -q --theme "$THEME"
          fi

          #---Copy Configs------
          ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css 2>/dev/null || true
          ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-mako ~/.config/mako/colors 2>/dev/null || true
          ${pkgs.coreutils}/bin/cp ~/.cache/wal/colors-wofi.css ~/.config/wofi/colors.css 2>/dev/null || true

          #---Generate Theme------
          vicinae-pywal-converter 2>/dev/null || true
          #---Update Vicinae------
          if [ -f ~/.config/vicinae/vicinae.json ]; then
            ${pkgs.jq}/bin/jq '.theme.name = "pywal-theme"' ~/.config/vicinae/vicinae.json > ~/.config/vicinae/vicinae.json.tmp
            ${pkgs.coreutils}/bin/mv ~/.config/vicinae/vicinae.json.tmp ~/.config/vicinae/vicinae.json
          fi

          #---Vicinae config updated------
          # Vicinae will pick up the new theme on next launch
          # (managed by systemd, no restart needed)

          #---Reload Services------
          ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
          ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
        fi

        echo "$MODE mode theme set to: $THEME"
      '')

      (pkgs.writeShellScriptBin "theme-toggle" ''
        ${pkgs.darkman}/bin/darkman toggle
      '')

      (pkgs.writeShellScriptBin "theme-status" ''
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

        mkdir -p ~/.cache/wal

        echo "$THEME" > ~/.cache/wal/"$MODE"-ghostty-theme

        CURRENT_MODE=$(${pkgs.darkman}/bin/darkman get 2>/dev/null || echo "dark")
        if [ "$MODE" = "$CURRENT_MODE" ]; then
          echo "# Managed by darkman - $MODE mode" > ~/.config/ghostty/theme
          echo "theme = $THEME" >> ~/.config/ghostty/theme
        fi

        echo "Ghostty $MODE mode theme set to: $THEME"
      '')
    ];
  };
}
