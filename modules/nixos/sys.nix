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

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    berkeley-mono
  ];

  hardware.graphics.enable = true;
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    nixd
    git
    wget
    curl
    tree
    brave
    alacritty
    xclip
    zed-editor
    code-cursor
    xfce.thunar
    xfce.thunar-volman
    xfce.tumbler
    pkgs.gvfs

    # For hypervisors that support auto-resizing, this script forces it.
    # I've noticed not everyone listens to the udev events so this is a hack.
    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  ];

  programs.fish.enable = false;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.tailscale.enable = true;
  services.desktopManager.plasma6.enable = false;

  system.stateVersion = "25.11";
}
