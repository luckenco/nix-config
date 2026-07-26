set shell := ["bash", "-euo", "pipefail", "-c"]

bootstrap host="mbp":
  @echo "Bootstrapping nix-darwin..."
  @command -v nix >/dev/null 2>&1 || { echo "Missing nix. Install Nix first."; exit 1; }
  @if command -v nh >/dev/null 2>&1; then \
    nh darwin switch --accept-flake-config --hostname {{host}} .; \
  else \
    nix --accept-flake-config run nix-darwin -- switch --flake .#{{host}}; \
  fi

fmt:
  @nix --accept-flake-config fmt .

lint:
  @nix --accept-flake-config flake check

update-grok:
  @bash scripts/update-grok-cli

# Full update + rebuild. The script is invoked with an explicit repo dir so it
# never needs to rely on the caller's PWD. Safe to run from any directory.
rebuild-update:
  @ulimit -n 4096 || true
  @bash scripts/rebuild-update "{{justfile_directory()}}" "mbp"
