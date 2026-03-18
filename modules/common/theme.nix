{ lib, ... }:
let
  inherit (lib) mkValue;
in
{
  options.theme = mkValue {
    name = "gruvbox-dark";

    # Gruvbox Dark Hard palette
    colors = {
      bg = "1d2021"; # hard contrast bg
      bg1 = "282828"; # softer bg
      bg2 = "3c3836";
      bg3 = "504945";
      fg = "ebdbb2";
      fg2 = "d5c4a1";
      gray = "928374";
      red = "fb4934";
      green = "b8bb26";
      yellow = "fabd2f";
      blue = "83a598";
      purple = "d3869b";
      aqua = "8ec07c";
      orange = "fe8019";
    };

    font = {
      mono = "TX-02";
      size = 14;
    };

    ui = {
      cornerRadius = 4;
      borderWidth = 2;
      padding = 8;
      opacity = 0.95;
    };
  };
}
