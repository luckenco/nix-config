{ pkgs, ... }:
{
  launchd.daemons.nix-prune-generations = {
    path = [ "/nix/var/nix/profiles/default/bin" ];
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.nh}/bin/nh"
        "clean"
        "profile"
        "/nix/var/nix/profiles/system"
        "--keep"
        "10"
        "--keep-since"
        "30d"
        "--no-gc"
        "--no-gcroots"
        "--no-direnv"
      ];
      StartCalendarInterval = {
        Weekday = 0;
        Hour = 12;
        Minute = 0;
      };
      StandardOutPath = "/var/log/nix-prune-generations.log";
      StandardErrorPath = "/var/log/nix-prune-generations.log";
    };
  };
}
