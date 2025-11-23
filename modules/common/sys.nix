{
  config,
  lib,
  ...
}:
let
  inherit (lib) last mkConst splitString;
in
{
  options = {
    os = mkConst <| last <| splitString "-" config.nixpkgs.hostPlatform.system;
    isDarwin = mkConst <| config.os == "darwin";
    isLinux = mkConst <| config.os == "linux";
  };

  config = {
    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = false;
  };
}
