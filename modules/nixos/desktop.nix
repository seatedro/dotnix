{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./x11.nix
    ./dunst.nix
    ./vicinae.nix
  ];

  options.desktop = {
    enable = mkEnableOption "desktop environment with bspwm";
  };

  config = mkIf config.desktop.enable {
    #---X11------
    x11.enable = true;

    #---Vicinae------
    vicinae.enable = true;

    #---Packages------
    environment.systemPackages = with pkgs; [
      #---Apps------
      ghostty
      pcmanfm
      pavucontrol
      yazi
      btop
      scrot
      nitrogen

      #---Utils------
      polkit_gnome
    ];

    #---X11 Config------
    services.xserver = {
      dpi = 220;
      displayManager.sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';
      desktopManager.wallpaper.mode = "fill";
    };

    #---Polkit------
    security.polkit.enable = true;

    #---PipeWire------
    security.rtkit.enable = true;

    #---Network------
    programs.nm-applet.enable = true;

    #---File Manager------
    services.gvfs.enable = true;

    #---Thumbnails------
    services.tumbler.enable = true;
  };
}
