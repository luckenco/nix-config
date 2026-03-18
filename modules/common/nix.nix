{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      warn-dirty = false;
    };
  }
  // (
    if config.isLinux then
      {
        channel.enable = false;

        gc = {
          automatic = true;
          options = "--delete-older-than 7d";
          dates = "weekly";
          persistent = true;
        };

        settings.trusted-users = [
          "root"
          "@wheel"
        ];

        optimise.automatic = true;
      }
    else
      { }
  );

  environment.systemPackages = with pkgs; [
    nh
  ];
}
