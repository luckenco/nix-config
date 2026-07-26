{ lib, ... }:
{
  options.theme = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    default = {
      # Stylix could eventually own Base16 palette generation and supported app
      # targets, but keep this small compatibility layer for tools whose built-in
      # themes use different names for the same scheme.
      names = {
        ghostty = "Gruvbox Dark";
        sublime = {
          colorScheme = "USGC-POLYIMIDE-ST.sublime-color-scheme";
          uiTheme = "Adaptive.sublime-theme";
        };
        zed = "Gruvbox Dark";
        zellij = "gruvbox-dark";
      };

      font = {
        mono = "TX-02";
        size = 14;
      };

      ui = {
        padding = 8;
        opacity = 0.95;
      };
    };
  };
}
