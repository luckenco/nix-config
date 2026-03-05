set shell := ["bash", "-euo", "pipefail", "-c"]

bootstrap:
  @echo "Bootstrapping nix-darwin..."
  @command -v nix >/dev/null 2>&1 || { echo "Missing nix. Install Nix first."; exit 1; }
  @mkdir -p "$HOME/.config/nix"
  @if ! grep -q "pipe-operators" "$HOME/.config/nix/nix.conf" 2>/dev/null; then \
    echo "experimental-features = nix-command flakes pipe-operators" >> "$HOME/.config/nix/nix.conf"; \
  fi
  @if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then \
    echo "No age key at ~/.config/sops/age/keys.txt (okay if my.secrets.enable = false)."; \
  fi
  @if command -v nh >/dev/null 2>&1; then \
    nh darwin switch .; \
  else \
    nix run nix-darwin -- switch --flake .#mbp; \
  fi
