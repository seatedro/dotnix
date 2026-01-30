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
      pavucontrol
      blueberry
      papirus-icon-theme
      gvfs
      vulkan-tools
      mesa
      libglvnd
      libGL
    ];

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
