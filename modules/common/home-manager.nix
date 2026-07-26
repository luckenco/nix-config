{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    sharedModules = [
      (
        { config, lib, ... }:
        {
          xdg = {
            enable = true;
            userDirs.setSessionVariables = true;
          };

          home.activation.ensureScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
          '';
        }
      )
    ];
  };
}
