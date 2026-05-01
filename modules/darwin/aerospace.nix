{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      let
        aerospace = lib.getExe config.programs.aerospace.package;
      in
      {
        # AeroSpace tiling window manager config
        # https://nikitabobko.github.io/AeroSpace/
        programs.aerospace = {
          enable = true;

          launchd.enable = true;

          settings = {
            after-startup-command = [ ];

            enable-normalization-flatten-containers = true;
            enable-normalization-opposite-orientation-for-nested-containers = true;

            accordion-padding = 30;
            default-root-container-layout = "tiles";
            default-root-container-orientation = "auto";

            on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

            automatically-unhide-macos-hidden-apps = false;

            key-mapping.preset = "qwerty";

            gaps = {
              inner = {
                horizontal = 0;
                vertical = 0;
              };
              outer = {
                left = 0;
                bottom = 0;
                top = 0;
                right = 0;
              };
            };

            mode = {
              main.binding = {
                alt-slash = "layout tiles horizontal vertical";
                alt-comma = "layout accordion horizontal vertical";

                alt-h = "focus left";
                alt-j = "focus down";
                alt-k = "focus up";
                alt-l = "focus right";

                alt-shift-h = "move left";
                alt-shift-j = "move down";
                alt-shift-k = "move up";
                alt-shift-l = "move right";

                alt-minus = "resize smart -50";
                alt-equal = "resize smart +50";

                alt-0 = "workspace 0";
                alt-1 = "workspace 1";
                alt-2 = "workspace 2";
                alt-3 = "workspace 3";
                alt-4 = "workspace 4";
                alt-5 = "workspace 5";
                alt-6 = "workspace 6";
                alt-7 = "workspace 7";
                alt-8 = "workspace 8";
                alt-9 = "workspace 9";

                alt-shift-0 = "move-node-to-workspace 0";
                alt-shift-1 = "move-node-to-workspace 1";
                alt-shift-2 = "move-node-to-workspace 2";
                alt-shift-3 = "move-node-to-workspace 3";
                alt-shift-4 = "move-node-to-workspace 4";
                alt-shift-5 = "move-node-to-workspace 5";
                alt-shift-6 = "move-node-to-workspace 6";
                alt-shift-7 = "move-node-to-workspace 7";
                alt-shift-8 = "move-node-to-workspace 8";
                alt-shift-9 = "move-node-to-workspace 9";

                alt-shift-semicolon = "mode service";
              };

              service.binding = {
                esc = [
                  "reload-config"
                  "mode main"
                ];
                r = [
                  "flatten-workspace-tree"
                  "mode main"
                ];
                f = [
                  "layout floating tiling"
                  "mode main"
                ];
                backspace = [
                  "close-all-windows-but-current"
                  "mode main"
                ];

                alt-shift-h = [
                  "join-with left"
                  "mode main"
                ];
                alt-shift-j = [
                  "join-with down"
                  "mode main"
                ];
                alt-shift-k = [
                  "join-with up"
                  "mode main"
                ];
                alt-shift-l = [
                  "join-with right"
                  "mode main"
                ];

                down = "volume down";
                up = "volume up";
                shift-down = [
                  "volume set 0"
                  "mode main"
                ];
              };
            };

            on-window-detected = [
              {
                "if".app-id = "com.brave.Browser";
                run = [ "move-node-to-workspace 1" ];
              }
              {
                "if".app-id = "com.mitchellh.ghostty";
                run = [
                  "layout floating"
                  "move-node-to-workspace 2"
                ];
              }
              {
                "if".app-id = "com.linear";
                run = [ "move-node-to-workspace 3" ];
              }
            ];
          };
        };

        home.file."/.config/aerospace/aerospace.toml".onChange = lib.mkForce ''
          if ${aerospace} list-workspaces --all >/dev/null 2>&1; then
            echo "AeroSpace config changed, reloading..."
            ${aerospace} reload-config || true
          else
            echo "AeroSpace config changed, server is not running; skipping reload."
          fi
        '';
      }
    )
  ];
}
