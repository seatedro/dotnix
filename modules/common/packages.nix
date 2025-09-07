{
  pkgs,
  glimpse,
  ...
}: {
  environment.systemPackages = with pkgs; [
    #---Editors------
    vim
    helix
    neovim

    #---Dev Tools------
    go
    rustup
    zig
    nodejs_24
    bun
    awscli2
    jujutsu
    alacritty
    carapace

    #---Nix Tools------
    alejandra

    #---System------
    zsh
    fish
    nushell
    btop
    ripgrep
    fd
    bat
    eza
    zoxide
    fzf
    jq
    chezmoi
    atuin
    tmux
    tree
    htop
    curl
    wget
    unzip
    rsync
    neofetch
    fastfetch
    lldb_21
    llvmPackages_21.libcxxClang
    ouch
    yazi
    spotify
    obsidian

    #---VCS------
    git
    gh

    #---Media------
    ffmpeg
    imagemagick
    pandoc
    obs-studio

    #---Security------
    gnupg
    openssh

    #---Custom------
    glimpse.packages.${pkgs.system}.default
  ];
}
