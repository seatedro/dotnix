lib:
lib.darwinSystem' (
  {
    lib,
    pkgs,
    ...
  }:
  let
    inherit (lib) collectNix remove;
  in
  {
    imports = collectNix ./. |> remove ./default.nix;

    networking.hostName = "nori";

    users.users.ro = {
      name = "ro";
      home = "/Users/ro";
      shell = pkgs.nushell;
      uid = 501;
    };

    users.knownUsers = [ "ro" ];

    home-manager.users.ro.home = {
      stateVersion = "25.11";
      homeDirectory = "/Users/ro";
    };

    environment.etc.nix-darwin.source = "/Users/ro/.config/nix";
    nix.settings.trusted-users = [ "ro" ];

    system.stateVersion = 5;
    nixpkgs.hostPlatform = "aarch64-darwin";
  }
)
