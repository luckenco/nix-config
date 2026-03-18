{ lib, pkgs, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager.sharedModules = [
    {
      programs.zellij = enabled {
        enableZshIntegration = false;

        settings = {
          theme = "gruvbox-dark";
          default_layout = "missioncontrol";
          show_startup_tips = false;
        };

        layouts.missioncontrol = ''
          layout {
              default_tab_template {
                  pane size=1 borderless=true {
                      plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                          format_left   "{mode} {session}"
                          format_center "{tabs}"
                          format_right  "{datetime}"
                      }
                  }
                  children
              }

              tab focus=true {
                  pane split_direction="vertical" {
                      pane command="codex" size="30%"
                      pane focus=true size="42%"
                      pane size="28%" split_direction="horizontal" {
                          pane command="bash" {
                              args "-c" "if jj root &>/dev/null; then jj status; else git status; fi; exec $SHELL"
                          }
                          pane command="bash" {
                              args "-c" "if jj root &>/dev/null; then jj log; else git log --oneline -20; fi; exec $SHELL"
                          }
                      }
                  }
              }
          }
        '';

        extraConfig = ''
          keybinds clear-defaults=true {
              locked {
                  bind "Ctrl g" { SwitchToMode "Normal"; }
              }
              pane {
                  bind "Left" { MoveFocus "Left"; }
                  bind "Down" { MoveFocus "Down"; }
                  bind "Up" { MoveFocus "Up"; }
                  bind "Right" { MoveFocus "Right"; }
                  bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
                  bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
                  bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
                  bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                  bind "h" { MoveFocus "Left"; }
                  bind "i" { TogglePanePinned; SwitchToMode "Normal"; }
                  bind "j" { MoveFocus "Down"; }
                  bind "k" { MoveFocus "Up"; }
                  bind "l" { MoveFocus "Right"; }
                  bind "n" { NewPane; SwitchToMode "Normal"; }
                  bind "p" { SwitchFocus; }
                  bind "Ctrl p" { SwitchToMode "Normal"; }
                  bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
                  bind "s" { NewPane "stacked"; SwitchToMode "Normal"; }
                  bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
                  bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
              }
              tab {
                  bind "Left" { GoToPreviousTab; }
                  bind "Down" { GoToNextTab; }
                  bind "Up" { GoToPreviousTab; }
                  bind "Right" { GoToNextTab; }
                  bind "1" { GoToTab 1; SwitchToMode "Normal"; }
                  bind "2" { GoToTab 2; SwitchToMode "Normal"; }
                  bind "3" { GoToTab 3; SwitchToMode "Normal"; }
                  bind "4" { GoToTab 4; SwitchToMode "Normal"; }
                  bind "5" { GoToTab 5; SwitchToMode "Normal"; }
                  bind "6" { GoToTab 6; SwitchToMode "Normal"; }
                  bind "7" { GoToTab 7; SwitchToMode "Normal"; }
                  bind "8" { GoToTab 8; SwitchToMode "Normal"; }
                  bind "9" { GoToTab 9; SwitchToMode "Normal"; }
                  bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
                  bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
                  bind "b" { BreakPane; SwitchToMode "Normal"; }
                  bind "h" { GoToPreviousTab; }
                  bind "j" { GoToNextTab; }
                  bind "k" { GoToPreviousTab; }
                  bind "l" { GoToNextTab; }
                  bind "n" { NewTab; SwitchToMode "Normal"; }
                  bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                  bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
                  bind "Ctrl t" { SwitchToMode "Normal"; }
                  bind "x" { CloseTab; SwitchToMode "Normal"; }
                  bind "Tab" { ToggleTab; }
              }
              resize {
                  bind "Left" { Resize "Increase Left"; }
                  bind "Down" { Resize "Increase Down"; }
                  bind "Up" { Resize "Increase Up"; }
                  bind "Right" { Resize "Increase Right"; }
                  bind "+" { Resize "Increase"; }
                  bind "-" { Resize "Decrease"; }
                  bind "=" { Resize "Increase"; }
                  bind "H" { Resize "Decrease Left"; }
                  bind "J" { Resize "Decrease Down"; }
                  bind "K" { Resize "Decrease Up"; }
                  bind "L" { Resize "Decrease Right"; }
                  bind "h" { Resize "Increase Left"; }
                  bind "j" { Resize "Increase Down"; }
                  bind "k" { Resize "Increase Up"; }
                  bind "l" { Resize "Increase Right"; }
                  bind "Ctrl n" { SwitchToMode "Normal"; }
              }
              move {
                  bind "Left" { MovePane "Left"; }
                  bind "Down" { MovePane "Down"; }
                  bind "Up" { MovePane "Up"; }
                  bind "Right" { MovePane "Right"; }
                  bind "h" { MovePane "Left"; }
                  bind "Ctrl m" { SwitchToMode "Normal"; }
                  bind "j" { MovePane "Down"; }
                  bind "k" { MovePane "Up"; }
                  bind "l" { MovePane "Right"; }
                  bind "n" { MovePane; }
                  bind "p" { MovePaneBackwards; }
                  bind "Tab" { MovePane; }
              }
              scroll {
                  bind "e" { EditScrollback; SwitchToMode "Normal"; }
                  bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
              }
              search {
                  bind "c" { SearchToggleOption "CaseSensitivity"; }
                  bind "n" { Search "Down"; }
                  bind "o" { SearchToggleOption "WholeWord"; }
                  bind "p" { Search "Up"; }
                  bind "w" { SearchToggleOption "Wrap"; }
              }
              session {
                  bind "a" {
                      LaunchOrFocusPlugin "zellij:about" {
                          floating true
                          move_to_focused_tab true
                      }
                      SwitchToMode "Normal"
                  }
                  bind "c" {
                      LaunchOrFocusPlugin "configuration" {
                          floating true
                          move_to_focused_tab true
                      }
                      SwitchToMode "Normal"
                  }
                  bind "Ctrl o" { SwitchToMode "Normal"; }
                  bind "p" {
                      LaunchOrFocusPlugin "plugin-manager" {
                          floating true
                          move_to_focused_tab true
                      }
                      SwitchToMode "Normal"
                  }
                  bind "w" {
                      LaunchOrFocusPlugin "session-manager" {
                          floating true
                          move_to_focused_tab true
                      }
                      SwitchToMode "Normal"
                  }
              }
              shared_except "locked" {
                  // Pass Shift+Enter to apps (workaround for zellij-org/zellij#4159)
                  bind "Shift Enter" { Write 27 91 49 51 59 50 117; }

                  // Pane navigation: Ctrl + h/j/k/l
                  bind "Ctrl h" { MoveFocus "Left"; }
                  bind "Ctrl j" { MoveFocus "Down"; }
                  bind "Ctrl k" { MoveFocus "Up"; }
                  bind "Ctrl l" { MoveFocus "Right"; }

                  // Move panes: Ctrl+Shift + h/j/k/l (destructive/moving)
                  bind "Ctrl H" { MovePane "Left"; }
                  bind "Ctrl J" { MovePane "Down"; }
                  bind "Ctrl K" { MovePane "Up"; }
                  bind "Ctrl L" { MovePane "Right"; }

                  // Resize panes: Ctrl+Alt + h/j/k/l
                  bind "Ctrl Alt h" { Resize "Increase Left"; }
                  bind "Ctrl Alt j" { Resize "Increase Down"; }
                  bind "Ctrl Alt k" { Resize "Increase Up"; }
                  bind "Ctrl Alt l" { Resize "Increase Right"; }
                  bind "Ctrl Alt H" { Resize "Decrease Left"; }
                  bind "Ctrl Alt J" { Resize "Decrease Down"; }
                  bind "Ctrl Alt K" { Resize "Decrease Up"; }
                  bind "Ctrl Alt L" { Resize "Decrease Right"; }

                  // Floating pane toggle
                  bind "Alt f" { ToggleFloatingPanes; }

                  // Lock mode
                  bind "Ctrl g" { SwitchToMode "Locked"; }

                  // Quit
                  bind "Ctrl q" { Quit; }
              }
              shared_except "locked" "session" {
                  bind "Ctrl o" { SwitchToMode "Session"; }
              }
              shared_except "locked" "scroll" "search" "tmux" {
                  bind "Ctrl b" { SwitchToMode "Tmux"; }
              }
              shared_except "locked" "scroll" "search" {
                  bind "Ctrl s" { SwitchToMode "Scroll"; }
              }
              shared_except "locked" "tab" {
                  bind "Ctrl t" { SwitchToMode "Tab"; }
              }
              shared_except "locked" "pane" {
                  bind "Ctrl p" { SwitchToMode "Pane"; }
              }
              shared_except "locked" "resize" {
                  bind "Ctrl n" { SwitchToMode "Resize"; }
              }
              shared_except "Normal" "locked" "EnterSearch" {
                  bind "Enter" { SwitchToMode "Normal"; }
              }
              shared_except "Normal" "locked" "EnterSearch" "RenameTab" "RenamePane" {
                  bind "Esc" { SwitchToMode "Normal"; }
              }
              shared_among "pane" "tmux" {
                  bind "x" { CloseFocus; SwitchToMode "Normal"; }
              }
              shared_among "scroll" "search" {
                  bind "PageDown" { PageScrollDown; }
                  bind "PageUp" { PageScrollUp; }
                  bind "Left" { PageScrollUp; }
                  bind "Down" { ScrollDown; }
                  bind "Up" { ScrollUp; }
                  bind "Right" { PageScrollDown; }
                  bind "Ctrl b" { PageScrollUp; }
                  bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                  bind "d" { HalfPageScrollDown; }
                  bind "Ctrl f" { PageScrollDown; }
                  bind "h" { PageScrollUp; }
                  bind "j" { ScrollDown; }
                  bind "k" { ScrollUp; }
                  bind "l" { PageScrollDown; }
                  bind "Ctrl s" { SwitchToMode "Normal"; }
                  bind "u" { HalfPageScrollUp; }
              }
              EnterSearch {
                  bind "Ctrl c" { SwitchToMode "Scroll"; }
                  bind "Esc" { SwitchToMode "Scroll"; }
                  bind "Enter" { SwitchToMode "Search"; }
              }
              RenameTab {
                  bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
              }
              shared_among "RenameTab" "RenamePane" {
                  bind "Ctrl c" { SwitchToMode "Normal"; }
              }
              RenamePane {
                  bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
              }
              shared_among "session" "tmux" {
                  bind "d" { Detach; }
              }
              tmux {
                  bind "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
                  bind "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
                  bind "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
                  bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
                  bind "Space" { NextSwapLayout; }
                  bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
                  bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
                  bind "," { SwitchToMode "RenameTab"; }
                  bind "[" { SwitchToMode "Scroll"; }
                  bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
                  bind "c" { NewTab; SwitchToMode "Normal"; }
                  bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
                  bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
                  bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
                  bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
                  bind "n" { GoToNextTab; SwitchToMode "Normal"; }
                  bind "o" { FocusNextPane; }
                  bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
                  bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
              }
          }

          plugins {
              about location="zellij:about"
              compact-bar location="zellij:compact-bar"
              configuration location="zellij:configuration"
              filepicker location="zellij:strider" {
                  cwd "/"
              }
              plugin-manager location="zellij:plugin-manager"
              session-manager location="zellij:session-manager"
              status-bar location="zellij:status-bar"
              strider location="zellij:strider"
              tab-bar location="zellij:tab-bar"
              welcome-screen location="zellij:session-manager" {
                  welcome_screen true
              }
          }

          load_plugins {
          }

          web_client {
              font "monospace"
          }
        '';
      };
    }
  ];
}
