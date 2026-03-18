{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    killall
  ];

  programs.zsh.enable = true;

  system.stateVersion = "25.11";
}
