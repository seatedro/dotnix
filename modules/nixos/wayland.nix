{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./wayland/hyprland.nix
    ./wayland/niri.nix
    ./wayland/waybar.nix
    ./wayland/wofi.nix
    ./wayland/mako.nix
    ./wayland/steam.nix
    ./pywal.nix
    ./pywal-scripts.nix
    ./darkman.nix
  ];

  options.wayland = {
    enable = mkEnableOption "Wayland display server and related components";
  };

  config = mkIf config.wayland.enable {
    #---Wayland------
    steam.enable = true;

    waybar.enable = true;
    mako.enable = true;

    #---Sound------
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    #---Touchpad------
    services.libinput.enable = true;

    #---Fonts------
    fonts.packages = with pkgs; [
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];

    environment.systemPackages = with pkgs; [
      wlsunset
    ];

    #---Security------
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
  };
}
