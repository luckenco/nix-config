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
just bootstrap host=mbp
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
- Darwin Homebrew is managed declaratively via `nix-homebrew` and `homebrew.*` settings.
- Homebrew auto-update/upgrade/cleanup are disabled during activation for deterministic, non-disruptive rebuilds.
- `ty` in Zed config is pinned to the Nix package path (`${pkgs.ty}/bin/ty`).
- `my.secrets.enable` defaults to `false`; enable it only after adding an age key at `~/.config/sops/age/keys.txt`.
- Screenshots are configured to `${homeDir}/Pictures/Screenshots` and that directory is created during activation.

## Known follow-ups

- `hosts/vps/hardware-configuration.nix` is still a placeholder and must be replaced with real hardware config before production deployment.
- Re-check Homebrew fallbacks (`gitui`, `yt-dlp`, `azure-cli`) periodically and move back to nixpkgs when stable on Darwin.
