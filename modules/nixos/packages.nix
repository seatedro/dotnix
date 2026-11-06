{
  pkgs,
  swww,
  quickshell,
  ghostty,
  nixpkgs-zed,
  ...
}:
let
  capy = pkgs.callPackage ../../pkgs/capy { };
  codex = pkgs.callPackage ../../pkgs/codex.nix { };
  helium-browser = pkgs.callPackage ../../pkgs/helium.nix { };
  flock = pkgs.callPackage ../../pkgs/flock { };
  quickshellPkg = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  ghosttyPkg = ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
  zedPkg = nixpkgs-zed.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zed-editor;
in
{
  environment.sessionVariables = {
    QML2_IMPORT_PATH = "${quickshellPkg}/lib/qt-6/qml";
  };

  # Capy registers its own capy:// handler pointing at the unwrapped store
  # binary, which can't run outside the AppImage FHS env; route it to ours.
  home-manager.sharedModules = [
    {
      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/capy" = "capy.desktop";
        "x-scheme-handler/t3code" = "flock.desktop";
        "x-scheme-handler/t3code-dev" = "flock.desktop";
      };
    }
  ];

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
    capy
    codex
    helium-browser
    flock
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
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.kio-extras
    kdePackages.kio-fuse
    kdePackages.ffmpegthumbs
    tumbler
    gvfs

    # Media viewers
    zathura
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
