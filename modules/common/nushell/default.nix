{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrValues
    enabled
    mkIf
    optionalAttrs
    readFile
    removeAttrs
    ;
in
{
  environment =
    optionalAttrs config.isDarwin {
      shells = [ pkgs.nushell ];
    }
    // {
      systemPackages = attrValues {
        inherit (pkgs)
          fish # For completions
          zoxide # For completions and better cd
          starship
          vivid # For ls colors
          ;
      };

      variables.STARSHIP_LOG = "error";
    };

  home-manager.sharedModules = [
    {
      xdg.configFile = {
        "nushell/zoxide.nu".source = pkgs.runCommand "zoxide.nu" { } ''
          ${pkgs.zoxide}/bin/zoxide init nushell > $out
        '';

        "nushell/starship.nu".source = pkgs.runCommand "starship.nu" { } ''
          ${pkgs.starship}/bin/starship init nu > $out
        '';
      };

      programs.starship = enabled {
        enableNushellIntegration = false;

        settings = {
          vcs.disabled = false;
          command_timeout = 100;
          scan_timeout = 20;
          character.error_symbol = "";
          character.success_symbol = "";
        };
      };

      programs.nushell = enabled {
        configFile.text = readFile ./config.nu;
        envFile.text = readFile ./environment.nu;

        environmentVariables = config.environment.variables;

        shellAliases =
          removeAttrs config.environment.shellAliases [
            "ls"
            "l"
          ]
          // {
            cdtmp = "cd (mktemp --directory)";
            ll = "ls --long";
          };
      };
    }
  ];
}
