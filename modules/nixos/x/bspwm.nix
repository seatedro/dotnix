{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.bspwm = {
    enable = mkEnableOption "Bspwm window manager";
  };

  config = mkIf config.bspwm.enable {
    services.xserver = {
      enable = true;
      windowManager.bspwm = {
        enable = true;
      };
    };

    home-manager.sharedModules = [
      {
        xdg.configFile."bspwm/bspwmrc" = {
          source = lib.configFile "bspwm/bspwmrc";
          executable = true;
        };
      }
    ];

    services.displayManager.defaultSession = "none+bspwm";

    environment.systemPackages = with pkgs; [
      bspwm
      sxhkd
      xorg.xsetroot
      nitrogen
      polkit_gnome
    ];
  };
}
