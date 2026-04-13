{
  description = "seatedro's nix flake";

  nixConfig = {
    extra-substituters = [
      "https://seatedro.cachix.org/"
      "https://ghostty.cachix.org"
      "https://nix-community.cachix.org/"
      "https://hyprland.cachix.org"
      "https://vicinae.cachix.org"
      "https://niri.cachix.org"
    ];

    extra-trusted-public-keys = [
      "seatedro.cachix.org-1:4fBkx08ZIy4YiohCAenWEESD1oVu04kzmz5swAUT43Q="
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];

    experimental-features = [
      "cgroups"
      "flakes"
      "nix-command"
      "pipe-operators"
    ];

    builders-use-substitutes = true;
    http-connections = 50;
    lazy-trees = true;
    show-trace = true;
    trusted-users = [
      "root"
      "ro"
    ];
    use-cgroups = true;
    warn-dirty = false;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus = {
      url = "github:dj95/zjstatus";
    };

    glimpse.url = "github:seatedro/glimpse";

    ghostty = {
      url = "github:ghostty-org/ghostty/v1.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
    };

    swww.url = "github:LGFae/swww";

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      inherit (builtins) readDir;
      inherit (nixpkgs.lib)
        attrsToList
        const
        groupBy
        listToAttrs
        mapAttrs
        nameValuePair
        ;

      lib' = nixpkgs.lib.extend (_: _: nix-darwin.lib);
      lib = lib'.extend <| import ./lib inputs;

      hostsByType =
        readDir ./hosts
        |> mapAttrs (name: const <| import ./hosts/${name} lib)
        |> attrsToList
        |> groupBy (
          {
            name,
            value,
          }:
          if name == "volt" || name == "thanatos" || name == "forge" then
            "nixosConfigurations"
          else
            "darwinConfigurations"
        )
        |> mapAttrs (const listToAttrs);

      hostConfigs =
        hostsByType.darwinConfigurations // hostsByType.nixosConfigurations
        |> attrsToList
        |> map (
          {
            name,
            value,
          }:
          nameValuePair name value.config
        )
        |> listToAttrs;
    in
    hostsByType
    // hostConfigs
    // {
      inherit lib;

      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
        x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt;
        aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
      };

      packages =
        lib.genAttrs
          [
            "x86_64-linux"
          ]
          (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            {
              helium-browser = pkgs.callPackage ./pkgs/helium.nix { };
              t3code = pkgs.callPackage ./pkgs/t3code.nix { };
            }
          );
    };
}
