{ pkgs, glimpse, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    helix
    neovim
    zed-editor
    code-cursor

    # Development tools
    go
    rustup
    zig
    nodejs_24
    bun
    awscli2
    jujutsu

    # Nix tools (additional to what's in nix.nix)
    alejandra

    # System tools
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

    # Version control
    git
    gh

    # Media and utilities
    ffmpeg
    imagemagick
    pandoc

    # Security tools
    gnupg
    openssh

    # Custom packages
    glimpse.packages.${pkgs.system}.default
  ];

}
