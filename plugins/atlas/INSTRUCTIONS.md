# Atlas v0.1 — cheatsheet

Claude Code plugin: `docs/` mirrors the codebase 1-to-1. Two slash commands, one skill, one subagent, one hook.

## Install

After GitHub push:
```
/plugin marketplace add lzvsk/atlas
/plugin install atlas
/reload-plugins
```

## Commands

### `/atlas:init` — once per repo

Interactive bootstrap:
1. Checks what already exists (`AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/`).
2. Asks: name, doc language (en/ru, default en), purpose, audience.
3. Scans code — stack (Python/Node/Go/…), full folder/file tree.
4. Shows a plan with per-file actions `[create]` / `[merge]` / `[prepend]` / `[skip]`.
5. Waits for confirmation.
6. Generates: AGENTS.md, CLAUDE.md, README.md (if missing), `docs/ARCHITECTURE.md`, `docs/ABOUT.md`, and a full mirror of the code tree (per-folder `ABOUT.md`, per-file same-named `.md`).

### `/atlas:sync` — regularly

- `/atlas:sync --check` — report only: Undocumented / Orphan / Drift.
- `/atlas:sync` — report + edit plan + single confirmation + apply.

Under the hood: the `atlas-auditor` subagent runs the scan in a fresh context.

## What init produces in an empty repo

```
<repo>/
├── AGENTS.md               agent entry + rules
├── CLAUDE.md               symlink or wrapper → AGENTS.md
├── README.md               human-facing (if missing)
└── docs/
    ├── ARCHITECTURE.md     stack, components, flows, boundaries
    ├── ABOUT.md            docs/ index
    └── <folder>/           mirror of each code folder
        ├── ABOUT.md        describes the folder
        ├── <file>.md       same-named doc for each code file
        ├── <subfolder>/    recursive
        │   ├── ABOUT.md
        │   └── <file>.md
```

**Rule:** the mirror file's name equals the code file's basename (extension stripped). `src/api/auth.py` → `docs/src/api/auth.md`. Nesting is 1-to-1.

## What init does in an existing repo

**Non-destructive:**
- Existing `AGENTS.md` → **MERGE**: adds only missing sections at the end under a single wrapper `## Added by /atlas:init <date>`. Doesn't touch your existing sections.
- Existing `CLAUDE.md` symlink → **SKIP**. With content → **PREPEND** one line `> See also: [AGENTS.md](AGENTS.md)` at the top.
- Existing `README.md` → **SKIP**.
- Existing file under `docs/` → **SKIP**.
- Missing file → **CREATE**.

## `mirrors:` frontmatter

Every `<file>.md` and every `ABOUT.md` carries a YAML frontmatter:
```yaml
---
mirrors:
  - src/api/auth.py
---
```
- `<file>.md` claims the exact code path.
- `ABOUT.md` claims a glob over its folder (`<folder>/**`).

The hook and the auditor resolve the mapping through this frontmatter.

## PostToolUse hook

After Edit/Write/MultiEdit inside an atlas-style repo, prints to the agent's context:
```
[atlas] edited src/api/auth.py — update matching doc: docs/src/api/auth.md
```

Gate: fires only if both `AGENTS.md` and `docs/` exist at `cwd`.

Skip-list: `docs/**`, AGENTS.md/CLAUDE.md/README.md, INSTRUCTIONS.md/CHANGELOG.md, `.gitignore`/`.gitkeep`/`.DS_Store`, `.env*`, `.git/**`/`.idea/**`/`.vscode/**`/`.claude/**`, `*.lock`/`*.pyc`/`*.map`.

Requires bash + optionally python3 (for parsing mirrors).

## Rules for the agent (in the generated AGENTS.md)

1. Change code — update the matching doc in the same turn.
2. No matching doc — create one with `mirrors:` frontmatter.
3. No aspirational content. Stale content — delete.
4. Before declaring a code-touching task done — `/atlas:sync --check`.

## v0.1 limitations

- Hook requires bash + (opt.) python3; no Windows variant.
- Drift fix in `/atlas:sync` is performed by the main Claude (no dedicated writer subagent).
- No CI recipe for auto-running `/atlas:sync --check`.
- No MADR template for ADR entries.

## Troubleshooting

- Skill doesn't activate? You need BOTH `AGENTS.md` AND `docs/` at the root.
- Hook doesn't fire? Check `chmod +x hooks/remind-doc.sh` and `python3` in PATH.
- Init overwrote something? It shouldn't — this is a bug, please open an issue.
