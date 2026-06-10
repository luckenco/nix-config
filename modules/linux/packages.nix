{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      yt-dlp
    ]
    ++ lib.optionals config.isDesktop [
      ghostty
    ];
}
