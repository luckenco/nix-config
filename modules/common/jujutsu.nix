{ lib, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager.sharedModules = [
    {
      home.shellAliases = {
        jl = "jj log";
        jd = "jj diff";
        jn = "jj new";
        js = "jj status";
        jds = "jj describe";
      };

      programs.jujutsu = enabled {
        settings = {
          user = {
            name = "Constantin Luckenbach";
            email = "cluckenbach@protonmail.com";
          };
          ui = {
            editor = "nvim";
            diff-formatter = [
              "difft"
              "--color=always"
              "$left"
              "$right"
            ];
            diff-editor = ":builtin";
          };
          signing = {
            behavior = "own";
            backend = "gpg";
          };
        };
      };
    }
  ];
}
