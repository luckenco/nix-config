{ lib, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager.sharedModules = [
    {
      programs.neovim = enabled {
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
    }
  ];
}
