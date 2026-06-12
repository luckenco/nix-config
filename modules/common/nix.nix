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

    # Automatic GC + store optimisation (de-duplication) when the Nix
    # integration is enabled (normal nix-darwin or NixOS; skipped when
    # using Determinate Nix with `nix.enable = false` on the mbp).
    #
    # Helps keep the store from growing unbounded on a development machine
    # (rustup toolchains, uv/bun/node, LSPs, generations of the config, etc.).
    gc = mkIf config.nix.enable (
      {
        automatic = true;
        options = "--delete-older-than 7d";
      }
      // lib.optionalAttrs config.isLinux {
        dates = "weekly";
        persistent = true;
      }
    );

    optimise.automatic = mkIf config.nix.enable true;
  }
  // (
    if config.isLinux then
      {
        channel.enable = false;

        settings.trusted-users = [
          "root"
          "@wheel"
        ];
      }
    else
      { }
  );

  environment.etc = mkIf (config.isDarwin && !config.nix.enable) {
    "nix/nix.custom.conf".text = ''
      extra-experimental-features = nix-command flakes pipe-operators
      warn-dirty = false
    '';
  };

  environment.systemPackages = with pkgs; [
    nh
  ];
}
