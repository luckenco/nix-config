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
    pkg: builtins.elem (lib.getName pkg) [ "sublimetext4" ]
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
          "${sublimeConfigRoot}/Packages/User/Preferences.sublime-settings".text = builtins.toJSON {
            theme = systemConfig.theme.names.sublime.uiTheme;
            color_scheme = systemConfig.theme.names.sublime.colorScheme;
            theme_font_options = [ "no_italic" ];
            auto_complete = true;
            caret_blink_interval = 0.5;
            caret_extra_bottom = -5;
            caret_extra_top = -5;
            caret_extra_width = 0;
            caret_style = "wide";
            font_face = systemConfig.theme.font.mono;
            font_size = 16;
            font_options = [ "no_italic" ];
            line_padding_top = -1;
            line_padding_bottom = -1;
            highlight_line = false;
            rulers = [ 96 ];
            relative_line_numbers = true;
            default_line_endings = "unix";
            show_line_endings = false;
            tab_size = 4;
            tab_completion = false;
            detect_indentation = false;
            draw_white_space = "none";
            draw_indent_guides = false;
            index_files = true;
            ignored_packages = [ ];
          };
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
