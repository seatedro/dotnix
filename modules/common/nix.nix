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
      ];

      warn-dirty = false;
    };

    channel.enable = false;
    gc =
      merge {
        automatic = true;
        options = "--delete-older-than 3d";
      }
      <| optionalAttrs config.isLinux {
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
    nixfmt-rfc-style
  ];
}
