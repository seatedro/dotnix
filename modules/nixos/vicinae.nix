{
  config,
  lib,
  pkgs,
  vicinae,
  ...
}:
with lib;
let
  pywalConverter = pkgs.writeScriptBin "vicinae-pywal-converter" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile (lib.configFile "vicinae/pywal_to_json_converter.py")}
  '';
in
{
  options.vicinae = {
    enable = mkEnableOption "vicinae launcher";
  };

  config = mkIf config.vicinae.enable {
    environment.systemPackages = [
      pywalConverter
      vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    home-manager.sharedModules = [
      {
        systemd.user.services.vicinae = {
          Unit = {
            Description = "Vicinae launcher server";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/vicinae server";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ ];
          };
        };
        xdg.configFile."vicinae/config.toml" = {
          text = ''
            [general]
            hotkey = "Alt+Space"
            theme = "pywal"

            [colors]
            background = "#ebdbb2"
            foreground = "#282828"
            selection = "#d65d0e"
            accent = "#458588"
            warning = "#d79921"
            error = "#cc241d"

            [appearance]
            width = 800
            max_height = 600
            show_icons = true
            icon_size = 32

            [extensions]
            enabled = [
              "applications",
              "file_search",
              "calculator",
              "clipboard_history",
              "emoji",
              "shortcuts",
              "themes",
              "window_manager",
              "system_commands"
            ]

            [themes]
            quick_switch = true
            available_themes = [
              "gruvbox",
              "catppuccin",
              "nord",
              "tokyo-night",
              "kanagawa",
              "everforest",
              "dracula"
            ]

            [file_search]
            paths = [
              "~/Documents",
              "~/Downloads",
              "~/code",
              "~/.config"
            ]
            max_results = 20

            [clipboard_history]
            max_items = 100
            enable_encryption = true
          '';
        };
      }
    ];
  };
}
