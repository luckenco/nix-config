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

Install Nix, clone the repository, enter it, and run:

```sh
nix --extra-experimental-features 'nix-command flakes' \
  --accept-flake-config run --inputs-from . nixpkgs#just -- bootstrap
```

This obtains Just from the repository's locked Nixpkgs input. If `just` is already available, `just bootstrap` is equivalent. The host defaults to `mbp`; pass `mbp` as the final argument to select it explicitly.

If `nh` is already installed, bootstrap uses it. Otherwise it runs the repository's locked nix-darwin with `sudo`.

Home Manager activation attempts to install the Cloudflare CLI (`cf`) through Bun if it is missing. Activation and interactive shells use the same Bun root at `$XDG_CACHE_HOME/.bun` (`~/.cache/.bun` by default). This requires network access on first install; Bun owns the CLI version outside the Nix lock file. Activation also caches its Zsh completion, so shell startup does not run the CLI. Installation or completion failures warn without aborting activation; failed generation preserves any existing completion. Completion refreshes on activation. After updating `cf` through `just update-extras`, run `just switch` to refresh its cached completion.

Before the first activation, sign in to the Mac App Store so the configured `masApps` can be installed. The Neovim configuration, GPG secret key, TX-02 font, Zed, and browsers are intentionally managed outside this repository; `just doctor` reports missing external dependencies after activation.

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

Update the Bun, Grok CLI, and OMP pins to their latest stable releases, and update flake inputs without activating anything:

```sh
just update
```

The update allows uncommitted changes to `flake.lock`, `pkgs/bun-latest.nix`, `pkgs/grok-cli-latest.nix`, and `pkgs/omp-latest.nix`, but refuses changes to other files. The safety check supports both Jujutsu and ordinary Git clones.

`just update-bun`, `just update-grok`, and `just update-omp` refresh individual pins. Bun uses an upstream Apple Silicon release with nixpkgs' packaging and Darwin fixups, so it can update even when nixpkgs lags. OMP uses a prebuilt Apple Silicon binary pinned by build ID and SHA-256. Normal rebuilds keep these versions until the pins are updated.

Update tools managed outside Nix:

```sh
just update-extras
```

This updates Bun global packages to latest releases (including Pi and `cf`), npm globals, uv tools, Rust toolchains, Origin, Prime Agent, Amp, Sentry CLI, Pi extensions, Mac App Store apps, and Homebrew packages. Missing commands are skipped. Failures are reported without preventing the other extras from being attempted; the stage exits unsuccessfully if any updater fails. Updates run from `$HOME`, never from the caller's project.

This does not update source checkouts, Cargo-installed binaries, arbitrary downloaded executables, or independently installed GUI apps such as Zed and browsers. Those retain their own update workflows. Other Nix packages normally follow nixpkgs. Node 24 temporarily uses the official, hash-pinned Apple Silicon 24.22.1 security release, including its bundled libraries. The system Node runtime, Cloudflare CLI completion, and Twilio use this package without rebuilding unrelated tools. It automatically defers to nixpkgs once its Node 24 package reaches 24.22.1 or newer. Bun, Grok, and OMP have independently updated upstream release pins.

Run the full update workflow:

```sh
just rebuild-update
```

This runs four stages in order:

1. Update repository pins.
2. Check the flake and build the host.
3. Activate the configuration.
4. Update external CLI packages, extensions, toolchains, and apps.

Each stage is available separately, so a failed update does not force the whole workflow to be repeated.

## Nix storage maintenance

Determinate Nix owns automatic store garbage collection. A separate root launchd job,
`org.nixos.nix-prune-generations`, prunes only the system profile every Sunday at
12:00 local time. It keeps all generations from the last 30 days and at least the
latest 10. It does not collect store garbage or prune project/direnv roots.

Preview the retention policy without changing anything:

```sh
nh clean profile /nix/var/nix/profiles/system --dry --keep 10 --keep-since 30d --no-gc --no-gcroots --no-direnv
```

The job is installed by `just switch`; activation does not immediately prune anything.
Logs go to `/var/log/nix-prune-generations.log`. Pruned generations are no longer
available for rollback. Determinate can reclaim their unreferenced dependencies later.

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

Brave, Chrome, and Helium are installed and updated outside Nix.

Zed is installed as a macOS app, while its settings are managed declaratively.

The Neovim configuration lives in the standalone `~/Code/nvim` repository. Home Manager links it into `~/.config/nvim`. `just doctor` verifies that link and the external tools the editor expects.
