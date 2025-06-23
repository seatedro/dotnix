_: self: super:
let
  inherit (self) filter hasSuffix;
  inherit (self.filesystem) listFilesRecursive;
in
{
  collectNix = path: listFilesRecursive path |> filter (hasSuffix ".nix");

  # Helper function to reference config files from flake root
  configFile = relativePath: ../. + "/.config/${relativePath}";
}
