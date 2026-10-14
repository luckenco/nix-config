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
        package = pkgs.atuin.overrideAttrs (
          old:
          assert pkgs.lib.assertMsg (!pkgs.stdenv.hostPlatform.isDarwin || old.version == "18.23.0")
            "Atuin changed: remove the NOSYSBASHRC override in modules/common/tools.nix and run just check. Keep it only if the Bash tests still fail, then update this version guard.";
          {
            # Keep the host's /etc/bashrc from replacing the isolated test PATH.
            # FreshEnv clears inherited variables, so set NOSYSBASHRC in the harness.
            postPatch =
              (old.postPatch or "")
              + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
                substituteInPlace crates/atuin/tests/common/mod.rs \
                  --replace-fail '("TERM".into(), "xterm-256color".into()),' \
                    '("TERM".into(), "xterm-256color".into()), ("NOSYSBASHRC".into(), "1".into()),'
              '';
          }
        );
      };

      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
      };
    }
  ];
}
