{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      {
        programs.atuin = {
          enable = true;
          settings = {
            style = "compact";
            sync_frequency = "1h";
            search_mode = "fuzzy";
          };
        };

        programs.fish = {
          enable = true;
          shellInit = ''
            set -x EDITOR nvim
            set -x BROWSER brave-browser

            if test -z "$SSH_AUTH_SOCK"
                eval (ssh-agent -c) > /dev/null
            end

            if test -f ~/.ssh/id_ed25519
                ssh-add ~/.ssh/id_ed25519 2>/dev/null
            end
          '';
        };
      }
    ];
  };
}
