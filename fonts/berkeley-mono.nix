{ pkgs, lib }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "berkeley-mono";
  version = "2.0";

  src = ../.config/fonts;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp -r $src/*.{ttf,otf} $out/share/fonts/truetype/
  '';

  meta = with lib; {
    description = "A typeface for professionals.";
    homepage = "https://berkeleygraphics.com/typefaces/berkeley-mono/";
    platforms = platforms.all;
  };
}
