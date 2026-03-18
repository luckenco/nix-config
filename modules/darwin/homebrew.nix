{
  homebrew-core,
  homebrew-cask,
  homebrew-twilio,
  config,
  lib,
  ...
}:
let
  inherit (lib) enabled;
in
{
  homebrew = enabled {
    onActivation = {
      # Keep rebuilds deterministic and avoid disruptive cleanup failures.
      # Do Homebrew upgrades explicitly when desired.
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };

    # TODO: Periodically check if these become available/fixed in nixpkgs
    brews = [
      "azure-cli" # nixpkgs build currently failing on darwin
      "gitui" # Broken in nixpkgs on aarch64-darwin
      "livekit-cli"
      "mas"
      "mole"
      "opencode" # Coding agent - homebrew updates faster than nixpkgs
      "twilio"
      "yt-dlp" # nixpkgs pull-in currently broken on darwin via python jeepney/secretstorage chain
    ];

    casks = [
      "anki"
      "claude-code" # Coding agent - homebrew updates faster than nixpkgs
      "codex" # Coding agent - cask, not brew
      "figma"
      "ghostty"
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

  nix-homebrew = enabled {
    user = config.system.primaryUser;
    autoMigrate = true;

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "twilio/homebrew-brew" = homebrew-twilio;
    };

    mutableTaps = true;
  };
}
