{
  pkgs,
  lib,
  glimpse,
  llm-agents,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      #---Editors------
      vim
      helix
      neovim

      #---Dev Tools------
      go
      rustup
      zig
      nodejs_24
      python3
      gcc
      gnumake
      pkg-config
      bun
      awscli2
      jujutsu
      jjui
      alacritty
      carapace
      postman

      #---Nix Tools------
      alejandra

      #---System------
      zsh
      libiconv
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
      fastfetch
      lldb_21
      llvmPackages_21.libcxxClang
      ouch
      yazi
      obsidian

      #---VCS------
      git
      gh

      #---Media------
      ffmpeg
      imagemagick
      pandoc

      #---Security------
      gnupg
      openssh

      llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
      llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
      llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code

      #---Custom------
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      spotify
      obs-studio
      glimpse.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
