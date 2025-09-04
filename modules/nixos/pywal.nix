{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.pywal = {
    enable = mkEnableOption "pywal color scheme generator";
  };

  config = mkIf config.pywal.enable {
    environment.systemPackages = with pkgs; [
      pywal
      imagemagick # For image processing
      swww # For wallpaper setting
    ];

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          pywal
        ];

        # Create pywal template directory
        xdg.configFile."wal/templates/".source = lib.configFile "wal/templates";

        systemd.user.timers.theme-sunset = {
          Unit = {
            Description = "Auto theme switching timer";
          };
          Timer = {
            OnCalendar = "*-*-* 06:00,18:00";
            Persistent = true;
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };

        systemd.user.services.theme-sunset = {
          Unit = {
            Description = "Auto theme switching service";
          };
          Service = {
            Type = "oneshot";
            Environment = [
              "XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
            ];
            ExecStart = pkgs.writeShellScript "theme-sunset" ''
              export GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas
              HOUR=$(${pkgs.coreutils}/bin/date +%H)
              if [ $HOUR -ge 18 ] || [ $HOUR -le 5 ]; then
                ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
              else
                ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
              fi
            '';
          };
        };
      }
    ];
  };
}

