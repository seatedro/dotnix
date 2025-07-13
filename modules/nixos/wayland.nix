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
    ./wayland/waybar.nix
    ./wayland/wofi.nix
    ./wayland/mako.nix
  ];

  options.wayland = {
    enable = mkEnableOption "Wayland display server and related components";
  };

  config = mkIf config.wayland.enable {
    # Enable Wayland components
    hyprland.enable = true;
    waybar.enable = true;
    wofi.enable = true;
    mako.enable = true;

    # Enable sound
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    # XDG Portal for Wayland
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      config.common.default = "*";
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

    # Security and authentication
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
  };
} 