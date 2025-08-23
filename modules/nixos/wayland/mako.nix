{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.mako = {
    enable = mkEnableOption "Mako notification daemon";
  };

  config = mkIf config.mako.enable {
    # Install mako and libnotify
    environment.systemPackages = with pkgs; [
      mako
      libnotify
    ];

    # Home Manager configuration
    home-manager.sharedModules = [
      {
        # Enable mako service
        services.mako = {
          enable = true;
          
          # Kanagawa theme configuration
          backgroundColor = "#181616";
          textColor = "#c5c9c5";
          borderColor = "#8ba4b0";
          borderRadius = 8;
          borderSize = 2;
          
          width = 400;
          height = 150;
          margin = "10";
          padding = "15";
          
          font = "JetBrainsMono Nerd Font 12";
          
          # Position
          anchor = "top-right";
          
          # Timeout
          defaultTimeout = 5000;
          
          # Icons
          iconPath = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
          maxIconSize = 48;
          
          # Grouping
          groupBy = "summary";
          
          # Extra config
          extraConfig = ''
            [urgency=low]
            border-color=#87a987
            
            [urgency=normal]
            border-color=#e6c384
            
            [urgency=high]
            border-color=#e46876
            background-color=#2d4f67
          '';
        };
      }
    ];
  };
} 