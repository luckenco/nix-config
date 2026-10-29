{ config, ... }:
let
  homeDir = config.my.machine.homeDir;
in
{
  system.defaults.NSGlobalDomain = {
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;

    # Fast key repeat
    InitialKeyRepeat = 15;
    KeyRepeat = 2;

    # Enable press-and-hold accent picker.
    ApplePressAndHoldEnabled = true;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # Faster UI feedback
    NSWindowResizeTime = 0.001;

    # Natural scrolling on
    "com.apple.swipescrolldirection" = true;
  };

  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.15;
    expose-animation-duration = 0.1;
    launchanim = false;
    mineffect = "scale";
    show-process-indicators = true;
    showhidden = true;
    show-recents = false;
    mru-spaces = false;
    tilesize = 48;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    FXPreferredViewStyle = "Nlsv";
    FXDefaultSearchScope = "SCcf";
    FXEnableExtensionChangeWarning = false;
    _FXShowPosixPathInTitle = true;
    _FXSortFoldersFirst = true;
    _FXSortFoldersFirstOnDesktop = true;
    ShowExternalHardDrivesOnDesktop = false;
    ShowHardDrivesOnDesktop = false;
    ShowMountedServersOnDesktop = false;
    ShowRemovableMediaOnDesktop = false;
    ShowPathbar = true;
    ShowStatusBar = true;
    QuitMenuItem = true;
  };

  system.defaults.loginwindow = {
    GuestEnabled = false;
    SHOWFULLNAME = true;
  };

  system.defaults.screencapture = {
    disable-shadow = true;
    include-date = true;
    location = "${homeDir}/Pictures/Screenshots";
    type = "png";
  };

  system.defaults.screensaver = {
    askForPassword = true;
    askForPasswordDelay = 0;
  };

  # nix-darwin applies these to both built-in and Bluetooth trackpads.
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    TrackpadThreeFingerDrag = false;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.finder".WarnOnEmptyTrash = false;
  };
  system.stateVersion = 7;
}
