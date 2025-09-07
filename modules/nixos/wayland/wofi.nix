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
    #---Package------
    environment.systemPackages = with pkgs; [
      wofi
    ];

    #---Home Manager------
    home-manager.sharedModules = [
      {
        #---Config Files------
        xdg.configFile."wofi/config" = {
          source = lib.configFile "wofi/config";
        };
        xdg.configFile."wofi/style.css" = {
          source = lib.configFile "wofi/style.css";
        };

        #---Program------
        programs.wofi = {
          enable = true;
        };
      }
    ];
  };
}
