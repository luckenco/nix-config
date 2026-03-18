{ config, lib, ... }:
let
  inherit (lib)
    last
    mkConst
    mkValue
    splitString
    ;
in
{
  options = {
    os = mkConst (last (splitString "-" config.nixpkgs.hostPlatform.system));

    isLinux = mkConst (config.os == "linux");
    isDarwin = mkConst (config.os == "darwin");

    type = mkValue "server";

    isDesktop = mkConst (config.type == "desktop");
    isServer = mkConst (config.type == "server");

    my = {
      machine = {
        hostName = mkValue config.networking.hostName;
        userName = mkValue (if config.isDarwin then (config.system.primaryUser or "user") else "morpheus");
        homeDir = mkValue (
          if config.isDarwin then
            "/Users/${config.my.machine.userName}"
          else
            "/home/${config.my.machine.userName}"
        );
        repoPath = mkValue "${config.my.machine.homeDir}/code/nix-cfg/nixos-config";
      };

      secrets.enable = mkValue false;
    };
  };
}
