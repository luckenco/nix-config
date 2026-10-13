{
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      {
        # Origin owns its updates; activation only bootstraps a missing install.
        home.activation.ensureOrigin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -x "$HOME/.local/bin/origin" ] && [ ! -v DRY_RUN ]; then
            (
              export PATH="${
                lib.makeBinPath [
                  pkgs.curl
                  pkgs.gnutar
                  pkgs.gzip
                  pkgs.coreutils
                ]
              }:/usr/bin:/bin:/usr/sbin:/sbin"
              unset ORIGIN_INSTALL_CHANNEL ORIGIN_INSTALL_DIR ORIGIN_BIN_DIR
              unset CO_INSTALL_CHANNEL CO_INSTALL_DIR CO_BIN_DIR
              installer="$(mktemp)" || exit 1
              trap 'rm -f "$installer"' EXIT
              ${pkgs.curl}/bin/curl -fsSL --proto '=https' --proto-redir '=https' \
                --connect-timeout 15 --max-time 120 \
                https://downloads.cursor.com/origin/install.sh \
                -o "$installer" \
                && ${pkgs.coreutils}/bin/timeout --kill-after=10 300 ${pkgs.bash}/bin/sh "$installer"
            ) || warnEcho "Failed to install Origin; continuing activation."
          fi
        '';
      }
    )
  ];
}
