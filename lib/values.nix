_: self: _: let
  inherit (self) merge mkMerge;
in {
  merge =
    mkMerge []
    // {
      __functor = self: next:
        self
        // {
          #---Implementation------
          contents = self.contents ++ [next];
        };
    };

  enabled = merge {enable = true;};
  disabled = merge {enable = false;};
}
