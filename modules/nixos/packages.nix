{
  pkgs,
  swww,
  quickshell,
  ...
}:
let
  helium-browser = pkgs.callPackage ../../pkgs/helium.nix { };
  quickshellPkg = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.sessionVariables = {
    QML2_IMPORT_PATH = "${quickshellPkg}/lib/qt-6/qml";
  };

  #---Common Packages------
  environment.systemPackages = with pkgs; [
    #---System Tools------
    nixfmt-rfc-style
    nixd
    xclip
    glib
    gsettings-desktop-schemas
    protonvpn-gui

    #---Applications------
    brave
    helium-browser
    ghostty
    vesktop
    telegram-desktop
    qbittorrent
    zed-editor-fhs
    krita

    # File management (common across desktop modules)
    thunar
    thunar-volman
    tumbler
    gvfs

    # Media viewers
    mpv
    feh

    # System applications
    wineWowPackages.stable
    sdl3
    kdePackages.qtdeclarative

    swww.packages.${pkgs.stdenv.hostPlatform.system}.swww
    quickshellPkg
  ];
}
