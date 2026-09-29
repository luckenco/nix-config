{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.etc = lib.mkIf (!config.nix.enable) {
    "nix/nix.custom.conf".text = ''
      warn-dirty = false
    '';
  };

  environment.systemPackages = [ pkgs.nh ];
}
