{
  pkgs,
  swww,
  quickshell,
  ghostty,
  nixpkgs-zed,
  ...
}:
let
  helium-browser = pkgs.callPackage ../../pkgs/helium.nix { };
  t3code = pkgs.callPackage ../../pkgs/t3code.nix { };
  quickshellPkg = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  ghosttyPkg = ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
  zedPkg = nixpkgs-zed.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zed-editor;
in
{
  environment.sessionVariables = {
    QML2_IMPORT_PATH = "${quickshellPkg}/lib/qt-6/qml";
  };

  #---Common Packages------
  environment.systemPackages = with pkgs; [
    #---System Tools------
    nixfmt
    nixd
    xclip
    cliphist
    fuzzel
    glib
    gsettings-desktop-schemas
    proton-vpn

    #---Applications------
    (brave.override {
      commandLineArgs = "--ozone-platform=wayland --enable-features=WaylandFractionalScaleV1";
    })
    helium-browser
    t3code
    ghosttyPkg
    vesktop
    telegram-desktop
    qbittorrent
    zedPkg
    krita
    slack
    k9s
    gnote
    kdePackages.kalarm
    sox
    syncthing

    # File management (common across desktop modules)
    thunar
    thunar-volman
    tumbler
    gvfs

    # Media viewers
    mpv
    feh

    # System applications
    wine64Packages.stable
    sdl3
    kdePackages.qtdeclarative
    comma

    swww.packages.${pkgs.stdenv.hostPlatform.system}.swww
    quickshellPkg
  ];
}
