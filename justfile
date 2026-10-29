set shell := ["bash", "-euo", "pipefail", "-c"]

bootstrap host="mbp":
    @echo "Bootstrapping nix-darwin..."
    @command -v nix >/dev/null 2>&1 || { echo "Missing nix. Install Nix first."; exit 1; }
    @if command -v nh >/dev/null 2>&1; then \
      nh darwin switch --accept-flake-config --hostname {{ quote(host) }} .; \
    else \
      sudo nix --extra-experimental-features 'nix-command flakes' \
        --accept-flake-config run --inputs-from . nix-darwin -- \
        switch --flake .#{{ quote(host) }}; \
    fi

doctor:
    @bash scripts/doctor

fmt:
    @nix --accept-flake-config fmt .

lint:
    @nix --accept-flake-config flake check

update-omp:
    @bash scripts/update-omp

update-bun:
    @bash scripts/update-bun

# Update repository pins without activating anything. Uncommitted pin updates are allowed to keep rolling.
update:
    @changes=""; \
      if command -v jj >/dev/null 2>&1 && jj root >/dev/null 2>&1; then \
        if ! changes="$(jj diff --summary 'all() ~ file:flake.lock ~ file:pkgs/omp-latest.nix ~ file:pkgs/bun-latest.nix')"; then \
          echo "Could not inspect the Jujutsu working copy; refusing to update." >&2; \
          exit 1; \
        fi; \
      elif git rev-parse --show-toplevel >/dev/null 2>&1; then \
        if ! status="$(git status --short --untracked-files=all)"; then \
          echo "Could not inspect the Git working tree; refusing to update." >&2; \
          exit 1; \
        fi; \
        changes="$(printf '%s\n' "$status" | grep -Ev '^.. (flake\.lock|pkgs/omp-latest\.nix|pkgs/bun-latest\.nix)$' || true)"; \
      else \
        echo "Not in a Jujutsu or Git repository; refusing to update." >&2; \
        exit 1; \
      fi; \
      if [ -n "$changes" ]; then \
        echo "Refusing to update with changes outside managed pin files:" >&2; \
        printf '%s\n' "$changes" >&2; \
        exit 1; \
      fi
    @bash scripts/update-omp; \
      bash scripts/update-bun; \
      nix --accept-flake-config fmt pkgs/omp-latest.nix pkgs/bun-latest.nix; \
      nix flake update --accept-flake-config --flake .

# Validate the flake and build the host without activating it.
check host="mbp":
    @nix --accept-flake-config flake check; \
      nh darwin build --accept-flake-config --hostname {{ quote(host) }} .

# Activate an already-validated configuration.
switch host="mbp":
    @nh darwin switch --accept-flake-config --hostname {{ quote(host) }} .

# Update state managed outside Nix.
update-extras:
    @bash scripts/update-extras

# Preserve the one-shot workflow while keeping every stage independently usable.
rebuild-update host="mbp":
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" update
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" check {{ quote(host) }}
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" switch {{ quote(host) }}
    @just --justfile "{{ justfile_directory() }}/justfile" --working-directory "{{ justfile_directory() }}" update-extras
