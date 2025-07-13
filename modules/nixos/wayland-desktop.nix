{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  imports = [
    ./wayland.nix
    ./theme.nix
  ];

  options.wayland-desktop = {
    enable = mkEnableOption "Wayland desktop environment with Hyprland";
  };

  config = mkIf config.wayland-desktop.enable {
    # Enable Wayland components
    wayland.enable = true;

    # Essential desktop packages
    environment.systemPackages = with pkgs; [
      # Applications
      ghostty
      xfce.thunar
      xfce.thunar-volman
      xfce.tumbler
      pavucontrol
      yazi
      btop
      
      # Bluetooth management
      blueberry
      
      # System utilities
      papirus-icon-theme
      gvfs

      # Nvidia
      libva-utils
      vdpauinfo
      vulkan-tools
      vulkan-validation-layers
      libvdpau-va-gl
      egl-wayland
      wgpu-utils
      mesa
      libglvnd
      nvitop
      libGL
    ];

    services.xserver.videoDrivers = [ "nvidia" ];

    services.displayManager.ly.enable = true;

    # Enable file manager daemon
    services.gvfs.enable = true;

    # Enable thumbnail support
    services.tumbler.enable = true;

    # Enable network manager applet
    programs.nm-applet.enable = true;

    # Enable fcitx5 input method
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-configtool
        fcitx5-gtk
      ];
    };
  };
} 