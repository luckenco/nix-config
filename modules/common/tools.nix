{ lib, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager.sharedModules = [
    {
      programs.bat = enabled { };

      programs.fzf = enabled {
        enableZshIntegration = true;
      };

      programs.direnv = enabled {
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      programs.zoxide = enabled {
        enableZshIntegration = true;
      };

      programs.atuin = enabled {
        enableZshIntegration = true;
      };

      programs.yazi = enabled {
        enableZshIntegration = true;
        shellWrapperName = "y";
      };
    }
  ];
}
