{ pkgs, ... }:

{
  # Common Linux system packages that were scattered across modules
  environment.systemPackages = with pkgs; [
    # Base system tools (from sys.nix)
    nixfmt-rfc-style
    nixd
    xclip

    # Applications
    brave
    vesktop
    
    # File management (common across desktop modules)
    xfce.thunar
    xfce.thunar-volman
    xfce.tumbler
    gvfs
    
    # System applications
    wineWowPackages.stable
    sdl3
  ];
} 