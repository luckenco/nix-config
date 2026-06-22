{ config, lib, ... }:

let
  dockDefaults = builtins.removeAttrs config.system.defaults.dock [ "expose-group-by-app" ];
  hasDockDefaults = lib.any (value: value != null) (builtins.attrValues dockDefaults);
  user = lib.escapeShellArg config.system.primaryUser;
in
{
  system.activationScripts.launchd.text = lib.mkIf hasDockDefaults (
    lib.mkBefore ''
      # nix-darwin currently applies system.defaults.dock by writing defaults and
      # then running `killall ... Dock`; it relies on launchd to respawn the Dock.
      # On this machine launchd can leave com.apple.Dock.agent exited instead
      # (`pended nondemand spawn = semaphore`). Keep this in the launchd phase as
      # a narrow recovery hook, and revisit/remove it once nix-darwin uses a
      # launchd-aware Dock restart or macOS reliably respawns Dock again.
      primary_uid="$(id -u -- ${user})"
      dock_agent="gui/$primary_uid/com.apple.Dock.agent"

      if ! launchctl print "$dock_agent" 2>/dev/null | grep -q 'state = running'; then
        echo >&2 "starting Dock after nix-darwin defaults restart..."
        launchctl asuser "$primary_uid" launchctl kickstart "$dock_agent" || true
      fi
    ''
  );
}
