---
mirrors:
  - plugins/atlas/hooks/remind-doc.sh
---

# hooks/remind-doc.sh

PostToolUse bash hook script. After every code edit it resolves the edited path against `mirrors:`-frontmatter in `docs/**/*.md` and prints a reminder into the agent's context to update the matching doc.

## Dependencies

- Bash (required).
- `jq` (optional — for parsing input JSON; fallback is sed).
- `python3` (optional — for resolving mirrors via fnmatch; fallback is a generic reminder without resolution).

## Gate

Fires only in atlas-style repos: both `AGENTS.md` and `docs/` must exist in cwd. Otherwise exits 0 silently.

## Skip-list

Does not remind for: `docs/**`, `AGENTS.md`/`CLAUDE.md`/`README.md`, `INSTRUCTIONS.md`/`CHANGELOG.md`, `.gitignore`/`.gitkeep`/`.DS_Store`, `.env*`, `.git/**`/`.idea/**`/`.vscode/**`/`.claude/**`, `*.lock`/`*.pyc`/`*.map`.

## Behaviour

1. Reads stdin, extracts the edited path.
2. Checks the gate and skip-list.
3. Calls python3 to parse frontmatter across `docs/**/*.md` and match the path against `mirrors:` globs.
4. For each matching doc, prints: `[atlas] edited <path> — update matching doc: <doc-path> (claims via mirrors: frontmatter)`.
5. If nothing matches, prints: `[atlas] edited <path> — no doc claims this path via mirrors:. Add a mirror or log debt.`

Exit code is always 0.
