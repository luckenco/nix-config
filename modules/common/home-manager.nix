{ lib, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      (
        { config, lib, ... }:
        {
          xdg = enabled { };

          home.activation.ensureScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
          '';
        }
      )
    ];
  };
}
