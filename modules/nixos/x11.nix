{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./x/bspwm.nix
    ./x/sxhkd.nix
    ./x/polybar.nix
    ./x/rofi.nix
    ./x/picom.nix
  ];

  options.x11 = {
    enable = mkEnableOption "X11 display server and related components";
  };

  config = mkIf config.x11.enable {
    #---X11------
    bspwm.enable = true;
    picom.enable = true;
    rofi.enable = true;
    polybar.enable = true;
    sxhkd.enable = true;

    services.xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.lightdm.enable = true;
      windowManager.bspwm.enable = true;
    };

    #---XDG Portal------
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gnome];
      config.common.default = "*";
    };

    # Enable sound
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    # Enable touchpad support
    services.libinput.enable = true;
  };
}
