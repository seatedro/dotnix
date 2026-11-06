{
  config,
  lib,
  dms,
  ...
}:
{
  options.dms.enable = lib.mkEnableOption "Dank Material Shell desktop and greeter";

  config = lib.mkIf config.dms.enable {
    services.displayManager.ly.enable = lib.mkForce false;

    programs.dms-greeter = {
      enable = true;
      compositor.name = if config.niri.enable then "niri" else "hyprland";
    };

    waybar.enable = lib.mkForce false;
    mako.enable = lib.mkForce false;

    home-manager.sharedModules =
      lib.optionals (!config.hyprland.enable) [
        dms.homeModules.dank-material-shell
        {
          programs.dank-material-shell = {
            enable = true;
            systemd.enable = true;
          };
        }
      ]
      ++ lib.optionals config.niri.enable [
        dms.homeModules.niri
        {
          programs.dank-material-shell.niri = {
            enableKeybinds = false;
            enableSpawn = false;
            includes.filesToInclude = [
              "alttab"
              "binds"
              "colors"
              "cursor"
              "layout"
              "outputs"
              "wpblur"
            ];
          };
        }
      ];
  };
}
