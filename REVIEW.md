# nix-config Review: MacBook (mbp) Development Setup
**Date**: 2026-06-12  
**Repo state**: 476accbc (working copy @ tmtkynyk, parent main a8858229)  
**Focus**: Fitness as daily driver for development on aarch64-darwin MacBook Pro ("mbp" host, user `cal`). Lightweight improvements only.

This is an audit + suggestions report. **The following items from the review have now been implemented** (with small practical adjustments for correctness on this setup — see details below and in the commit diffs):

- **2 (jj script)**: `scripts/update-grok-cli` is now robust when the repo is managed by `jj`.
- **3 (GC/optimise)**: Guarded `nix.gc` and `nix.optimise` with `mkIf config.nix.enable` in [modules/common/nix.nix](/Users/cal/Code/nix-config/modules/common/nix.nix) so it activates on normal Nix/NixOS/nix-darwin setups but does not trigger assertions on the mbp (which deliberately uses `nix.enable = false` for Determinate Nix). Includes explanatory comment.
- **4 (.envrc)**: Added minimal `.envrc` at the root.
- **5 (classification comment)**: Added a clear, accurate multi-line comment in [flake.nix](/Users/cal/Code/nix-config/flake.nix) explaining the host discovery/groupBy logic (we documented rather than injecting a `class` attribute, as that would have required declaring a new option and polluted the module).

No other items were changed. The core "technique" and behaviour for the mbp remain the same. Verifications passed cleanly after edits (see below).

---

**Zero changes were made to the actual configuration logic** during the *initial* review (only this doc + the private plan file were added at that time). The edits described above were applied in a follow-up after clarification. All suggestions are small in scope and follow existing patterns.

## Executive Verdict
The current setup is **excellent** for a power-user Mac dev environment. It is opinionated, reproducible where it matters (pinned Homebrew sources + custom binary), and heavily optimized for ergonomics:

- Aerospace tiling + Ghostty + Zellij (jj/git-aware layout) + direnv/nix-direnv
- Rustup + uv + bun + Node (deliberate, not fully Nix-pinned toolchains)
- Rich global LSPs + formatters (biome, ty, ruff, nil, etc.)
- Just + nh + nom UX, careful PATH priority (`.cargo` / `.local` > Nix > fallbacks)
- Very polished macOS system defaults and security (touchid sudo, stealth FW, key repeat, no autocorrect, fast UI, screenshots dir)
- Consistent Gruvbox theming across tools

The "Nix-first for CLIs/dev tools + Homebrew casks + some brews for Darwin gaps" philosophy is executed cleanly via `nix-homebrew` + `brew-src` pinning.

It is **not overcomplicated** for its goals. The custom `lib/` (enabled merge, mkValue/mkConst, collectNix, darwinSystem'/nixosSystem' wrappers) + sharedModules + host auto-discovery is a nice lightweight alternative to flake-parts for a personal 3-host config.

Minor sharp edges exist (mostly already called out in README.md TODOs), but nothing that would block productive daily work.

## What Works Exceptionally Well (Key Techniques)
- **direnv + nix-direnv** ([modules/common/tools.nix:14](modules/common/tools.nix)): First-class, Zsh integration, Darwin-specific doCheck override. Combined with the elaborate PATH logic in shell this is the foundation of project-local dev shells.
- **Language runtime choices** ([modules/common/packages.nix:46](modules/common/packages.nix)): `rustup`, `uv`, `bun`, `nodejs`. LSPs (pyright/ruff/ty/biome/nil/stylua/typescript-go/clang-tools) installed globally for instant editor use. `bacon` for Rust. This is the correct pragmatic choice for a dev machine.
- **Editors**:
  - Zed: only settings managed ([modules/darwin/zed.nix:7](modules/darwin/zed.nix)), official app for freshness + auto-update. Python uses Nix `ty` binary path explicitly; rust-analyzer clippy on save.
  - Helix configured with gruvbox + relative numbers + inlay hints + nvim-compat motions during transition ([modules/common/editor/helix.nix](modules/common/editor/helix.nix)).
  - Neovim package only (config still in external stow, per README).
- **Terminal + WM + Multiplexer**:
  - Aerospace full declarative config + launchd + on-window-detected rules (brave→ws1, ghostty→ws2 floating, linear→ws3) + nice reload-on-change ([modules/darwin/aerospace.nix](modules/darwin/aerospace.nix)).
  - Ghostty (via cask) + HM settings for padding, opacity, blur, keybinds, option-as-alt ([modules/common/ghostty.nix](modules/common/ghostty.nix)).
  - Zellij with custom "missioncontrol" layout that auto-runs `jj status`/`git status` + `jj log` in side panes, plus exhaustive keybinds + tmux compat ([modules/common/zellij.nix](modules/common/zellij.nix)).
