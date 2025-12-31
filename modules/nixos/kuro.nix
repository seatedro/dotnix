{
  config,
  lib,
  pkgs,
  kuro,
  ...
}:
with lib;
{
  options.kuro = {
    enable = mkEnableOption "kuro desktop shell";
  };

  config = mkIf config.kuro.enable {
    home-manager.sharedModules = [
      kuro.homeManagerModules.default
      {
        programs.caelestia = {
          enable = true;
          package = kuro.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;

          systemd = {
            enable = true;
            target = "hyprland-session.target";
          };

          settings = {
            services.smartScheme = true;
          };
        };
      }
    ];
  };
}
