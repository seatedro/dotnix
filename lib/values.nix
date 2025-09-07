_: self: _: let
  inherit (self) merge mkMerge;
in {
  merge =
    mkMerge []
    // {
      __functor = self: next:
        self
        // {
          # Technically, `contents` is implementation defined
          # but nothing ever happens, so we can rely on this.
          contents = self.contents ++ [next];
        };
    };

  enabled = merge {enable = true;};
  disabled = merge {enable = false;};
}
