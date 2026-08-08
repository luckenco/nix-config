{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core utilities
    stow
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
    just
    tokei
    nix-output-monitor
    ast-grep
    deadnix
    shellcheck
    shfmt

    # Media
    ffmpeg

    # HTTP & JSON
    xh
    jnv

    # AI/LLM
    (pkgs.callPackage ../../pkgs/grok-cli-latest.nix { })
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Documentation
    tealdeer

    # Languages & runtimes
    nodejs
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
    typescript-go
    biome

    # System info
    fastfetch

    # CLIs
    awscli2
    cloudflared
  ];
}
