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

    # Natural scrolling off
    "com.apple.swipescrolldirection" = false;
  };

  system.defaults.dock = {
    autohide = true;
    showhidden = true;
    show-recents = false;
    mru-spaces = false;
    tilesize = 48;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    FXPreferredViewStyle = "Nlsv";
    _FXShowPosixPathInTitle = true;
    _FXSortFoldersFirst = true;
    ShowPathbar = true;
    ShowStatusBar = true;
    QuitMenuItem = true;
  };

  system.defaults.CustomSystemPreferences."com.apple.desktopservices" = {
    DSDontWriteNetworkStores = true;
    DSDontWriteUSBStores = true;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.dock" = {
      autohide-delay = 0.0;
      autohide-time-modifier = 0.15;
      expose-animation-duration = 0.1;
      launchanim = false;
      mineffect = "scale";
      show-process-indicators = true;
    };

    "com.apple.finder" = {
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      WarnOnEmptyTrash = false;
      _FXSortFoldersFirstOnDesktop = true;
    };

    "com.apple.screencapture" = {
      disable-shadow = true;
      include-date = true;
      location = "${homeDir}/Pictures/Screenshots";
      type = "png";
    };

    "com.apple.screensaver" = {
      askForPassword = 1;
      askForPasswordDelay = 0;
    };

    "com.apple.loginwindow" = {
      GuestEnabled = false;
      SHOWFULLNAME = true;
    };

    "com.apple.AppleMultitouchTrackpad" = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };

    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };
  };
  system.stateVersion = 6;
}
