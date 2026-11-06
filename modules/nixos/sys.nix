{ pkgs, ... }:
let
  berkeley-mono = import ../../fonts/berkeley-mono.nix {
    inherit pkgs;
    inherit (pkgs) lib;
  };
in
{
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  environment.variables.EDITOR = "nvim";

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.geist-mono
    pkgs.geist-font
    berkeley-mono
  ];

  hardware = {
    graphics.enable = true;
    keyboard.zsa.enable = true;
  };
  environment.systemPackages = with pkgs; [
    nixfmt
    nixd
    git
    wget
    curl
    tree
    alacritty
    xclip
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.kio-extras
    kdePackages.kio-fuse
    kdePackages.ffmpegthumbs
    tumbler
    gvfs
    keymapp

    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  ];

  programs.fish.enable = false;

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.envfs.enable = true;
  services.tailscale.enable = true;
  services.desktopManager.plasma6.enable = false;

  system.stateVersion = "25.11";
}
