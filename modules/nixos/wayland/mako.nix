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
          
          # Gruvbox dark theme configuration
          backgroundColor = "#1d2021";
          textColor = "#ebdbb2";
          borderColor = "#458588";
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
            border-color=#689d6a
            
            [urgency=normal]
            border-color=#d79921
            
            [urgency=high]
            border-color=#fb4934
            background-color=#3c1f1e
          '';
        };
      }
    ];
  };
} 