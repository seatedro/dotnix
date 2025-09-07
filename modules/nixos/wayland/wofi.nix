{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.wofi = {
    enable = mkEnableOption "Wofi application launcher";
  };

  config = mkIf config.wofi.enable {
    # Install wofi
    environment.systemPackages = with pkgs; [
      wofi
    ];

    # Home Manager configuration
    home-manager.sharedModules = [
      {
        # Wofi config files
        xdg.configFile."wofi/config" = {
          source = lib.configFile "wofi/config";
        };
        xdg.configFile."wofi/style.css" = {
          source = lib.configFile "wofi/style.css";
        };

        # Enable wofi program
        programs.wofi = {
          enable = true;
        };
      }
    ];
  };
}
