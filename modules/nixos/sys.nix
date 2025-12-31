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
    nixfmt-rfc-style
    nixd
    git
    wget
    curl
    tree
    brave
    alacritty
    xclip
    code-cursor
    thunar
    thunar-volman
    tumbler
    gvfs
    keymapp

    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')

    (makeDesktopItem {
      name = "1password";
      desktopName = "1Password";
      exec = "1password --ozone-platform-hint=x11 %U";
      terminal = false;
      type = "Application";
      icon = "1password";
      comment = "Password manager and secure wallet";
      mimeTypes = [ "x-scheme-handler/onepassword" ];
      categories = [ "Office" ];
      startupWMClass = "1Password";
    })
  ];

  programs.fish.enable = false;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "ro" ];
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.tailscale.enable = true;
  services.desktopManager.plasma6.enable = false;

  system.stateVersion = "25.11";
}
