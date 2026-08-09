{ config, inputs, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      # Keep rebuilds deterministic and avoid disruptive cleanup failures.
      # Do Homebrew upgrades explicitly when desired.
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };

    # Keep tools here when Homebrew is newer or nixpkgs is unsuitable.
    brews = [
      "cocoapods"
      "mas"
      "mole" # The nixpkgs package with this name is a different program
    ];

    # Zed is intentionally omitted: install the official app for fresher
    # releases, while modules/darwin/zed.nix manages its settings.
    casks = [
      "anki"
      "codex" # Coding agent - cask, not brew
      "figma"
      "gcloud-cli"
      "ghostty"
      "keyboardcleantool"
      "linear"
      "microsoft-teams"
      "protonvpn"
      "raycast"
      "spotify"
      "sublime-text"
      "telegram"
      "zotero"
    ];

    masApps = {
      "Maccy" = 1527619437;
      "MeetingBar" = 1532419400;
      "Theine" = 955848755;
      "Xcode" = 497799835;
    };
  };

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    autoMigrate = true;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    mutableTaps = false;
  };
}
