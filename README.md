# macOS Development Configuration

Declarative development environment for an Apple Silicon Mac using nix-darwin, Home Manager, and Homebrew.

## Layout

```text
.
├── flake.nix
├── hosts/mbp/
├── modules/
│   ├── common/
│   └── darwin/
├── pkgs/
└── scripts/
```

Modules are imported explicitly through `modules/common/default.nix` and `modules/darwin/default.nix`. A future platform can add its own module directory and flake configuration without changing the macOS setup.

## First installation

Install Nix and clone the external Neovim configuration first:

```sh
git clone --recurse-submodules git@github.com:luckenco/.dotfiles.git ~/Code/.dotfiles
```

Then run from this repository root:

```sh
nix --extra-experimental-features "nix-command flakes" \
  run github:nix-darwin/nix-darwin/master -- \
  switch --flake .#mbp
```

If `just` is already available, `just bootstrap` performs the same activation.

## Daily use

Rebuild without updating inputs:

```sh
rebuild
# or
nh darwin switch --accept-flake-config --hostname mbp .
```

Build without activating:

```sh
nh darwin build --accept-flake-config --hostname mbp .
```

Run the complete update workflow from any directory:

```sh
rebuild-update
```

The shell alias uses absolute repository paths and runs these independently usable stages:

```sh
just update          # update Grok and flake inputs
just check           # check the flake and build without activating
just switch          # activate the validated configuration
just update-extras   # update Pi extensions and Homebrew packages
just rebuild-update  # run every stage in order
```

`just update` refuses to mutate a dirty working copy. The full workflow validates and builds the new configuration before activation.

## Validation and formatting

```sh
just doctor
just fmt
just lint
```

- `just doctor` verifies external applications, fonts, the Neovim repository, and its language servers.
- `just fmt` formats the Nix source with `nixfmt-tree`.
- `just lint` evaluates the flake and runs its formatting check.

## Package ownership

- Nix owns CLI tools, runtimes, language servers, formatters, and system configuration.
- Home Manager owns shell and user application configuration.
- Homebrew owns macOS applications and packages that are fresher or more reliable outside nixpkgs.
- Native ecosystems own fast-moving project tooling when appropriate, such as Rust toolchains managed through rustup.

Homebrew updates and cleanup are disabled during normal activation. Run upgrades explicitly through `just update-extras` or `rebuild-update`.

## Operational notes

- Determinate Nix manages the daemon, so `nix.enable = false`.
- Homebrew runtime and taps are pinned through flake inputs.
- Zed is installed from its official download and owns its updates; Home Manager owns its settings.
- Neovim is installed by Nix. Home Manager owns `~/.config/nvim`, which points to the mutable Neovim Git repository inside `~/Code/.dotfiles`.
- Screenshots are stored in `~/Pictures/Screenshots`.
- The configuration expects the proprietary `TX-02` font to be installed separately.
- Rust project tooling follows rustup and Cargo rather than duplicating toolchains in Nix.

## TODO

- Remove the Herdr packaging override once upstream includes `SKILL.md` in its Nix source fileset.
- Add secret management when there are concrete secrets to manage.
- Re-check Homebrew fallbacks periodically and move packages back to nixpkgs when reliable.
- Investigate the non-blocking pinned Homebrew tap `.git: Permission denied` warning.
- Investigate the non-blocking Nix `options.json` store-path context warning.
