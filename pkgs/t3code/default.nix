{
  appimageTools,
  fetchurl,
}:
let
  pname = "t3code";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  inherit (source) version;
  src = fetchurl {
    inherit (source) url hash;
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
      install -Dm444 ${appimageContents}/t3code.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun %U' 'Exec=${pname} %U'
      install -Dm444 ${appimageContents}/t3code.png $out/share/pixmaps/t3code.png
    '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "T3 Code desktop client";
    homepage = "https://github.com/pingdotgg/t3code";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
