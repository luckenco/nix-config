{ config, lib, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager.sharedModules = [
    {
      # Git aliases (cross-shell)
      home.shellAliases = {
        g = "git";
        ga = "git add";
        gaa = "git add ./";
        gc = "git commit";
        gca = "git commit --amend --no-edit";
        gcm = "git commit --message";
        gp = "git push";
        gpf = "git push --force-with-lease";
        gpl = "git pull";
        gplr = "git pull --rebase";
        gpls = "git pull --recurse-submodules";
        gst = "git stash";
        gstp = "git stash pop";
        gs = "git switch";
        gsc = "git switch -c";
        gco = "git checkout";
        grb = "git rebase";
        grbi = "git rebase --interactive";
        gd = "git diff";
        gds = "git diff --staged";
        gsh = "git show --ext-diff";
        gl = "git log";
        glo = "git log --oneline --graph";
        glp = "git log --patch --ext-diff";
        gstat = "git status";

        # Tools
        gui = "gitui";
      };

      programs.git = enabled {
        signing = {
          key = "7B0964DD92945BF9";
          signByDefault = true;
        };

        settings = {
          user.name = "Constantin Luckenbach";
          user.email = "cluckenbach@protonmail.com";

          commit.gpgsign = true;
          tag.gpgsign = true;
          core.ignorecase = false;
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          rebase.autoStash = true;
          rebase.autoSquash = true;
          rerere.enabled = true;
        }
        // lib.optionalAttrs config.isDarwin {
          gpg.program = "/etc/profiles/per-user/${config.system.primaryUser or "cal"}/bin/gpg";
        };
      };

      programs.difftastic = enabled {
        git.enable = true;
        options.background = "dark";
      };
    }
  ];
}
