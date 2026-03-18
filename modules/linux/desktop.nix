{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) enabled mkIf;
  systemConfig = config;
  c = config.theme.colors;
in
mkIf config.isDesktop {
  home-manager.sharedModules = [
    (
      { config, ... }:
      let
        hmConfig = config;
      in
      {
        xsession = enabled {
          windowManager.i3 = enabled {
            package = pkgs.i3;
            config = {
              bars = [
                {
                  position = "bottom";
                  statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${hmConfig.xdg.configHome}/i3status-rust/config-bottom.toml";
                  colors = {
                    background = "#${c.bg1}";
                    statusline = "#${c.fg}";
                    focusedWorkspace = {
                      border = "#${c.blue}";
                      background = "#${c.blue}";
                      text = "#${c.fg}";
                    };
                    inactiveWorkspace = {
                      border = "#${c.bg1}";
                      background = "#${c.bg1}";
                      text = "#${c.gray}";
                    };
                  };
                  fonts = {
                    names = [ systemConfig.theme.font.mono ];
                    size = systemConfig.theme.font.size * 1.0;
                  };
                }
              ];
              window.border = 0;
              defaultWorkspace = "1";

              startup = [
                {
                  command = "vmware-user-suid-wrapper";
                  notification = false;
                }
                {
                  command = "ghostty";
                  notification = false;
                }
              ];

              keybindings = lib.mkOptionDefault {
                "Mod1+Shift+e" = "exec i3-msg exit";
              };
            };
          };
        };

        programs.i3status-rust = enabled {
          bars.bottom = {
            theme = "gruvbox-dark";
            icons = "awesome6";
            blocks = [
              {
                block = "memory";
                format = " $mem_used/$mem_total ";
              }
              {
                block = "cpu";
                format = " $utilization ";
              }
              {
                block = "disk_space";
                path = "/";
                format = " $available ";
              }
            ];
          };
        };
      }
    )
  ];
}
