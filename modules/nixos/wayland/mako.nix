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
    #---Packages------
    environment.systemPackages = with pkgs; [
      mako
      libnotify
    ];

    #---Home Manager------
    home-manager.sharedModules = [
      {
        #---Service------
        services.mako = {
          enable = true;

          settings = {
            #---Kanagawa------
            background-color = "#181616";
            text-color = "#c5c9c5";
            border-color = "#8ba4b0";
            border-radius = 8;
            border-size = 2;

            width = 400;
            height = 150;
            margin = "10";
            padding = "15";

            font = "JetBrainsMono Nerd Font 12";

            #---Position------
            anchor = "top-right";

            #---Timeout------
            default-timeout = 5000;

            #---Icons------
            icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
            max-icon-size = 48;

            #---Grouping------
            group-by = "summary";

            #---Markup------
            markup = true;
          };

          #---Extra------
          extraConfig = ''
            include=~/.config/mako/colors

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
