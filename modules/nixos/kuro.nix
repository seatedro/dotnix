{
  config,
  lib,
  pkgs,
  kuro,
  caelestia-cli,
  ...
}:
with lib;
{
  options.kuro = {
    enable = mkEnableOption "kuro desktop shell";
  };

  config = mkIf config.kuro.enable {
    services.upower.enable = true;

    environment.systemPackages = [
      caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home-manager.sharedModules = [
      kuro.homeManagerModules.default
      {
        programs.caelestia = {
          enable = true;
          package = kuro.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;

          systemd = {
            enable = true;
            target = "graphical-session.target";
          };

          settings = {
            services.smartScheme = true;
          };
        };
      }
    ];
  };
}
