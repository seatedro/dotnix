_: self: super: let
  inherit (self) filter hasSuffix;
  inherit (self.filesystem) listFilesRecursive;
in {
  collectNix = path: listFilesRecursive path |> filter (hasSuffix ".nix");

  #---Config Helper------
  configFile = relativePath: ../. + "/.config/${relativePath}";
}
