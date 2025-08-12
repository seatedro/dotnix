{ pkgs, ... }:

let
  berkeley-mono = import ../../fonts/berkeley-mono.nix {
    inherit pkgs;
    inherit (pkgs) lib;
  };
in
{
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  # For hypervisors that support auto-resizing, this script forces it.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "xrandr-auto" ''
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
