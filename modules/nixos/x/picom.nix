{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.picom = {
    enable = mkEnableOption "Picom compositor";
  };

  config = mkIf config.picom.enable {
    home-manager.sharedModules = [
      {
        services.picom = {
          enable = true;
          settings = {
            # Transitions
            transition-length = 300;
            transition-pow-x = 0.1;
            transition-pow-y = 0.1;
            transition-pow-w = 0.1;
            transition-pow-h = 0.1;
            size-transition = true;

            # Corner radius - increased for gruvbox aesthetic
            corner-radius = 8.0;
            rounded-corners-exclude = [
              "class_g = 'awesome'"
              "class_g = 'URxvt'"
              "class_g = 'ghostty'"
              "class_g ?= 'ghostty'"
              "name = 'ghostty'"
              "class_g = 'XTerm'"
              "class_g = 'Polybar'"
              "class_g = 'code-oss'"
              "class_g = 'rofi'"
              "_GTK_FRAME_EXTENTS@:c"
            ];
            round-borders = 8.0;
            round-borders-exclude = [
              "class_g = 'Polybar'"
            ];

            # Shadow - adjusted for gruvbox dark hard
            shadow = true;
            shadow-radius = 15;
            shadow-opacity = 0.6;
            shadow-offset-x = -12;
            shadow-offset-y = -12;
            shadow-color = "#1d2021"; # gruvbox-bg0-hard for shadow
            shadow-exclude = [
              "name = 'Notification'"
              "class_g = 'Conky'"
              "class_g ?= 'Notify-osd'"
              "class_g = 'Cairo-clock'"
              "class_g = 'slop'"
              "class_g = 'ghostty'"
              "class_g = 'Polybar'"
              "_GTK_FRAME_EXTENTS@:c"
              "class_g = 'dunst'"
              "class_g = 'rofi'"
            ];

            # Fading
            fading = true;
            fade-in-step = 0.03;
            fade-out-step = 0.03;
            fade-delta = 8;
            fade-exclude = [
              "class_g = 'slop'"
              "class_g = 'rofi'"
            ];

            # Opacity - adjusted for gruvbox theme
            inactive-opacity = 0.95;
            active-opacity = 1.0;
            popup_menu = {
              opacity = 0.9;
            };
            dropdown_menu = {
              opacity = 0.9;
            };

            focus-exclude = [
              "class_g = 'Cairo-clock'"
              "class_g = 'Bar'"
              "class_g = 'slop'"
              "class_g = 'ghostty'"
              "class_g = 'Brave-browser'"
              "class_g = 'rofi'"
            ];

            opacity-rule = [
              "95:class_g     = 'Bar'"
              "100:class_g    = 'slop'"
              "100:class_g    = 'XTerm'"
              "100:class_g    = 'URxvt'"
              "100:class_g    = 'ghostty'"
              "95:class_g     = 'Alacritty'"
              "100:class_g    = 'Polybar'"
              "100:class_g    = 'cursor'"
              "100:class_g    = 'Meld'"
              "85:class_g     = 'TelegramDesktop'"
              "95:class_g     = 'Joplin'"
              "100:class_g    = 'Thunderbird'"
              "100:class_g    = 'brave-browser'"
              "100:class_g    = 'Brave-browser'"
              "100:class_g    = 'pcmanfm'"
              "100:class_g    = 'rofi'"
              "100:class_g    = 'dunst'"
            ];

            # Blur - reduced for performance and gruvbox aesthetic
            blur = {
              method = "dual_kawase";
              strength = 3;
              background = false;
              background-frame = false;
              background-fixed = false;
              kern = "3x3box";
            };

            blur-background-exclude = [
              "class_g = 'slop'"
              "class_g = 'ghostty'"
              "class_g = 'rofi'"
              "_GTK_FRAME_EXTENTS@:c"
            ];

            # Backend
            experimental-backends = true;
            backend = "glx";

            # Window detection
            mark-wmwin-focused = true;
            mark-ovredir-focused = true;
            detect-rounded-corners = true;
            detect-client-opacity = true;
            refresh-rate = 0;
            detect-transient = true;
            detect-client-leader = true;
            use-damage = false;

            # Logging
            log-level = "info";

            # Window types
            wintypes = {
              normal = {
                fade = true;
                shadow = true;
              };
              tooltip = {
                fade = true;
                shadow = true;
                opacity = 0.9;
                focus = true;
                full-shadow = false;
              };
              dock = {
                shadow = false;
              };
              dnd = {
                shadow = false;
              };
              popup_menu = {
                opacity = 0.9;
                shadow = true;
              };
              dropdown_menu = {
                opacity = 0.9;
                shadow = true;
              };
            };
          };
        };
      }
    ];
  };
}
