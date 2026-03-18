{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ghostty
    yt-dlp
  ];
}
