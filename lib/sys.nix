inputs: self: super: let
  inherit
    (self)
    attrValues
    filter
    getAttrFromPath
    hasAttrByPath
    collectNix
    ;

  collectInputs = let
    inputs' = attrValues inputs;
  in
    path: inputs' |> filter (hasAttrByPath path) |> map (getAttrFromPath path);

  inputModulesDarwin = collectInputs [
    "darwinModules"
    "default"
  ];
  inputModulesNixOS = collectInputs [
    "nixosModules"
    "default"
  ];
  inputOverlays = collectInputs [
    "overlays"
    "default"
  ];
  customOverlays = import ./overlays.nix inputs;

  overlayModule = {
    nixpkgs.overlays = inputOverlays ++ customOverlays;
  };

  modulesCommon = collectNix ../modules/common;
  modulesDarwin = collectNix ../modules/darwin;
  modulesNixOS = collectNix ../modules/nixos;

  specialArgs =
    inputs
    // {
      inherit inputs;

      lib = self;
    };
in {
  darwinSystem' = module:
    super.darwinSystem {
      inherit specialArgs;

      modules =
        [
          module
          overlayModule
        ]
        ++ modulesCommon
        ++ modulesDarwin
        ++ inputModulesDarwin;
    };

  nixosSystem' = module:
    super.nixosSystem {
      inherit specialArgs;

      modules =
        [
          module
          overlayModule
          # Allow unfree packages.
          {nixpkgs.config.allowUnfree = true;}
        ]
        ++ modulesCommon
        ++ modulesNixOS
        ++ inputModulesNixOS;
    };
}
