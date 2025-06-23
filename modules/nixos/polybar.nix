{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  config = {
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
