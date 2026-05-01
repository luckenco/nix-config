{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  systemConfig = config;

  sublimeConfigRoot =
    if systemConfig.isDarwin then
      "Library/Application Support/Sublime Text"
    else
      ".config/sublime-text";
in
{
  nixpkgs.config.allowUnfreePredicate = mkIf (config.isLinux && config.isDesktop) (
    pkg: builtins.elem (lib.getName pkg) [ "sublime4" ]
  );

  environment.systemPackages = mkIf (config.isLinux && config.isDesktop) [ pkgs.sublime4 ];

  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      let
        configRoot = "${config.home.homeDirectory}/${sublimeConfigRoot}";
        oldDotfilesRoot = "${config.home.homeDirectory}/Code/.dotfiles/sublime-text/Library/Application Support/Sublime Text";
        oldRelativeRoot = "../../Code/.dotfiles/sublime-text/Library/Application Support/Sublime Text";
      in
      mkIf systemConfig.isDesktop {
        home.activation.unlinkOldSublimeDotfilesLink = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          target=${lib.escapeShellArg configRoot}
          old_dotfiles_root=${lib.escapeShellArg oldDotfilesRoot}
          old_relative_root=${lib.escapeShellArg oldRelativeRoot}

          if [ -L "$target" ]; then
            link_target="$(readlink "$target")"
            if [ "$link_target" = "$old_dotfiles_root" ] || [ "$link_target" = "$old_relative_root" ]; then
              echo "Removing old Sublime Text dotfiles symlink at $target"
              rm "$target"
            fi
          fi
        '';

        home.file = {
          "${sublimeConfigRoot}/Packages/User/Preferences.sublime-settings".source =
            ./sublime/Preferences.sublime-settings;
          "${sublimeConfigRoot}/Packages/USGC-EPITAXY-ST.sublime-color-scheme".source =
            ./sublime/USGC-EPITAXY-ST.sublime-color-scheme;
          "${sublimeConfigRoot}/Packages/USGC-HIGHK-ST.sublime-color-scheme".source =
            ./sublime/USGC-HIGHK-ST.sublime-color-scheme;
          "${sublimeConfigRoot}/Packages/USGC-METALGATE-ST.sublime-color-scheme".source =
            ./sublime/USGC-METALGATE-ST.sublime-color-scheme;
          "${sublimeConfigRoot}/Packages/USGC-POLYIMIDE-ST.sublime-color-scheme".source =
            ./sublime/USGC-POLYIMIDE-ST.sublime-color-scheme;
          "${sublimeConfigRoot}/Packages/USGC-RETICLE-ST.sublime-color-scheme".source =
            ./sublime/USGC-RETICLE-ST.sublime-color-scheme;
        };
      }
    )
  ];
}
