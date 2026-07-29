# Nix config

My macOS development setup, managed with nix-darwin and Home Manager.

This repo configures my Apple Silicon MacBook Pro: `mbp`.

If necessary it should be easily expandable by creating a new host in 
the `hosts/` directory.

## Layout

```text
.
├── flake.nix
├── flake.lock
├── hosts/
│   └── mbp/
├── modules/
│   ├── common/
│   └── darwin/
├── pkgs/
├── scripts/
└── justfile
```

- `hosts/mbp/` contains the host entry point.
- `modules/common/` contains shared user and development tooling.
- `modules/darwin/` contains macOS system settings and packages.
- `pkgs/` contains packages that are not sourced directly from nixpkgs.
- `scripts/` contains checks and update helpers.

## Bootstrap

Install Nix and clone the repository, then run:

```sh
just bootstrap
```

The host defaults to `mbp`. To pass it explicitly:

```sh
just bootstrap mbp
```

If `nh` is installed, bootstrap uses it. Otherwise it falls back to nix-darwin directly.

## Daily use

Check the flake and build the configuration without activating it:

```sh
just check
```

Activate the configuration:

```sh
just switch
```

Format the Nix files:

```sh
just fmt
```

Run the flake checks:

```sh
just lint
```

Check tools and configuration that live outside Nix:

```sh
just doctor
```

## Updating

Update the Grok CLI pin and flake inputs without activating anything:

```sh
just update
```

The update allows uncommitted changes to `flake.lock` and the Grok CLI pin, but refuses changes to other files.

Update Pi extensions and Homebrew packages:

```sh
just update-extras
```

Run the full update workflow:

```sh
just rebuild-update
```

This runs four stages in order:

1. Update repository pins.
2. Check the flake and build the host.
3. Activate the configuration.
4. Update Pi extensions and Homebrew packages.

Each stage is available separately, so a failed update does not force the whole workflow to be repeated.

## What is managed

### Nix and Home Manager

- Shell and terminal tooling
- Git and Jujutsu
- Editors and language tooling
- Zellij
- Shared packages
- Theme and user configuration

### nix-darwin

- macOS defaults
- System and security settings
- AeroSpace
- GPG
- Homebrew
- Zed
- macOS-specific packages

## Package ownership

The setup is Nix-first, not Nix-only.

Stable CLI tools, development tools, and shared configuration belong in Nix. Homebrew handles GUI apps, vendor tools, and packages that currently work better outside nixpkgs.

Zed is installed as a macOS app, while its settings are managed declaratively.

The Neovim configuration still lives in `~/Code/.dotfiles` and is linked into `~/.config/nvim`. `just doctor` verifies that link and the external tools the editor expects.
