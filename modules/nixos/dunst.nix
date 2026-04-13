{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = {
    environment.systemPackages = with pkgs; [
      libnotify
    ];

    home-manager.sharedModules = [
      {
        services.dunst = {
          enable = true;
          iconTheme = {
            package = pkgs.papirus-icon-theme;
            name = "Luna-Dark";
            size = "16x16";
          };

          settings = {
            global = {
              monitor = 0;
              follow = "none";

              width = 400;
              height = 300;

              origin = "top-right";
              offset = "6x33";

              indicate_hidden = "yes";

              shrink = "no";

              transparency = 0;
              notification_height = 120;

              separator_height = 0;

              padding = 20;
              horizontal_padding = 10;

              frame_width = 2;
              frame_color = "#3c3836"; # gruvbox-bg1
              corner_radius = 8;
              separator_color = "frame";

              sort = "yes";
              idle_threshold = 120;

              font = "JetBrainsMono Nerd Font Medium 14";
              line_height = 0;

              markup = "full";
              format = "<b>%s</b>\\n%b";

              alignment = "left";
              vertical_alignment = "center";

              show_age_threshold = 60;

              word_wrap = "yes";
              ellipsize = "middle";
              ignore_newline = "yes";

              stack_duplicates = true;
              hide_duplicate_count = false;
              show_indicators = "yes";

              icon_position = "left";
              max_icon_size = 72;

              sticky_history = "yes";
              history_length = 20;

              always_run_script = true;

              title = "Dunst";
              class = "Dunst";

              startup_notification = false;
              verbosity = "mesg";
              force_xinerama = false;

              mouse_left_click = "close_current";
              mouse_middle_click = "do_action";
              mouse_right_click = "close_all";
            };

            urgency_low = {
              background = "#1d2021"; # gruvbox-bg0-hard
              foreground = "#ebdbb2"; # gruvbox-fg1
              frame_color = "#689d6a"; # gruvbox-aqua
              timeout = 5;
            };

            urgency_normal = {
              background = "#1d2021"; # gruvbox-bg0-hard
              foreground = "#ebdbb2"; # gruvbox-fg1
              frame_color = "#d79921"; # gruvbox-yellow
              timeout = 8;
            };

            urgency_critical = {
              background = "#1d2021"; # gruvbox-bg0-hard
              foreground = "#ebdbb2"; # gruvbox-fg1
              frame_color = "#fb4934"; # gruvbox-red-light
              timeout = 0;
            };
          };
        };
      }
    ];
  };
}
