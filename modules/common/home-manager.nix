{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    sharedModules = [
      (
        { config, lib, ... }:
        {
          # Home Manager's generated options.json loses its Nixpkgs store-path
          # context, producing a warning that Nix may eventually make an error.
          manual.manpages.enable = false;

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
