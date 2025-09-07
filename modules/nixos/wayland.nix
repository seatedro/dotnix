{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./wayland/hyprland.nix
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
    # Enable Wayland components
    hyprland.enable = true;
    waybar.enable = true;
    wofi.enable = false;
    mako.enable = true;
    steam.enable = true;
    pywal.enable = true;
    darkman.enable = mkIf config.pywal.useDarkman true;

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
      config = {
        common.default = ["hyprland"];
        hyprland.default = ["hyprland"];
        hyprland."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
        hyprland."org.freedesktop.impl.portal.Settings" = ["darkman"];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-termfilechooser
      ];
    };

    # Enable touchpad support
    services.libinput.enable = true;

    # Font configuration
    fonts.packages = with pkgs; [
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];

    environment.systemPackages = with pkgs; [
      wlsunset
    ];

    # Security and authentication
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
  };
}
