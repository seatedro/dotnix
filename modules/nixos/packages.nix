{
  pkgs,
  swww,
  vicinae,
  ...
}:
{
  #---Common Packages------
  environment.systemPackages = with pkgs; [
    #---System Tools------
    nixfmt-rfc-style
    nixd
    xclip

    #---Applications------
    brave
    ghostty
    vesktop
    telegram-desktop
    qbittorrent

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
