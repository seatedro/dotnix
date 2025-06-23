{
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      "com.apple.swipescrolldirection" = false;
    };
  };
  security.pam.services.sudo_local.touchIdAuth = true;
}
