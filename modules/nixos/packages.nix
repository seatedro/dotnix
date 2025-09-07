{
  pkgs,
  swww,
  vicinae,
  ...
}: {
  # Common Linux system packages that were scattered across modules
  environment.systemPackages = with pkgs; [
    # Base system tools (from sys.nix)
    nixfmt-rfc-style
    nixd
    xclip

    # Applications
    brave
    ghostty
    vesktop
    telegram-desktop

    # File management (common across desktop modules)
    xfce.thunar
    xfce.thunar-volman
    xfce.tumbler
    gvfs

    # Media viewers
    mpv
    feh

    # System applications
    wineWowPackages.stable
    sdl3

    swww.packages.${pkgs.system}.swww
    vicinae.packages.${pkgs.system}.default
  ];
}
