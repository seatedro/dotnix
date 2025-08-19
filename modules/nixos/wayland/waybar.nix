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
          systemd.enable = true;
        };
      }
    ];
  };
} 