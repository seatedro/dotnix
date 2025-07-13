{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.sxhkd = {
    enable = mkEnableOption "Sxhkd keyboard shortcut daemon";
  };

  config = mkIf config.sxhkd.enable {
    environment.systemPackages = with pkgs; [
      sxhkd
    ];

    home-manager.sharedModules = [
      {
        services.sxhkd = {
          enable = true;
          keybindings = {
            # Terminal
            "super + Return" = "ghostty";
            "super + b" = "brave-browser";

            # Focus options
            "super + {h,j,k,l}" = "bspc node -f {west,south,north,east}"; # Switch window directly
            "super + {_,shift + } Tab" = "bspwc node -f {next.local,prev.local}"; # Switch focus chronologically

            # Window options
            "super + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}"; # Move window
            "alt + shift + {h,j,k,l}" = "bspc node -v {-20 0,0 20,0 -20,20 0}"; # Move floating window
            "super + alt + {h,l,k,j}" = "bspc node -z {left 20 0,right -20 0,top 0 20,bottom 0 -20}"; # Shrink window
            "super + control + {h,l,k,j}" = "bspc node -z {left -20 0,right 20 0,top 0 -20,bottom 0 20}"; # Expand window
            "super + q" = "bspc node -c"; # Close window

            # Automatic layout
            "super + f" = "bspc desktop -l next"; # Toggle monocle
            "super + space" = "bspc node -t '~'{floating,tiled}"; # Toggle float and tile
            "super + {p,t}" = "bspc node -t {pseudo_tiled,tiled}"; # Switch tile and pseudo tile

            # Manual layout
            "super + {Up,Down,esc}" = "bspc node -p {east,south,cancel}"; # Specify direction
            "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}"; # Specify ratio

            # Workspace
            "super + {1,2,3,4,5,6,7}" = "bspc desktop -f '^{1,2,3,4,5,6,7}'"; # Switch workspace directly
            "ctrl + alt + {h,l}" = "bspc desktop -f {prev.local,next.local}"; # Switch workspace in order
            "super + shift + {1,2,3,4,5,6,7}" = "bspc node -d '^{1,2,3,4,5,6,7}'"; # Window --> Workspace

            # Rofi
            "super + d" = "rofi -show drun"; # Application menu
            "alt + Tab" = "rofi -show window";
            "super + shift + f" = "rofi -show filebrowser";

            # Dunst
            "super + shift + o" = "dunstctl history-pop";
            "super + shift + p" = "dunstctl close";

            # Volume keys
            "XF86AudioMute" = "pamixer -t";
            "XF86AudioRaiseVolume" = "pamixer -i 5";
            "XF86AudioLowerVolume" = "pamixer -d 5";

            # Backlight
            "XF86MonBrightnessUp" = "brightnessctl set +5%";
            "XF86MonBrightnessDown" = "brightnessctl set 5%-";

            # Media keys
            "XF86AudioPlay" = "playerctl play-pause";
            "XF86AudioPrev" = "playerctl previous";
            "XF86AudioNext" = "playerctl next";

            # Screenshot
            "super + shift + s" = "scrot '%d.%m.%Y_$wx$h.png' -e 'mv $f ~/Bilder/'";
            "alt + shift + s" = "scrot -u '%d.%m.%Y_$wx$h.png' -e 'mv $f ~/Bilder/'";

            # Options if something goes wrong
            "ctrl + alt + r" = "systemctl --user restart polybar.service";
            "ctrl + alt + q" = "xkill";
          };
        };
      }
    ];
  };
}
