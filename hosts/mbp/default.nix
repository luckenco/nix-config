{ config, ... }:
let
  machine = config.my.machine;
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Determinate Nix manages the daemon.
  nix.enable = false;

  my.machine = {
    hostName = "mbp";
    userName = "cal";
    homeDir = "/Users/cal";
    repoPath = "/Users/cal/Code/nix-config";
  };

  networking.hostName = machine.hostName;
  system.primaryUser = machine.userName;

  users.users.${machine.userName} = {
    name = machine.userName;
    home = machine.homeDir;
  };

  home-manager.users.${machine.userName} = {
    home = {
      username = machine.userName;
      homeDirectory = machine.homeDir;
      stateVersion = "25.11";
    };

    programs.home-manager.enable = true;
  };
}
