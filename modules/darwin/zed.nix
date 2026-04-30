{ config, pkgs, ... }:
{
  home-manager.sharedModules = [
    {
      # Install Zed from https://zed.dev/download and let the app auto-update.
      # nixpkgs/Homebrew casks can lag upstream; Home Manager owns settings only.
      xdg.configFile."zed/settings.json".text = builtins.toJSON (
        with config.theme;
        {
          auto_install_extensions = {
            dockerfile = true;
            make = true;
            sql = true;
          };

          base_keymap = "VSCode";

          features.edit_prediction_provider = "zed";

          buffer_font_family = font.mono;
          cursor_blink = false;

          scrollbar.show = "never";

          tab_bar.show_nav_history_buttons = false;

          tabs = {
            file_icons = true;
            git_status = true;
            show_diagnostics = "errors";
          };

          toolbar.quick_actions = false;

          inlay_hints.enabled = true;

          languages.Python = {
            language_servers = [
              "ty"
              "ruff"
              "!basedpyright"
            ];
            format_on_save = "on";
            formatter = [
              { code_action = "source.fixAll.ruff"; }
              { code_action = "source.organizeImports.ruff"; }
              { language_server.name = "ruff"; }
            ];
          };

          lsp = {
            rust_analyzer.initialization_options.checkOnSave.command = "clippy";
            ty = {
              binary = {
                path = "${pkgs.ty}/bin/ty";
                arguments = [ "server" ];
              };
            };
            ruff.initialization_options.settings.lineLength = 80;
          };

          theme = "Gruvbox Dark";
          vim_mode = true;

          project_panel = {
            dock = "right";
            indent_size = 18;
          };

          disable_ai = true;

          calls.mute_on_join = true;

          ui_font_size = 15;
          ui_font_family = font.mono;

          vertical_scroll_margin = 8;
          relative_line_numbers = true;

          terminal = {
            font_family = "MonoLisa Nerd Font";
            font_size = 14;
          };

          git.inline_blame = {
            enabled = true;
            delay_ms = 480;
            show_commit_summary = true;
          };

          edit_predictions.mode = "subtle";
        }
      );
    }
  ];
}
