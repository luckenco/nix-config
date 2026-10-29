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
      "planetscale/tap/pscale"
    ];

    # Zed is intentionally omitted: install the official app for fresher
    # releases, while modules/darwin/zed.nix manages its settings.
    casks = [
      "anki"
      "blockblock"
      "codex" # Coding agent - cask, not brew
      "figma"
      "gcloud-cli"
      "ghostty"
      "keyboardcleantool"
      "linear"
      "oversight"
      "protonvpn"
      "spotify"
      "sublime-text"
      "telegram"
      "whatsyoursign" # Stages a manual installer; see README for setup.
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
      "planetscale/homebrew-tap" = inputs.planetscale-tap;
    };

    trust.formulae = [ "planetscale/tap/pscale" ];
    mutableTaps = false;
  };
}
