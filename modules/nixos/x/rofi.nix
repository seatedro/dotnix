{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  environment.systemPackages = with pkgs; [
    rofi
    papirus-icon-theme
  ];

  home-manager.sharedModules = [
    {
      xdg.configFile."rofi/config.rasi" = {
        source = lib.configFile "rofi/config.rasi";
        executable = true;
      };
      xdg.configFile."rofi/gruvbox-dark-hard.rasi" = {
        source = lib.configFile "rofi/gruvbox-dark-hard.rasi";
        executable = true;
      };
      xdg.configFile."rofi/gruvbox-common.rasi" = {
        source = lib.configFile "rofi/gruvbox-common.rasi";
        executable = true;
      };
    }
  ];
}
