{
  pkgs,
  appimageTools,
  fetchurl,
}:
let
  pname = "helium-browser";
  version = "0.10.6.1";
in
appimageTools.wrapType2 {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-6xqNRaP3aqitEseexRVEEjKkJClC0j1HHZoRGQanhSk=";
  };

  extraInstallCommands =
    let
      appimageContents = appimageTools.extractType2 {
        inherit pname version;
        src = fetchurl {
          url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
          hash = "sha256-6xqNRaP3aqitEseexRVEEjKkJClC0j1HHZoRGQanhSk=";
        };
      };
    in
    ''
      install -Dm444 ${appimageContents}/helium.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=helium' 'Exec=${pname}'
      install -Dm444 ${appimageContents}/helium.png $out/share/pixmaps/helium.png
    '';

  passthru = {
    updateScript = pkgs.nix-update-script {
      attrPath = "packages.${pkgs.stdenv.hostPlatform.system}.helium-browser";
    };
  };

  meta = {
    description = "Helium web browser";
    homepage = "https://github.com/imputnet/helium-linux";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
