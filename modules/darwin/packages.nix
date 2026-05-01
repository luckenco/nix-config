{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    orbstack
    pinentry_mac
  ];
}
