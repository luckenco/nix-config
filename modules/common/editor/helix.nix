{ lib, ... }: let
  inherit (lib) enabled;
in {
  home-manager.sharedModules = [{
    programs.helix = enabled {
      settings = {
        theme = "gruvbox_dark_hard";

        editor = {
          line-number = "relative";
          mouse       = false;

          auto-save.focus-lost = true;

          cursor-shape = {
            insert = "bar";
            select = "underline";
          };

          file-picker.hidden = false;

          inline-diagnostics = {
            cursor-line = "warning";
            other-lines = "error";
          };

          lsp.display-inlay-hints = true;

          soft-wrap.enable = true;

          statusline = {
            left   = [ "mode" "spinner" ];
            center = [ "file-name" "file-type" ];
            right  = [ "diagnostics" "selections" "position" "file-line-ending" ];

            mode = {
              insert = "INSERT";
              normal = "NORMAL";
              select = "SELECT";
            };
          };

          indent-guides = {
            render    = true;
            character = "╎";
          };
        };

        keys.insert.j = {
          k   = "normal_mode";
          esc = [ "collapse_selection" "normal_mode" ];
        };

        # Temporary nvim-like motions while transitioning to Helix.
        keys.normal = {
          h = [ "collapse_selection" "move_char_left" ];
          j = [ "collapse_selection" "move_line_down" ];
          k = [ "collapse_selection" "move_line_up" ];
          l = [ "collapse_selection" "move_char_right" ];
          w = [ "collapse_selection" "move_next_word_start" ];
          b = [ "collapse_selection" "move_prev_word_start" ];
          e = [ "collapse_selection" "move_next_word_end" ];
          "0" = [ "collapse_selection" "goto_line_start" ];
          "$" = [ "collapse_selection" "goto_line_end" ];
        };
      };
    };
  }];
}
