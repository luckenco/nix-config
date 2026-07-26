{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.neovim ];

  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      let
        source = "${config.home.homeDirectory}/Code/.dotfiles/nvim/.config/nvim";
        target = "${config.xdg.configHome}/nvim";
      in
      {
        # Replace the old manually-created link before Home Manager takes ownership.
        home.activation.unlinkOldNvimLink = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          target=${lib.escapeShellArg target}
          source=${lib.escapeShellArg source}

          if [ -L "$target" ]; then
            link_target="$(readlink "$target")"
            if [ "$link_target" = "$source" ] || [ "$link_target" = "../Code/.dotfiles/nvim/.config/nvim" ]; then
              rm "$target"
            fi
          fi
        '';

        xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink source;
      }
    )
  ];
}
