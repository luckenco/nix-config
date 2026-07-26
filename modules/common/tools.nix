{ pkgs, ... }:
{
  home-manager.sharedModules = [
    {
      programs.bat = {
        enable = true;
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        historyWidget.command = "";
      };

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        package = pkgs.direnv.overrideAttrs {
          doCheck = false;
        };
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.atuin = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
      };
    }
  ];
}
