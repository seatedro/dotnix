{
  config,
  lib,
  pkgs,
  niri,
  dms,
  ...
}:
with lib;
{
  imports = [
    niri.nixosModules.niri
  ];

  options.niri = {
    enable = mkEnableOption "niri scrollable-tiling Wayland compositor";
  };

  config = mkIf config.niri.enable {
    #---Niri------
    hyprland.enable = mkForce false;
    programs.niri.enable = true;
    programs.niri.package = niri.packages.${pkgs.system}.niri-unstable;
    kuro.enable = mkForce false;
    services.upower.enable = true;

    #---Packages------
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      swaylock
      swaybg
      wl-clipboard
      wl-clip-persist
      grim
      slurp
      brightnessctl
      playerctl
      wireplumber
      rose-pine-cursor
    ];

    #---dconf------
    programs.dconf.enable = true;

    #---XDG Portal------
    xdg.portal = {
      enable = true;
      config = {
        common.default = [
          "gnome"
          "gtk"
        ];
        niri.default = [
          "gnome"
          "gtk"
        ];
        niri."org.freedesktop.impl.portal.Settings" = [
          "gnome"
        ];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    #---Home Manager------
    home-manager.sharedModules = [
      dms.homeModules.dank-material-shell
      dms.homeModules.niri
      {
        programs.dank-material-shell = {
          enable = true;
          systemd.enable = true;
          niri.enableKeybinds = false;
          niri.enableSpawn = false;
          niri.includes.filesToInclude = [
            "alttab"
            "binds"
            "colors"
            "cursor"
            "layout"
            "outputs"
            "wpblur"
          ];
        };

        #---Niri Settings------
        programs.niri.settings = {
          input.keyboard.xkb.options = "caps:escape";
          input.keyboard.repeat-delay = 300;
          input.keyboard.repeat-rate = 50;
          input.touchpad.tap = true;
          input.touchpad.natural-scroll = false;
          input.touchpad.click-method = "clickfinger";
          input.mouse.accel-profile = "flat";
          input.focus-follows-mouse.enable = true;
          input.focus-follows-mouse.max-scroll-amount = "10%";

          cursor.theme = "rose-pine-cursor";
          cursor.size = 24;

          layout = {
            gaps = 5;
            struts = {
              left = 2;
              right = 2;
              top = 0;
              bottom = 0;
            };
          };

          prefer-no-csd = true;

          screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";

          environment = {
            GDK_BACKEND = "wayland";
            QT_QPA_PLATFORM = "wayland";
            SDL_VIDEODRIVER = "wayland";
            MOZ_ENABLE_WAYLAND = "1";
            ELECTRON_OZONE_PLATFORM_HINT = "wayland";
            OZONE_PLATFORM = "wayland";
            NIXOS_OZONE_WL = "1";
            XCURSOR_SIZE = "24";
            BROWSER = "helium-browser";
          };

          spawn-at-startup = [
            {
              command = [
                "wl-clip-persist"
                "--clipboard"
                "regular"
              ];
            }
            {
              command = [
                "wlsunset"
                "-S"
                "05:30"
                "-s"
                "17:40"
              ];
            }
            { command = [ "xwayland-satellite" ]; }
          ];

          binds = {
            "Mod+Return".action.spawn = [ "ghostty" ];
            "Mod+B".action.spawn = [
              "helium-browser"
              "--ozone-platform=wayland"
            ];
            "Mod+Ctrl+L".action.spawn = [
              "helium-browser"
              "--app=https://t3.chat"
            ];
            "Mod+Ctrl+E".action.spawn = [
              "helium-browser"
              "--app=https://gmail.com"
            ];
            "Mod+Ctrl+Y".action.spawn = [
              "helium-browser"
              "--app=https://youtube.com"
            ];
            "Mod+Ctrl+X".action.spawn = [
              "helium-browser"
              "--app=https://x.com"
            ];
            "Mod+Ctrl+W".action.spawn = [
              "helium-browser"
              "--app=https://web.whatsapp.com"
            ];
            "Mod+Ctrl+C".action.spawn = [
              "helium-browser"
              "--app=https://cobalt.tools"
            ];
            "Mod+Ctrl+G".action.spawn = [
              "helium-browser"
              "--app=https://github.com"
            ];
            "Mod+Ctrl+N".action.spawn = [
              "helium-browser"
              "--app=https://notion.so"
            ];
            "Mod+Ctrl+D".action.spawn = [
              "helium-browser"
              "--app=https://app.devin.ai"
            ];
            "Mod+Ctrl+T".action.spawn = [ "t3code" ];
            "Mod+Ctrl+M".action.spawn = [ "gnote" ];
            "Mod+Ctrl+A".action.spawn = [ "kalarm" ];
          };

          window-rules = [
            {
              clip-to-geometry = true;
              geometry-corner-radius =
                let
                  r = 8.0;
                in
                {
                  top-left = r;
                  top-right = r;
                  bottom-left = r;
                  bottom-right = r;
                };
            }
          ];
        };
      }
    ];
  };
}
