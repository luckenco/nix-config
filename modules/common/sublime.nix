{ config, ... }:
let
  systemConfig = config;
  sublimeConfigRoot = "Library/Application Support/Sublime Text";
  sublimeUserRoot = "${sublimeConfigRoot}/Packages/User";
in
{
  home-manager.sharedModules = [
    ({
      home.file = {
        "${sublimeUserRoot}/Preferences.sublime-settings".text = builtins.toJSON {
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
        "${sublimeUserRoot}/USGC-EPITAXY-ST.sublime-color-scheme".source =
          ./sublime/USGC-EPITAXY-ST.sublime-color-scheme;
        "${sublimeUserRoot}/USGC-HIGHK-ST.sublime-color-scheme".source =
          ./sublime/USGC-HIGHK-ST.sublime-color-scheme;
        "${sublimeUserRoot}/USGC-METALGATE-ST.sublime-color-scheme".source =
          ./sublime/USGC-METALGATE-ST.sublime-color-scheme;
        "${sublimeUserRoot}/USGC-POLYIMIDE-ST.sublime-color-scheme".source =
          ./sublime/USGC-POLYIMIDE-ST.sublime-color-scheme;
        "${sublimeUserRoot}/USGC-RETICLE-ST.sublime-color-scheme".source =
          ./sublime/USGC-RETICLE-ST.sublime-color-scheme;
      };
    })
  ];
}
