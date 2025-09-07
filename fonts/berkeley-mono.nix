{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "berkeley-mono";
  version = "2.0";

  src = builtins.path {
    path = ../.config/fonts;
    name = "berkeley-mono-src";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype" "$out/share/fonts/opentype"
    cp -r $src/*.{ttf,otf} $out/share/fonts/truetype/
  '';

  meta = with lib; {
    description = "A typeface for professionals.";
    homepage = "https://berkeleygraphics.com/typefaces/berkeley-mono/";
    platforms = platforms.all;
  };
}
