{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.pywal = {
    enable = mkEnableOption "pywal color scheme generator";
    useDarkman = mkOption {
      type = types.bool;
      default = true;
      description = "Use darkman for automatic dark/light mode switching instead of timer";
    };
  };

  config = mkIf config.pywal.enable {
    environment.systemPackages = with pkgs; [
      pywal
      imagemagick # For image processing
      swww # For wallpaper setting
    ];

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          pywal
        ];

        #---Templates------
        xdg.configFile."wal/templates/".source = lib.configFile "wal/templates";
      }
    ];
  };
}
