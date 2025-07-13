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
  ];

  options.desktop = {
    enable = mkEnableOption "desktop environment with bspwm";
  };

  config = mkIf config.desktop.enable {
    # Enable X11 components
    x11.enable = true;

    # Essential desktop packages
    environment.systemPackages = with pkgs; [
      # Applications
      ghostty
      pcmanfm
      pavucontrol
      yazi
      btop
      scrot
      nitrogen

      # System utilities
      polkit_gnome
    ];

    # X11 specific configuration
    services.xserver = {
      dpi = 220;
      displayManager.sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';
      desktopManager.wallpaper.mode = "fill";
    };

    # Enable polkit for authentication
    security.polkit.enable = true;

    # Enable sound with PipeWire
    security.rtkit.enable = true;

    # Enable network manager applet and other system services
    programs.nm-applet.enable = true;

    # Enable file manager daemon
    services.gvfs.enable = true;

    # Enable thumbnail support
    services.tumbler.enable = true;
  };
}
