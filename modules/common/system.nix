{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.my.machine = {
    hostName = mkOption {
      type = types.str;
      description = "Machine hostname";
    };
    userName = mkOption {
      type = types.str;
      description = "Primary user name";
    };
    homeDir = mkOption {
      type = types.str;
      description = "Primary user home directory";
    };
    repoPath = mkOption {
      type = types.str;
      description = "Path to this configuration repository";
    };
  };
}
