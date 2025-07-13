{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./wofi.nix
    ./mako.nix
  ];

  options.wayland-desktop = {
    enable = mkEnableOption "Wayland desktop environment with Hyprland";
  };

  config = mkIf config.wayland-desktop.enable {
    # Enable all wayland components
    hyprland.enable = true;
    waybar.enable = true;
    wofi.enable = true;
    mako.enable = true;

    # Essential desktop packages
    environment.systemPackages = with pkgs; [
      # Applications
      ghostty
      thunar
      thunar-volman
      tumbler
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
      nvtop
      nvitop
      libGL
    ];

    services.xserver.videoDrivers = [ "nvidia" ];

    # Enable file manager daemon
    services.gvfs.enable = true;

    # Enable thumbnail support
    services.tumbler.enable = true;

    # Enable network manager applet
    programs.nm-applet.enable = true;

    # Enable gnome keyring
    services.gnome.gnome-keyring.enable = true;
  };
} 