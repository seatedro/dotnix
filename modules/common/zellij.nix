{
  lib,
  pkgs,
  ...
}:
let
  configFile = lib.configFile;
in
{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      {
        xdg.configFile = {
          "zellij/config.kdl".source = configFile "zellij/config.kdl";
          "zellij/layouts/simple.kdl".source = pkgs.replaceVars (configFile "zellij/simple.kdl") {
            zjstatus = pkgs.zjstatus;
          };
          "zellij/layouts/mobile.kdl".source = pkgs.replaceVars (configFile "zellij/mobile.kdl") {
            zjstatus = pkgs.zjstatus;
          };
        };
        home.activation.zellijPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          target="${config.xdg.cacheHome}/zellij/permissions.kdl"
          mkdir -p "$(dirname "$target")"
          if [ -L "$target" ]; then
            rm "$target"
          fi
          install -m 0644 ${
            pkgs.replaceVars (configFile "zellij/permissions.kdl") { zjstatus = pkgs.zjstatus; }
          } "$target"
        '';
        programs.zellij = {
          enable = true;
          package = pkgs.zellij;
        };
      }
    )
  ];
}
