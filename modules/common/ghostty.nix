{ config, lib, ... }:
let
  inherit (lib) enabled mkIf;
in
{
  home-manager.sharedModules = [
    {
      programs.ghostty = enabled {
        # Don't install Ghostty on Darwin (installed via Homebrew)
        package = mkIf config.isDarwin null;

        settings = with config.theme; {
          font-family = font.mono;
          font-size = font.size;
          font-thicken = true;
          theme = "Gruvbox Dark";

          window-height = 48;
          window-width = 140;

          #window-decoration = "none";
          gtk-titlebar = false;

          window-padding-x = 12;
          window-padding-y = ui.padding - 2;
          cursor-style = "bar";
          cursor-style-blink = false;

          background-opacity = ui.opacity;
          background-blur-radius = 20;
          macos-non-native-fullscreen = "visible-menu";
          macos-option-as-alt = "left";

          mouse-hide-while-typing = true;
          mouse-scroll-multiplier = 2;

          quit-after-last-window-closed = false;
          confirm-close-surface = true;

          keybind = [
            "super+c=copy_to_clipboard"
            "super+v=paste_from_clipboard"
            "super+shift+c=copy_to_clipboard"
            "super+shift+v=paste_from_clipboard"
            "super+equal=increase_font_size:1"
            "super+minus=decrease_font_size:1"
            "super+zero=reset_font_size"
            "super+q=unbind"
            "super+shift+comma=reload_config"
            "super+k=clear_screen"
            "super+n=new_window"
            "super+w=close_surface"
            "super+shift+w=unbind"
            "super+alt+w=close_tab:this"
            "super+alt+shift+w=unbind"
            "super+t=new_tab"
            "super+shift+left_bracket=previous_tab"
            "super+shift+right_bracket=next_tab"
            "super+d=new_split:right"
            "super+shift+d=new_split:down"
            "super+right_bracket=goto_split:next"
            "super+left_bracket=goto_split:previous"
            # Previous Keybinds:
            #   super+shift+r=reload_config
            #   shift+enter=text:\n (removed - breaks Shift+Enter in apps like Claude Code)
          ];
        };
      };
    }
  ];
}
