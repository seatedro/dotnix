{
  appimageTools,
  fetchurl,
  stdenv,
}:
let
  pname = "flock-desktop";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  inherit (source) version;
  src = fetchurl source.sources.${stdenv.hostPlatform.system};
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/t3code.desktop $out/share/applications/flock.desktop
    substituteInPlace $out/share/applications/flock.desktop \
      --replace-fail 'Exec=AppRun %U' 'Exec=${pname} %U' \
      --replace-fail 'Icon=t3code' 'Icon=flock'
    install -Dm444 ${appimageContents}/t3code.png $out/share/icons/hicolor/1024x1024/apps/flock.png
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Flock desktop client, seatedro's fork of T3 Code";
    homepage = "https://github.com/seatedro/t3code";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = pname;
  };
}
