# Recovering the Mac

This is a recovery checklist, not another installer. Nix restores the declarative setup; external tools remain independently updated. The inventory below was checked on 2026-10-29 and is not a version lock. Never commit credentials, private keys, or their backups here.

## Base setup

1. Install [Determinate Nix](https://docs.determinate.systems/), which owns the daemon and garbage collection for this host.
2. Restore this repository at `~/Code/nix-config`. Sign in to the Mac App Store before `just bootstrap`.
3. Restore the editor checkout, or clone it:
   ```sh
   git clone https://github.com/luckenco/nvim.git ~/Code/nvim
   ```
4. Run `just bootstrap` from the Nix repository, then open a fresh login shell. On an existing installation, activation moves `~/.cache/.bun` to `~/.local/share/bun` and leaves a compatibility symlink. If both real directories exist, activation stops rather than merging or overwriting them; back up both and reconcile their global package inventories first. `~/.bun` is left alone.
5. Open Neovim and run `:Lazy restore` to restore plugins from its lockfile. Run `:Lazy build rustowl` if the RustOwl executables are missing.

The Bun installation root is `$XDG_DATA_HOME/bun`; new download caches use `$XDG_CACHE_HOME/bun`. Keep the legacy symlink while old shells or rollback generations need it. The migration does not delete old download caches.

## External CLI tools

Run installation commands from `$HOME`, not from a project. These commands install current releases; restore a private copy of the global package manifest and lockfile if exact external versions are required.

| Tools | Restore |
| --- | --- |
| Pi and Cloudflare CLI | `bun add --global @earendil-works/pi-coding-agent cf` (`cf` is also bootstrapped by activation) |
| Expo development, when needed | `bun add --global eas-cli @expo/ngrok` |
| Diff and duplication tools, when needed | `bun add --global hunkdiff jscpd` |
| Prime infrastructure CLI | `uv tool install prime` |
| Origin | Activation bootstraps a missing installation; see `modules/common/origin.nix` |
| Prime Agent (separate from `prime`) | Use the [upstream Rust installer](https://github.com/PrimeIntellect-ai/prime-agent/blob/main/install-rust.sh) |
| Amp | Follow the [official CLI installation](https://ampcode.com/docs/cli) |
| Sentry CLI (`sentry`, not `sentry-cli`) | Follow the [official installation](https://cli.sentry.dev/getting-started/) |

No npm global packages were present in the checked inventory. Do not duplicate Nix-owned tools into npm/Bun globals. Reauthenticate external CLIs with their own login workflows. Pi configuration is restored by activation; its package installation/update remains outside Nix (`pi update --extensions`).

`just update-extras` updates installed tools; it does not install missing ones. It also does not update Cargo-installed binaries or source checkouts.

## Rust

Rustup is installed by Nix, but its toolchains and components are not:

```sh
rustup toolchain install stable --profile minimal
rustup default stable
rustup component add --toolchain stable clippy rustfmt rust-analyzer rust-src
```

Embedded/WebAssembly work additionally uses:

```sh
rustup target add --toolchain stable thumbv7em-none-eabihf wasm32-unknown-unknown
cargo install --locked worker-build
```

RustOwl is built by the Neovim plugin's `./scripts/toolchain cargo install --path . --locked` hook, which provisions its matching toolchain. Let that hook choose the version rather than copying historical rustup installations. Project-specific `rust-toolchain.toml` files own other toolchain requirements.

The optional `tt` utility was installed from `~/Code/personal/ttrs`; restore that checkout and use `cargo install --path ~/Code/personal/ttrs` if needed.

## Signing and private state

Git expects OpenPGP signing key `7B0964DD92945BF9`. Restore its private backup outside this repository, verify the **full fingerprint** against your trusted backup record, and import it:

```sh
gpg --import /path/to/secret-key-backup.asc
gpg --list-secret-keys --with-subkey-fingerprint 7B0964DD92945BF9
printf 'recovery signing check\n' | gpg --local-user 7B0964DD92945BF9 --clearsign >/dev/null
```

If an owner-trust backup is available, restore it with `gpg --import-ownertrust /path/to/ownertrust.txt`. Keep decrypted backups private and remove temporary decrypted copies according to your backup procedure. Reauthenticate services rather than committing or embedding tokens in Nix. Any retained agent sessions or authentication state belong in private backups, not this repository.

## Applications and permissions

- Restore TX-02 from its licensed source or backup to `~/Library/Fonts`; doctor checks `TX-02-Regular.otf`.
- Install the official Zed app and your browsers separately. Homebrew/App Store applications are installed by activation.
- Grant AeroSpace Accessibility permission and any macOS App Management permission requested for Nix/Home Manager app installation.
- Complete Xcode's first-launch setup and license acceptance when using Apple development tools.
- Follow the [Objective-See setup steps](../README.md#objective-see-apps); installation alone does not grant permissions.

Finish with `just doctor`, a TypeScript file in Neovim (`:checkhealth vim.lsp` should show tsrs), and the signing check above. Doctor does not validate credentials, browsers, macOS permissions, FileVault, or backup restoration.
