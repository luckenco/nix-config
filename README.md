# NixOS + nix-darwin Configuration

Multi-host Nix flake for Linux (`nixos`) and macOS (`nix-darwin`), with shared Home Manager modules.

## Repository layout

```text
.
├── flake.nix
├── flake.lock
├── hosts/
│   ├── mbp/
│   ├── vm/
│   └── vps/
├── lib/
├── modules/
│   ├── common/
│   ├── linux/
│   └── darwin/
└── keys/
```

## Prerequisites

This flake uses `pipe-operators`, so Nix experimental features must include:

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes pipe-operators" > ~/.config/nix/nix.conf
```

On macOS hosts using Determinate Nix (`nix.enable = false`), the flake also writes the same feature set to `/etc/nix/nix.custom.conf` after a successful rebuild.

## Hosts

| Host | Platform | Type | User |
|------|----------|------|------|
| `mbp` | `aarch64-darwin` | desktop | `cal` |
| `vm` | `aarch64-linux` | desktop | `morpheus` |
| `vps` | `x86_64-linux` | server | `morpheus` |

## Usage

### macOS (`nix-darwin`)

First install:

```sh
just bootstrap
# or explicitly
just bootstrap mbp
```

Daily rebuilds:

```sh
rebuild
# equivalent:
nh darwin switch .
nh darwin build .
```

Update flake inputs and re-apply:

```sh
rebuild-update
# equivalent:
nix flake update
nh darwin switch .
HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade
```

### Linux (`nixos`)

Rebuild:

```sh
nh os switch .
nh os build .
```

## Formatting and linting

```sh
just fmt
just lint
```

- `just fmt` runs `nix fmt .` (powered by `flake.nix` `formatter` output using `nixfmt`).
- `just lint` runs `nix flake check`.

## What is configured

- Shared modules for shell, tooling, editor defaults, git, theme, and terminal UX
- Linux modules for networking, locale, nix-ld, desktop/session behavior, and Linux-only packages
- Darwin modules for defaults, Homebrew integration, AeroSpace, GPG, Zed, and Darwin-specific packages
- Flake host auto-discovery via `hosts/*`
- Expanded macOS defaults for developer UX (input autocorrect off, faster UI animations, Finder and Dock tuning, screenshot path/type, trackpad behavior, lock/login defaults)

## Operational notes

- zsh customization is managed through Home Manager (`programs.zsh`), not `/etc/zshrc` overrides.
- Linux firewall defaults to enabled in shared Linux networking config.
- Darwin Homebrew is managed declaratively via `nix-homebrew`, `brew-src`, and `homebrew.*` settings.
- Homebrew auto-update/upgrade/cleanup are disabled during activation for deterministic, non-disruptive rebuilds.
- When updating Homebrew inputs, move `brew-src`, `homebrew-core`, and `homebrew-cask` together so the pinned runtime stays compatible with the pinned tap DSL.
- Package ownership is Nix-first, not Nix-only: stable CLI/dev tools and shared config should live in Nix; Homebrew is for GUI apps, broken Darwin packages, and fast-moving vendor/agent tools.
- Rust project tooling follows `rustup`/Cargo when that is the natural upstream workflow, so global Cargo CLIs such as `sqlx-cli`, `cargo-binstall`, and `rustowl` are intentionally not forced into Nix.
- `ty` in Zed config is pinned to the Nix package path (`${pkgs.ty}/bin/ty`).
- `my.secrets.enable` defaults to `false`; enable it only after adding an age key at `~/.config/sops/age/keys.txt`.
- Screenshots are configured to `${homeDir}/Pictures/Screenshots` and that directory is created during activation.
- Neovim is currently installed by Nix, but `~/.config/nvim` is still owned by the stowed dotfiles repo rather than Home Manager.

## Known follow-ups

- `hosts/vps/hardware-configuration.nix` is still a placeholder and must be replaced with real hardware config before production deployment.
- Re-check Homebrew fallbacks (`gitui`, `yt-dlp`, `azure-cli`) periodically and move back to nixpkgs when stable on Darwin.
- Migrate the Neovim config from the dotfiles repo into Home Manager, then let Home Manager take ownership of `~/.config/nvim`.
