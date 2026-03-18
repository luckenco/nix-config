{ pkgs, lib, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager.sharedModules = [
    {
      programs.gpg = enabled { };

      # Configure gpg-agent to use pinentry-mac
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
        default-cache-ttl 3600
        max-cache-ttl 7200
      '';
    }
  ];
}
