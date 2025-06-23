{ config, lib, ... }:
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
    # Don't require password for sudo
    security.sudo.wheelNeedsPassword = false;
  };
}
