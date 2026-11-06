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
      shell = pkgs.zsh;
      uid = 501;
    };

    users.knownUsers = [ "ro" ];

    home-manager.users.ro.home = {
      stateVersion = "25.11";
      homeDirectory = "/Users/ro";
    };

    environment.etc.nix-darwin.source = "/Users/ro/.config/nix";
    nix.settings.trusted-users = [ "ro" ];

    services.openssh = {
      enable = true;
      extraConfig = ''
        AllowUsers ro@100.64.0.0/10 ro@fd7a:115c:a1e0::/48
      '';
    };

    system.stateVersion = 5;
    nixpkgs.hostPlatform = "aarch64-darwin";
  }
)
