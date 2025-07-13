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
    # Install waybar
    environment.systemPackages = with pkgs; [
      waybar
    ];

    # Home Manager configuration
    home-manager.sharedModules = [
      {
        # Waybar config files
        xdg.configFile."waybar/config" = {
          source = lib.configFile "waybar/config";
        };
        xdg.configFile."waybar/style.css" = {
          source = lib.configFile "waybar/style.css";
        };

        # Enable waybar service
        programs.waybar = {
          enable = true;
          systemd.enable = true;
        };
      }
    ];
  };
} 