{
  pkgs,
  appimageTools,
  fetchurl,
}:
let
  pname = "t3code";
  version = "0.0.9";
  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-jdLmriOb9WsusOICaPhehxDx4gAsxHVb8mJPIkgFTZg=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands =
    let
      appimageContents = appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    ''
      install -Dm444 ${appimageContents}/t3-code-desktop.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} --no-sandbox %U'
      install -Dm444 ${appimageContents}/t3-code-desktop.png $out/share/pixmaps/t3-code-desktop.png
    '';

  passthru = {
    updateScript = pkgs.nix-update-script {
      attrPath = "packages.${pkgs.stdenv.hostPlatform.system}.t3code";
    };
  };

  meta = {
    description = "T3 Code desktop client";
    homepage = "https://github.com/pingdotgg/t3code";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