- **macOS system UX** ([modules/darwin/defaults.nix](modules/darwin/defaults.nix)): Dozens of thoughtful tweaks (InitialKeyRepeat/KeyRepeat, all autocorrect off, fast resize/animations, dock autohide + no recents, finder POSIX paths + sort folders first, screencapture to ~/Pictures/Screenshots + png + no shadow, trackpad tap-to-click + right-click, login full name, etc.). Plus activation script for the screenshots dir.
- **Rebuild & ops ergonomics** ([modules/common/shell.nix:74](modules/common/shell.nix), justfile): `rebuild`, `rebuild-update` (flake update + just update-grok + brew upgrade under HOMEBREW_NO_AUTO_UPDATE), bootstrap. ulimit -n 4096 guards everywhere. nh + nom aliases (`nb`, `nd`, `ns`).
- **Reproducible Homebrew technique** ([modules/darwin/homebrew.nix](modules/darwin/homebrew.nix) + flake inputs): `nix-homebrew` with `mutableTaps = false`, pinned `brew-src` + homebrew-{core,cask} flakes (not flake), `onActivation` all disabled. Some brews are intentional fallbacks (azure-cli, gitui, yt-dlp, opencode, cocoapods, livekit-cli, mas, mole) because nixpkgs Darwin support lags. Casks for GUIs + agents (claude-code, codex, raycast, etc.). masApps for Xcode + a few others. Comment in README explains the migration gotcha for existing `/opt/homebrew/Library/Taps`.
- **Git + Jujutsu** ([modules/common/git.nix](modules/common/git.nix), [modules/common/jujutsu.nix](modules/common/jujutsu.nix)): Full alias sets, difftastic for git, jj signing + difft diff + nvim editor, shell aliases `jl`/`jd` etc. zellij layout detects jj root.
- **Security / agent** ([modules/darwin/security.nix](modules/darwin/security.nix), [modules/darwin/gpg.nix](modules/darwin/gpg.nix)): `security.pam.services.sudo_local.touchIdAuth`, app firewall + stealth + signed allow. gpg-agent with pinentry_mac.
- **Other UX wins**: starship (memory usage + lua), atuin, fzf, zoxide, yazi (with `y` wrapper), bat everywhere, eza, just + tokei + ast-grep + xh + jnv + llm + grok-cli-latest (custom pinned via scripts/), tealdeer, fastfetch. grok update script uses prefetch + perl edit + fmt ([scripts/update-grok-cli](scripts/update-grok-cli), [pkgs/grok-cli-latest.nix](pkgs/grok-cli-latest.nix)).
- **Modularity & lib** ([lib/system.nix](lib/system.nix), [lib/option.nix](lib/option.nix), [lib/values.nix](lib/values.nix)): `enabled` (merge functor), `mkValue`/`mkConst`, `collectNix`, platform `isDarwin`/`isLinux`/`isDesktop`, `my.machine` injection, automatic aggregation of common + darwin/linux modules + overlays + sops + input modules. Host discovery in flake is clever (readDir + groupBy on the evaluated system result).
- **Darwin shell env** ([modules/darwin/shell.nix](modules/darwin/shell.nix)): CC/CXX/CARGO_*_LINKER to system clang, launchctl maxfiles bump.
- **Activation hygiene**: home-manager backupFileExtension, screenshot dir, sublime old-dotfiles link cleanup ([modules/common/sublime.nix](modules/common/sublime.nix)).

The PATH manipulation in zsh `initContent` (user paths first, then insert fallbacks after the Nix profile segments) is battle-tested and correct for rustup + Homebrew + Orbstack + Bun.

## Lightweight Improvement Opportunities
Only small, optional, pattern-reusing changes. Grouped roughly by effort. None are required.

### Very Low Effort (docs / comments / one-liners)
1. **Add a `devShells` output to flake.nix** (~8-15 lines).  
   Provides `nix develop` (or direnv `use flake`) for working on *this repo itself* with just, nh, nixfmt, etc. available purely. Reuses the existing `forAllSystems`, formatter, and checks logic.  
   File: [flake.nix:96](flake.nix) (after the `// { ... }`).

2. **Document or lightly harden jj vs git in update script**.  
   `scripts/update-grok-cli:4` does `git rev-parse --show-toplevel`. Works in jj (jj provides git compat for many commands), but a comment + fallback to `jj root 2>/dev/null || git ...` would be more explicit. Or just a README note. Cost: 2 lines + comment.

3. **Symmetric GC/optimise on Darwin** (in [modules/common/nix.nix](modules/common/nix.nix)).  
   Currently only under the Linux branch (lines 22-41). Add for Darwin too (even with Determinate Nix the explicit `nix.optimise.automatic = true;` + perhaps a GC entry is harmless and keeps the store lean under heavy rustup/uv/node use). Use `mkIf config.isDarwin` or just always-on settings that Darwin supports.

