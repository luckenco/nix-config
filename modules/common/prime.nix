{
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      {
        # Activation bootstraps missing tools; update-extras owns updates.
        home.activation.ensurePrime = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -v DRY_RUN ]; then
            (
              export PATH="${
                lib.makeBinPath [
                  pkgs.uv
                  pkgs.curl
                  pkgs.gnutar
                  pkgs.gzip
                  pkgs.coreutils
                ]
              }:/usr/bin:/bin:/usr/sbin:/sbin"
              ${pkgs.bash}/bin/bash ${../../scripts/install-prime}
            ) || warnEcho "Failed to install Prime tools; retry with just switch."
          fi
        '';
      }
    )
  ];
}
