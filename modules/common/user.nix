{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.isLinux {
  # Linux user: morpheus
  users.users.morpheus = {
    isNormalUser = true;
    description = "morpheus";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  home-manager.users.morpheus = {
    home = {
      username = "morpheus";
      homeDirectory = "/home/morpheus";
      stateVersion = "25.11";
    };

    programs.home-manager.enable = true;
  };
}
