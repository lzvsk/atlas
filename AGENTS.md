# atlas

Claude Code plugin: `docs/` mirrors the code 1-to-1. Every code change updates the matching doc in the same turn. This repo is both the plugin **and** a dogfood of its methodology.

## Navigation

- **Plugin architecture:** `docs/ARCHITECTURE.md` — stack, components, flows, boundaries
- **Docs index:** `docs/ABOUT.md`
- **Code mirrors** (one folder per code folder):
  - `docs/commands/` ← `commands/`
  - `docs/skills/` ← `skills/`
  - `docs/agents/` ← `agents/`
  - `docs/hooks/` ← `hooks/`

## Code ↔ docs

Source of truth for the mapping is the `mirrors:`-frontmatter in each doc file. The table below is a human-readable summary.

| Code | Matching doc |
|---|---|
| `commands/<file>.md` | `docs/commands/<file>.md` |
| `skills/<name>/<file>.md` | `docs/skills/<name>/<file>.md` |
| `agents/<file>.md` | `docs/agents/<file>.md` |
| `hooks/<file>` | `docs/hooks/<basename>.md` (extension stripped) |
| `.claude-plugin/plugin.json` | `docs/ARCHITECTURE.md` |
| `README.md`, `AGENTS.md`, `CLAUDE.md`, `INSTRUCTIONS.md`, `license.txt`, `.gitignore` | not documented (housekeeping) |

## Rules

1. Any code change updates the matching doc in the same turn.
2. No matching doc? Create one (file with the same basename as the code file, with `mirrors:`-frontmatter).
3. No aspirational content. Stale content is deleted, not marked `(deprecated)`.
4. This file is a router, ≤100 lines. Details live in `docs/`.
5. Before declaring a code-touching task done — run `/atlas:sync --check`. If drift > 0 — either `/atlas:sync` to fix, or explicitly tell the user the repo is out of sync.

## Commands

Two, no complex flags:

- `/atlas:init` — bootstrap a fresh repo. Interactive, no flags.
- `/atlas:sync` — audit + fix (one confirmation for the whole batch). `--check` — report only.

## When atlas fires

1. After any code edit — the `hooks/remind-doc.sh` hook prints which doc to update.
2. In any conversation about docs/structure/"where does X go" — the `atlas` skill activates.
3. On explicit `/atlas:init` or `/atlas:sync`.
4. Before declaring a task done — rule 5 (closing ritual).

## Install & usage

See `README.md` at the root.

## License

WTFPL — `license.txt`.
