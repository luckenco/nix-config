set shell := ["bash", "-euo", "pipefail", "-c"]

bootstrap host="mbp":
    @echo "Bootstrapping nix-darwin..."
    @command -v nix >/dev/null 2>&1 || { echo "Missing nix. Install Nix first."; exit 1; }
    @if command -v nh >/dev/null 2>&1; then \
      nh darwin switch --accept-flake-config --hostname {{ host }} .; \
    else \
      sudo nix --extra-experimental-features 'nix-command flakes' \
        --accept-flake-config run --inputs-from . nix-darwin -- \
        switch --flake .#{{ host }}; \
    fi

doctor:
    @bash scripts/doctor

fmt:
    @nix --accept-flake-config fmt .

lint:
    @nix --accept-flake-config flake check

update-grok:
    @bash scripts/update-grok-cli

# Update repository pins without activating anything. Uncommitted pin updates are allowed to keep rolling.
update:
    @changes=""; \
      if command -v jj >/dev/null 2>&1 && jj root >/dev/null 2>&1; then \
        if ! changes="$(jj diff --summary 'all() ~ file:flake.lock ~ file:pkgs/grok-cli-latest.nix')"; then \
          echo "Could not inspect the Jujutsu working copy; refusing to update." >&2; \
          exit 1; \
        fi; \
      elif git rev-parse --show-toplevel >/dev/null 2>&1; then \
        if ! status="$(git status --short --untracked-files=all)"; then \
          echo "Could not inspect the Git working tree; refusing to update." >&2; \
          exit 1; \
        fi; \
        changes="$(printf '%s\n' "$status" | grep -Ev '^.. (flake\.lock|pkgs/grok-cli-latest\.nix)$' || true)"; \
      else \
        echo "Not in a Jujutsu or Git repository; refusing to update." >&2; \
        exit 1; \
      fi; \
      if [ -n "$changes" ]; then \
        echo "Refusing to update with changes outside managed pin files:" >&2; \
        printf '%s\n' "$changes" >&2; \
        exit 1; \
      fi
    @ulimit -n unlimited || true; \
      bash scripts/update-grok-cli; \
      nix --accept-flake-config fmt pkgs/grok-cli-latest.nix; \
      nix flake update --accept-flake-config --flake .

# Validate the flake and build the host without activating it.
check host="mbp":
    @ulimit -n unlimited || true; \
      nix --accept-flake-config flake check; \
      nh darwin build --accept-flake-config --hostname {{ host }} .

# Activate an already-validated configuration.
switch host="mbp":
    @ulimit -n unlimited || true; \
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
