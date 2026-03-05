{
  programs.zsh.enable = true;

  # Increase file descriptor limit for Nix operations
  system.activationScripts.set-ulimit.text = ''
    launchctl limit maxfiles 65536 200000
  '';
}
