inputs: self: super: let
  fs = import ./fs.nix inputs self super;
  option = import ./option.nix inputs self super;
  sys = import ./sys.nix inputs self super;
  values = import ./values.nix inputs self super;
in
  fs // option // sys // values
