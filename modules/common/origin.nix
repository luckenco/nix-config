{
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      {
        # Origin owns its updates; activation only bootstraps a missing install.
        home.activation.ensureOrigin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -x "$HOME/.local/bin/origin" ] && [ ! -v DRY_RUN ]; then
            (
              installer="$(mktemp)" || exit 1
              trap 'rm -f "$installer"' EXIT
              ${pkgs.curl}/bin/curl -fsSL \
                https://downloads.cursor.com/origin/install.sh \
                -o "$installer" \
                && ${pkgs.bash}/bin/sh "$installer"
            ) || warnEcho "Failed to install Origin; continuing activation."
          fi
        '';
      }
    )
  ];
}
