{
  programs.zsh.enable = true;

  environment.variables = {
    CC = "/usr/bin/clang";
    CXX = "/usr/bin/clang++";
    CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER = "/usr/bin/clang";
  };

  # Increase file descriptor limit for Nix operations
  system.activationScripts.set-ulimit.text = ''
    launchctl limit maxfiles 65536 200000
  '';
}
