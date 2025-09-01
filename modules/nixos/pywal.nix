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
  };

  config = mkIf config.pywal.enable {
    environment.systemPackages = with pkgs; [
      pywal
      imagemagick  # For image processing
      swww         # For wallpaper setting
    ];

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          pywal
        ];

        # Create pywal template directory
        xdg.configFile."wal/templates/".source = lib.configFile "wal/templates";
      }
    ];
  };
}