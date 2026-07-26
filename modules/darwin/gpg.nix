{ pkgs, ... }:
{
  home-manager.sharedModules = [
    {
      programs.gpg = {
        enable = true;
      };

      # Configure gpg-agent to use pinentry-mac
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
        default-cache-ttl 3600
        max-cache-ttl 7200
      '';
    }
  ];
}
