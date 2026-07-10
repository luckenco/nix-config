# nix-config Review: MBP Development Setup

**Date:** 2026-07-10

**Primary focus:** Using this repository to orchestrate the development environment on the `mbp` host

**Scope:** Flake architecture, host composition, packages, Home Manager, Homebrew, bootstrap/update workflows, configuration ownership, and validation

## Verdict

This is a strong MBP development configuration. The underlying strategy is sound:

- Nix owns stable CLI tools, runtimes, LSPs, and system configuration.
- Homebrew owns macOS applications and packages where Darwin support or freshness is better.
- Native ecosystems own fast-moving project tooling such as Rust toolchains.
- Home Manager supplies a consistent shell, editor, and terminal experience.

The best next step is to simplify and harden the existing design rather than add more tools.

## Highest-value improvements

### 1. Introduce explicit host profiles

Every file under `modules/common` is imported into every host through [lib/system.nix](lib/system.nix). Consequently, the VPS inherits most of the MBP development stack from [modules/common/packages.nix](modules/common/packages.nix), including:

- ffmpeg, Node, Bun, Rustup, and Bacon
- Grok, Herdr, LLM, and Codex
- every language server and formatter
- Neovim, Yazi, and other interactive tools

It also gets NetworkManager and hard-coded Cloudflare DNS from [modules/linux/networking.nix](modules/linux/networking.nix). That is desktop policy and could be inappropriate for a provider-managed VPS.

Organize modules into capabilities:

```text
profiles/
├── base.nix       # shell, git, nix, essential diagnostics
├── dev.nix        # runtimes, editors, LSPs, AI tools
├── desktop.nix    # GUI, terminal, window manager, theme
└── server.nix     # SSH, Tailscale, firewall, minimal tools
```

Then compose hosts as follows:

- `mbp`: base + dev + desktop + Darwin
- `vm`: base + dev + desktop + Linux
- `vps`: base + server

This is the highest-value architectural change.

### 2. Replace implicit flake discovery with explicit composition

[lib/system.nix](lib/system.nix) automatically imports every input's `homeModules.default`, `nixosModules.default`, `darwinModules.default`, and `overlays.default`.

That creates hidden coupling:

- Home Manager and nix-homebrew are essential but never explicitly named as modules.
- SOPS is imported explicitly and also discovered automatically.
- Herdr's default overlay, which includes `rust-overlay`, is applied to the global package set even though Herdr is consumed directly through `inputs.herdr.packages`.
- Adding a future package-only input could silently modify every host.

For three hosts, explicit module and overlay lists would be easier to understand and safer.

The host classifier in [flake.nix](flake.nix) is similarly clever but fragile: anything without `class = "nixos"` becomes a Darwin configuration. A small explicit host registry would be clearer.

### 3. Remove the `pipe-operators` bootstrap dependency

There are only a handful of `|>` uses, but they require enabling an experimental parser feature before Nix can parse the flake. That complexity leaks into the README, bootstrap recipe, and `/etc/nix/nix.custom.conf`.

Ordinary function application or `lib.pipe` would remove the requirement without materially hurting readability.

This would also simplify first installation. Currently:

- [README.md](README.md) says `just bootstrap`, but `just` is installed by the configuration being bootstrapped.
- The prerequisite command in the README overwrites the user's entire `nix.conf` with `>`.
- [justfile](justfile) may append a second `experimental-features` setting if the existing features appear in a different order.

At minimum, document this bootstrap command:

```sh
nix run nixpkgs#just -- bootstrap mbp
```

Use `extra-experimental-features` rather than replacing `experimental-features`.

### 4. Split "update everything" from "activate everything"

[scripts/rebuild-update](scripts/rebuild-update) currently:

1. Mutates the Grok package.
2. Updates every flake input.
3. Builds and activates the MBP.
4. Updates Pi extensions.
5. Upgrades all Homebrew packages.

That is convenient, but it spans three independent state systems with no common rollback. A Homebrew failure can leave Nix already switched, and the command can begin while unrelated working-tree changes are present.

Retain the convenient wrapper, but expose separate stages:

```text
just update       # mutate pins only
just check        # formatting + all-host evaluation
just build        # build MBP without activation
just switch       # activate
just update-extra # Pi + Homebrew
```

The wrapper can call these in sequence, print the changes, and stop for confirmation before activation.

### 5. Close or formally document configuration ownership gaps

The recent Neovim issue demonstrated this well: Nix owns Neovim and TSGo, while `~/Code/.dotfiles` owns the Neovim configuration. Neither repository can test the complete editor.

Choose one of these approaches:

- Move Neovim into this repository and manage it with Home Manager.
- Make the dotfiles repository an explicit flake input.
- Keep the split, but add `just doctor` to verify the expected dotfiles link, Zed installation, proprietary fonts, age key, and external package managers.

The manual Zed installation and undeclared `TX-02`/MonoLisa fonts are reasonable choices, but they should be documented machine prerequisites rather than implicit knowledge.

### 6. Improve verification

The current [checks](flake.nix) only contain formatting derivations. `nix flake check` evaluates configuration outputs, but it does not build the host systems.

A useful local verification command would run:

```sh
nix flake check --all-systems
nh darwin build --hostname mbp .
bash -n scripts/*
```

For a personal repository, CI is optional. Making this the mandatory pre-switch step is more important.

## Smaller fixes

- Resolve the current fzf/Atuin warning in [modules/common/tools.nix](modules/common/tools.nix). Atuin currently wins Ctrl-R implicitly; declare that with `programs.fzf.historyWidget.command = ""`.
- Move Linux `system.stateVersion` out of [modules/linux/shell.nix](modules/linux/shell.nix) and into each host. State versions belong to machines, not shell modules.
- Namespace and type custom options. Top-level `type`, `os`, `isDesktop`, and similar options should become something like `my.role` and use `types.enum`, `types.str`, and `types.path`.
- On the MBP, [automatic GC](modules/common/nix.nix) is skipped because `nix.enable = false`. Confirm that Determinate Nix owns GC; otherwise add a separate scheduled mechanism.
- Finish SOPS only if unmanaged shell files contain credentials. The current disabled scaffold is fine, but it is not yet providing secret orchestration.
- Remove or archive this review once its useful decisions have been incorporated, so the README remains the canonical operational documentation.
- Remove the unreferenced, executable 707 KB `.github/images/screenshot.png`, or reference it and fix its mode.

## What should remain

- The Nix/Homebrew/native-tooling boundary.
- The pinned Homebrew runtime and taps with upgrades disabled during normal activation.
- The MBP defaults, security settings, PATH ordering, AeroSpace/Ghostty/Zellij integration, and global LSP strategy.
- `nixpkgs-unstable` for this use case; freshness is valuable on a development workstation.

## Validation

The following checks passed against the current working tree:

- `nix flake check --no-build --all-systems`
- `bash -n scripts/rebuild-update scripts/update-grok-cli`
- `git diff --check`

The only evaluation warnings were:

- The fzf/Atuin Ctrl-R ownership conflict.
- The current nixpkgs `options.json` store-path context warning during Linux evaluation.

The review was performed against the existing dirty working tree. Unrelated changes were preserved.
