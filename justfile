set shell := ["bash", "-euo", "pipefail", "-c"]

bootstrap host="mbp":
  @echo "Bootstrapping nix-darwin..."
  @command -v nix >/dev/null 2>&1 || { echo "Missing nix. Install Nix first."; exit 1; }
  @mkdir -p "$HOME/.config/nix"
  @if ! grep -Eq '^[[:space:]]*experimental-features[[:space:]]*=.*\bnix-command\b.*\bflakes\b.*\bpipe-operators\b' "$HOME/.config/nix/nix.conf" 2>/dev/null; then \
    printf '%s\n' "experimental-features = nix-command flakes pipe-operators" >> "$HOME/.config/nix/nix.conf"; \
  fi
  @if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then \
    echo "No age key at ~/.config/sops/age/keys.txt (okay if my.secrets.enable = false)."; \
  fi
  @if command -v nh >/dev/null 2>&1; then \
    nh darwin switch --hostname {{host}} .; \
  else \
    nix run nix-darwin -- switch --flake .#{{host}}; \
  fi

fmt:
  @nix fmt .

lint:
  @nix flake check
