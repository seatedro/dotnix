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
    ./vicinae.nix
  ];

  options.wayland-desktop = {
    enable = mkEnableOption "Wayland desktop environment with Hyprland";
  };

  config = mkIf config.wayland-desktop.enable {
    wayland.enable = true;

    # disabled - kuro handles launcher
    # wofi.enable = true;

    environment.systemPackages = with pkgs; [
      #---Apps------
      pavucontrol

      #---Bluetooth------
      blueberry

      #---Utils------
      papirus-icon-theme
      gvfs

      #---Nvidia------
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

    services.gvfs.enable = true;

    services.tumbler.enable = true;

    programs.nm-applet.enable = true;

    programs.nix-ld.enable = true;

    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        qt6Packages.fcitx5-configtool
        fcitx5-gtk
      ];
    };
  };
}
