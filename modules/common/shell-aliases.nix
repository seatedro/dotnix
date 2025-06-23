{ pkgs, ... }:

{
  environment.shellAliases = {
    nb = "nix build";
    nf = "nix flake";
    ns = "nix shell";
    nr = "nix run";
    nd = "nix develop";

    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gpl = "git pull";
    gco = "git checkout";
    gb = "git branch";
    gl = "git log --oneline --graph";
    gdiff = "git diff";

    # Jujutsu aliases
    jd = "jj desc";
    jf = "jj git fetch";
    jn = "jj new";
    jp = "jj git push";
    js = "jj st";

    # Better ls with eza
    ls = "eza";
    la = "eza --all";
    lla = "eza --long --all";
    ll = "eza -l";
    l = "eza -la";

    cat = "bat";
    grep = "rg";
    find = "fd";
    vim = "nvim";

    cp = "cp --recursive --verbose --progress";
    mk = "mkdir";
    mv = "mv --verbose";
    rm = "rm --recursive --verbose";
  };

  environment.shells = with pkgs; [
    fish
    nushell
  ];
}
