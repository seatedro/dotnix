{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
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
    # Enable X11 and display manager
    services.xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.lightdm.enable = true;
      windowManager.bspwm.enable = true;
    };

    # XDG Portal for desktop integration
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
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

    # Font configuration
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
  };
} 