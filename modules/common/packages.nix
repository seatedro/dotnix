{ pkgs, glimpse, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    helix
    neovim

    # Development tools
    go
    rustup
    zig
    nodejs_24
    bun
    awscli2
    jujutsu
    lldb
    alacritty
    carapace

    # Nix tools (additional to what's in nix.nix)
    alejandra

    # System tools
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
    clang
    ouch
    yazi
    spotify
    obsidian

    # Version control
    git
    gh

    # Media and utilities
    ffmpeg
    imagemagick
    pandoc
    obs-studio

    # Security tools
    gnupg
    openssh

    # Custom packages
    glimpse.packages.${pkgs.system}.default
  ];

}
