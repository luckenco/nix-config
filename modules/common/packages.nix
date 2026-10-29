{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      bun = final.callPackage ../../pkgs/bun-latest.nix { bun = prev.bun; };
      # Stop overriding automatically once nixpkgs has the security release.
      nodejs-security =
        if prev.lib.versionOlder prev.nodejs_24.version "24.22.1" then
          prev.nodejs_24.override {
            nodejs-slim = final.callPackage ../../pkgs/nodejs-24-security.nix {
              nodejs-slim = prev.nodejs-slim_24;
            };
          }
        else
          prev.nodejs_24;
    })
  ];

  environment.systemPackages = with pkgs; [
    # Core utilities
    ripgrep
    eza
    fd
    gh
    htop
    jq

    # File viewers
    glow
    jless

    # Dev tools
    gitui
    just
    tokei
    nix-output-monitor
    ast-grep
    deadnix
    shellcheck
    shfmt

    # Media
    ffmpeg
    yt-dlp

    # HTTP & JSON
    xh
    jnv

    # AI/LLM
    (pkgs.callPackage ../../pkgs/omp-latest.nix { })
    python3Packages.huggingface-hub

    # Documentation
    tealdeer

    # Languages & runtimes
    nodejs-security
    bun
    uv
    rustup
    bacon
    cargo-audit
    cargo-nextest
    probe-rs-tools
    sqlx-cli
    tree-sitter

    # LSP and formatters
    clang-tools
    nil
    nixfmt
    lua-language-server
    stylua
    taplo
    ruff
    ty
    typescript # Keep the reference compiler; do not alias tsc to tsrs.
    (pkgs.callPackage ../../pkgs/tsrs.nix { })
    biome

    # System info
    fastfetch

    # CLIs
    awscli2
    inputs.nixpkgs-azure-cli.legacyPackages.${pkgs.stdenv.hostPlatform.system}.azure-cli
    cloudflared
    livekit-cli
  ];
}
