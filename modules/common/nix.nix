{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) merge mkDefault optionalAttrs;
in
{
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];

      max-jobs = mkDefault "auto";
      cores = mkDefault 0;

      trusted-users = [
        "root"
        "ro"
        "rohit"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://seatedro.cachix.org"
        "https://ghostty.cachix.org"
        "https://devenv.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbPFnrF6IIIKhB9Qtr8xB0qf9M="
        "seatedro.cachix.org-1:4fBkx08ZIy4YiohCAenWEESD1oVu04kzmz5swAUT43Q="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];

      warn-dirty = false;
    };

    channel.enable = false;
    gc =
      merge {
        options = "--delete-older-than 3d";
      }
      <| optionalAttrs config.isLinux {
        automatic = true;
        dates = "weekly";
        persistent = true;
      };

    enable = if config.isDarwin then false else true;

    optimise.automatic = if config.isDarwin then false else true;
  };

  environment.systemPackages = with pkgs; [
    cachix
    nil
    nix-output-monitor
    nixpkgs-fmt
    nixfmt
  ];
}