4. **Add a root `.envrc`** (and ensure .gitignore covers it).  
   Typical: `use flake` or `use nix`. .direnv is already ignored. This lowers friction the first time someone (including future you) `cd`s into the nix-config repo. One file.

5. **Clarify host classification comment** in [flake.nix:89](flake.nix).  
   The `if value ? class && value.class == "nixos"` works (per `nix flake show`), but no source sets `class` (hosts set `type`; `value` is the system builder return value). A one-line comment explaining why it classifies correctly today, or setting `class = "nixos";` inside the vm/vps modules for explicitness, would remove any future mystery.

### Small Polish / Docs
6. **Secrets readiness nudge** ([modules/common/secrets.nix](modules/common/secrets.nix), justfile bootstrap, README).  
   Already gated and bootstrap warns. Consider:
   - A `secrets/.gitkeep` (empty dir is fine; the yaml is user-supplied).
   - One commented example in secrets.nix or a short "to enable" section in README.
   - Optional note in hosts/mbp/default.nix near `my.machine`.
   Does **not** turn it on or create real secrets.

7. **Minor dev-loop package candidates** (if you feel the lack).  
   Current set in packages.nix + darwin packages is already rich. Candidates people often add: `watchexec`, `hyperfine`, `entr`, `sd`, `ripgrep-all`, `cargo-expand`/`cargo-udeps` (via rustup or nix). Only add what you actually miss; the philosophy of "Nix for stable CLIs, language tools via their native managers" is sound.

8. **Fonts note or light cask** (theme uses "TX-02" + "MonoLisa Nerd Font" + gruvbox).  
   Currently user responsibility (or manual brew cask font-...). A short paragraph in README "Operational notes" or a tiny optional `modules/darwin/fonts.nix` (just a couple casks under homebrew) would close the loop if you ever want full declarativity here. Low priority.

9. **Re-prioritize / tick README TODOs**.  
   The list in [README.md:117](README.md) is accurate and was a great guide during review. After this audit the highest-value remaining for *you on mbp* are probably:
   - The non-blocking `options.json` context warning (seen again in the nh darwin build verification).
   - The pinned Homebrew tap `.git: Permission denied` warning (investigate).
   - Re-check fallbacks (azure-cli etc.) periodically.
   - (Neovim migration and full secrets are larger personal decisions.)

## Risks / Things Worth Watching (No Action Needed)
- `pipe-operators` (and the full feature set) must be in `~/.config/nix/nix.conf` + written to `/etc/nix/nix.custom.conf` on Darwin because of Determinate. Bootstrap handles it; documented.
- Rolling `nixpkgs-unstable` + `home-manager/master` (intentional for freshness; README discusses stable alternative).
- Hardcoded personal data (name, email, GPG key `7B0964DD92945BF9`) in git/jj modules — normal for a single-user machine flake.
- Neovim config ownership split (stow vs this repo).
- Orbstack profileExtra + other fallbacks in shell init.
- The options.json and Homebrew tap warnings (non-fatal, already tracked).

## Verification Performed (2026-06-12)
All passed cleanly (source tree untouched):
- `just lint` → ✅ (formatting derivation + darwinConfigurations.mbp evaluated; some expected "omitted systems" and "unchecked outputs" warnings).
- `nix flake show --accept-flake-config` → ✅ (correct split: darwinConfigurations.mbp, nixosConfigurations.{vm,vps}).
- `nh darwin build --accept-flake-config --hostname mbp .` → ✅ (built in ~3s, no version changes; reproduced the known `options.json` store-path context warning).

Additional manual checks recommended after any future edits:
- `nh darwin build ...` (or full switch on a safe day).
- Shell: `type rebuild`, `direnv status`, `starship`, jj/git aliases, `which ty` (must be Nix store path), direnv in a subdir with flake.
- `nix flake show`, `just lint`.

## Summary & Recommendations
This is one of the nicer personal nix-darwin + HM setups I've seen for serious Mac development work. The combination of tiling + modal multiplexer + excellent shell + language-native managers + global LSPs + declarative macOS prefs + careful Homebrew reproducibility gives a very "it just works and feels fast" daily experience.

**Do nothing** if you're happy — the current technique is working well.

**Pick 1-3 small items** from the list above if you want to close a few loops (the devShell and a root .envrc + the GC line + the update-script comment would be my personal top recommendations for low cost/high consistency).

If you want any of the suggested improvements implemented (or a different subset, or a more thorough review of a specific area like the zellij keybinds or the PATH logic), just say the word and point to the numbers. I can execute them with the same "keep it simple" constraint, run the verification suite again, and leave the working copy ready for `jj describe`.

---

*Generated from exhaustive review of flake.nix, all hosts/, modules/{common,darwin,linux}/, lib/, pkgs/, scripts/, justfile, README, and runtime flake evaluation + build.*
