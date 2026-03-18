{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aerospace
    brave
    orbstack
    pinentry_mac
  ];
}
