{
  pkgs,
  swww,
  ...
}:
let
  helium-browser = pkgs.callPackage ../../pkgs/helium.nix { };
in
{
  #---Common Packages------
  environment.systemPackages = with pkgs; [
    #---System Tools------
    nixfmt-rfc-style
    nixd
    xclip
    protonvpn-gui

    #---Applications------
    brave
    helium-browser
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
  ];
}
