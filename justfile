set shell := ["bash", "-euo", "pipefail", "-c"]

bootstrap host="mbp":
    @echo "Bootstrapping nix-darwin..."
    @command -v nix >/dev/null 2>&1 || { echo "Missing nix. Install Nix first."; exit 1; }
    @if command -v nh >/dev/null 2>&1; then \
      nh darwin switch --accept-flake-config --hostname {{ host }} .; \
    else \
      nix --accept-flake-config run nix-darwin -- switch --flake .#{{ host }}; \
    fi

doctor:
    @bash scripts/doctor

fmt:
    @nix --accept-flake-config fmt .

lint:
    @nix --accept-flake-config flake check

update-grok:
    @bash scripts/update-grok-cli

# Update repository pins without activating anything.
update:
    @if [ -n "$(jj diff --summary)" ]; then \
      echo "Refusing to update a dirty working copy:" >&2; \
      jj status >&2; \
      exit 1; \
    fi
    @ulimit -n 4096 || true; \
      bash scripts/update-grok-cli; \
      nix --accept-flake-config fmt pkgs/grok-cli-latest.nix; \
      nix flake update --accept-flake-config --flake .

# Validate the flake and build the host without activating it.
check host="mbp":
    @ulimit -n 4096 || true; \
      nix --accept-flake-config flake check; \
      nh darwin build --accept-flake-config --hostname {{ host }} .

# Activate an already-validated configuration.
switch host="mbp":
    @ulimit -n 4096 || true; \
      nh darwin switch --accept-flake-config --hostname {{ host }} .

# Update state managed outside Nix.
update-extras:
    @if command -v pi >/dev/null 2>&1; then \
      pi update --extensions; \
    else \
      echo "pi not found; skipping Pi extension update"; \
    fi
    @if command -v brew >/dev/null 2>&1; then \
      HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade --yes; \
    else \
      echo "brew not found; skipping Homebrew update"; \
    fi

# Preserve the one-shot workflow while keeping every stage independently usable.
rebuild-update host="mbp":
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" update
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" check {{ host }}
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" switch {{ host }}
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" update-extras
