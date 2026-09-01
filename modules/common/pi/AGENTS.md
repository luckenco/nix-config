# PI AGENT CONFIG

Global pi config at `~/.pi`. `settings.json` packages and this file are managed by nix (see `modules/common/pi.nix` in `~/Code/nix-config`) — edit them there, not here.

## Structure

- `agent/settings.json` — models, theme, packages. Edit directly or via `/settings`.
- **pinnacle package** (`git:github.com/luckenco/pinnacle`) — personal extensions, skills (github, jj, uv), prompts, themes. Source of truth is the repo at `~/Code/pinnacle`. The clone at `~/.pi/agent/git/github.com/luckenco/pinnacle` is managed by pi; `pi update --extensions` resets/cleans it. Edit the repo, not the clone. `prompts/` is intentionally kept even while empty.
- `agent/extensions/codex-fast.json` — runtime state written by the codex-fast `/fast` toggle.
- `agent/extensions/herdr-agent-state.ts` — managed by herdr; reinstalling herdr overwrites it.

## Skills — two homes

- `~/.agents/skills/` — canonical cross-agent skills (mysql, postgres, and the rest).
- `~/.pi/agent/skills/` — pi-discovered skills. Most files here are exact copies of `~/.agents/skills` ones; herdr-installed skills (herdr, web-perf, sandbox-*, cloudflare-*) live here and are herdr/Cloudflare-installer managed.

When adding or editing a skill: use `~/.agents/skills/` unless an installer owns it. Never copy skills between the two homes — dedupe instead.

## MCP

Servers are configured in the shared config `~/.config/mcp/mcp.json`, bridged by `npm:pi-mcp-adapter`. `agent/mcp-cache.json` and `agent/mcp-onboarding.json` are runtime state.

## Runtime state

Never edit or commit: `auth.json`, `models-store.json`, `mcp-cache.json`, `mcp-onboarding.json`, `trust.json`, `sessions/`, `.DS_Store`.

## Conventions

- Default provider is `openai-codex`. Startup model and thinking level are saved via `/model` and `/thinking` with Ctrl+S — if `defaultModel` in settings.json disagrees with the model you actually use, press Ctrl+S to fix it.
- `enabledModels` scopes Ctrl+P cycling; patterns are minimatch on `provider/modelId`.
- Packages use `git:` shorthand. Unpinned sources track the default branch; pin with `@ref` to freeze.

## Anti-patterns

- Editing the git clone instead of `~/Code/pinnacle`
- Copying skills between the two skill homes
- Adding personal extensions under `agent/extensions/` — put them in the pinnacle repo so they're versioned; leave `extensions/` for tool-managed files (herdr, codex-fast state)
