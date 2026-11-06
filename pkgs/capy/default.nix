{
  appimageTools,
  fetchurl,
}:
let
  pname = "capy";
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
      install -Dm444 ${appimageContents}/capy.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun %U' 'Exec=${pname} %U'
      mkdir -p $out/share/icons
      cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons/
    '';

  # Updated by ./update.sh from the electron-builder feed, not nix-update.
  meta = {
    description = "Capy desktop app for running coding agents in the cloud";
    homepage = "https://capy.ai";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
