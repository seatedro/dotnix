{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.polybar = {
    enable = mkEnableOption "Polybar status bar";
  };

  config = mkIf config.polybar.enable {
    home-manager.sharedModules = [
      {
        services.polybar = {
          enable = true;
          config = lib.configFile "polybar/config.ini";
          script = "polybar bar1 &";
        };
      }
    ];
  };
}
