{
  config,
  lib,
  pkgs,
  ...
}:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };

    # These settings only apply when nix-darwin manages Nix itself.
    gc = lib.mkIf config.nix.enable {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = lib.mkIf config.nix.enable true;
  };

  environment.etc = lib.mkIf (!config.nix.enable) {
    "nix/nix.custom.conf".text = ''
      extra-experimental-features = nix-command flakes
      warn-dirty = false
    '';
  };

  environment.systemPackages = [ pkgs.nh ];
}
