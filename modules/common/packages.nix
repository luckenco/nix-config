{ lib, pkgs, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      # Core utilities
      stow
      ripgrep
      eza
      fd
      gh
      htop
      tree
      jq

      # File viewers
      yazi
      glow
      bat
      jless

      # Dev tools
      just
      tokei
      nix-output-monitor
      ast-grep

      # Media
      ffmpeg

      # HTTP & JSON
      xh
      jnv

      # AI/LLM
      # codex  # TODO: upstream build broken (rama-boring-sys fails)
      llm

      # Documentation
      tealdeer

      # Security
      gnupg

      # Languages & runtimes
      nodejs
      bun
      uv
      rustup
      bacon
      tree-sitter

      # LSP and formatters
      clang-tools
      nil
      nixfmt
      lua-language-server
      astro-language-server
      rust-analyzer
      pyright
      stylua
      ruff
      ty
      typescript-go
      biome

      # System info
      fastfetch

      # CLIs
      awscli2
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      gcc
      azure-cli
    ];
}
