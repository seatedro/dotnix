{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    {
      xdg.configFile = {
        "zellij/config.kdl".source = lib.configFile "zellij/config.kdl";
      };
      xdg.configFile = {
        "zellij/layouts/simple.kdl".source = pkgs.replaceVars (lib.configFile "zellij/simple.kdl") {
          zjstatus = pkgs.zjstatus;
        };
      };
      programs.zellij = {
        enable = true;
        package = pkgs.zellij;
      };
    }
  ];
}
