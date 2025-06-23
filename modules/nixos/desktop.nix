{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  imports = [
    ./bspwm.nix
    ./sxhkd.nix
    ./polybar.nix
    ./rofi.nix
    ./picom.nix
    ./dunst.nix
  ];

  options.desktop = {
    enable = mkEnableOption "desktop environment with bspwm";
  };

  config = mkIf config.desktop.enable {

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      config.common.default = "*";
    };
    services.gnome.gnome-keyring.enable = true;

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

    # Enable X11 and display manager
    services.xserver = {
      enable = true;
      dpi = 220;

      displayManager = {
        lightdm.enable = true;
        sessionCommands = ''
          ${pkgs.xorg.xset}/bin/xset r rate 200 40
        '';
      };

      desktopManager = {
        wallpaper.mode = "fill";
      };
    };

    # Enable polkit for authentication
    security.polkit.enable = true;

    # Enable sound with PipeWire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable network manager applet and other system services
    programs.nm-applet.enable = true;

    # Enable file manager daemon
    services.gvfs.enable = true;

    # Enable thumbnail support
    services.tumbler.enable = true;
  };
}
