# NixOS & nix-darwin Configuration

Multi-platform Nix configuration for NixOS (Linux) and nix-darwin (macOS) using flakes.

## Structure

```
.
├── flake.nix              # Flake with dynamic host discovery
├── lib/                   # Custom library functions
│   ├── default.nix        # Library aggregator
│   ├── filesystem.nix     # collectNix utility
│   ├── option.nix         # mkConst, mkValue helpers
│   ├── system.nix         # nixosSystem', darwinSystem' wrappers
│   └── values.nix         # enabled, disabled helpers
├── modules/
│   ├── common/            # Cross-platform system modules
│   ├── linux/             # NixOS-specific modules
│   └── darwin/            # nix-darwin-specific modules
├── home/
│   ├── common/            # Cross-platform home-manager modules
│   ├── linux/             # Linux-specific home modules
│   └── darwin/            # macOS-specific home modules
└── hosts/
    ├── vm/                # NixOS VM configuration
    ├── vps/               # NixOS VPS configuration
    └── mbp/               # macOS MacBook Pro configuration
```

## Usage

This flake uses experimental Nix features (`pipe-operators`). These must be enabled before the flake can be evaluated.

**Option 1: Global config (recommended)**
```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes pipe-operators" > ~/.config/nix/nix.conf
```

**Option 2: Pass flag each time**
```sh
nix --extra-experimental-features pipe-operators <command>
# or with nh
nh darwin build . -- --extra-experimental-features pipe-operators
```

### macOS (nix-darwin)

**First time setup:**
```sh
# Install nix (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Enable experimental features (required to evaluate flake)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes pipe-operators" > ~/.config/nix/nix.conf

# Clone and apply
git clone https://github.com/caluckenbach/nixos-config.git
cd nixos-config
nix run nix-darwin -- switch --flake .#mbp
```

**Rebuild after changes (nh includes pretty output via nom):**
```sh
nh darwin switch .
# or build only
nh darwin build .
```

**Update Homebrew packages (managed via nix-homebrew):**
```sh
nix flake update homebrew-core homebrew-cask
nh darwin switch .
```

### NixOS (Linux)

**Rebuild system:**
```sh
nh os switch .
# or build only
nh os build .
```

## Hosts

| Host | Platform | Type | User |
|------|----------|------|------|
| `mbp` | macOS (aarch64-darwin) | Desktop | cal |
| `vm` | NixOS (aarch64-linux) | Desktop | morpheus |
| `vps` | NixOS (x86_64-linux) | Server | morpheus |

## What's Included

### System
- Nix flakes with automatic host discovery
- Home Manager integration
- Platform-specific defaults (macOS: Dock, Finder, keyboard settings)
- Homebrew integration for macOS casks not in nixpkgs

### Shell & Terminal
- Zsh with autosuggestions, syntax highlighting
- Starship prompt
- Ghostty terminal
- Zellij multiplexer with zjstatus

## Keybindings

Modifier hierarchy for consistent muscle memory across tools:
- **Ctrl** = Pane operations (Zellij)
- **Cmd** = Tab operations (Ghostty)
- **+ Shift** = Destructive/moving operations
- **+ Alt** = Resize operations

### Zellij (Panes)

| Action | Keybind |
|--------|---------|
| Navigate panes | `Ctrl+h/j/k/l` |
| Move panes | `Ctrl+Shift+h/j/k/l` |
| Resize panes | `Ctrl+Alt+h/j/k/l` |
| New pane down | `Ctrl+p d` |
| New pane right | `Ctrl+p r` |
| Close pane | `Ctrl+p x` |
| Toggle floating | `Alt+f` |

### Ghostty (Tabs)

| Action | Keybind |
|--------|---------|
| New tab | `Cmd+t` |
| Close tab | `Cmd+w` |
| Previous tab | `Cmd+Shift+[` |
| Next tab | `Cmd+Shift+]` |

### Development
- **Editors:** Neovim, Helix, Zed (macOS)
- **VCS:** Git, Jujutsu, lazygit, gitui
- **Languages:** Rust (rustup, bacon), Python (uv, ruff), Bun, Lua
- **LSP:** nil, lua-language-server, ruff
- **Formatters:** nixfmt-rfc-style, stylua, ty

### Tools
- eza, bat, ripgrep, fd, fzf, zoxide
- yazi, glow, jless, jnv
- ffmpeg, yt-dlp, xh, tokei
- nix-output-monitor (nom)

### AI/LLM
- claude-code
- opencode
- llm

### macOS Apps (via nix)
- Raycast, Anki, Telegram, Zotero, OrbStack

### macOS Apps (via Homebrew)
- Figma, ProtonVPN, Sublime Text

## TODO
- VPS: ensure `morpheus` has a password or passwordless sudo to avoid lockout when SSH password auth and root login are disabled.
- Review Linux firewall defaults; currently disabled by default.
- Consider avoiding `bun install -g` in activation scripts; move to declarative packages or pin versions.
- README: reconcile formatter/tool list (mentions `nixfmt-rfc-style` but config installs `nixfmt`).
- Homebrew-to-Nix review (macOS): periodically re-check `gitui` and `yt-dlp` in nixpkgs and move back to Nix packages when stable.
