{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.waybar = {
    enable = mkEnableOption "Waybar status bar";
  };

  config = mkIf config.waybar.enable {
    environment.systemPackages = with pkgs; [
      waybar
    ];

    home-manager.sharedModules = [
      {
        xdg.configFile."waybar/config" = {
          source = lib.configFile "waybar/config";
        };
        xdg.configFile."waybar/style.css" = {
          source = lib.configFile "waybar/style.css";
        };

        programs.waybar = {
          enable = true;
          systemd = {
            enable = false;
          };
        };

        systemd.user.services.waybar = {
          Unit = {
            Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
            Documentation = "https://github.com/Alexays/Waybar/wiki";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.waybar}/bin/waybar";
            ExecReload = "${pkgs.procps}/bin/kill -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            RestartSec = 1;
          };
          Install = {
            WantedBy = [ ];
          };
        };
      }
    ];
  };
}
