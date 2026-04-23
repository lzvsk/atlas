---
name: atlas
description: Activate in any atlas-style repo (has `AGENTS.md` + `docs/` at the root). Enforces "docs are the source of truth" — every code change updates the matching doc. Triggers on `/atlas:*` commands, on code edits in such a repo, or when the user asks to init / check drift / update docs.
---

# atlas

Plugin for the "docs/ mirrors the code" discipline. Lightweight helper: **bootstraps** the docs at start (`/atlas:init`) and **maintains** sync with the code (`/atlas:sync`). The methodology and per-repo mapping live in the repo's own `AGENTS.md` — this skill supplies only the minimum rules and entry points.

## Recognize an atlas repo

A repo is atlas-style if:
- `AGENTS.md` exists at the root, AND
- `docs/` folder exists.

Otherwise the skill is inactive. Do not impose structure on non-atlas projects.

Edge case: `AGENTS.md` exists, `docs/` is empty or missing → init-needed mode. Tell the user `run /atlas:init to bootstrap` and stop.

## First thing to do in a session — read the repo's AGENTS.md

It contains: Code↔docs mapping, stack, components, per-repo rule specifics. **The repo's AGENTS.md is the methodology source of truth for that project.** This skill is a fallback when AGENTS.md doesn't cover something.

## Fallback rules

1. Any code change updates the matching doc in the same turn. Matching — `docs/<mirror-path>/<file>.md` or `docs/<folder>/ABOUT.md` (for folder-structure changes).
2. No matching doc — create one next to existing `ABOUT.md`/`<file>.md` in `docs/`.
3. No aspirational content. Either it exists in code, or don't write it.
4. Stale content — delete. Don't mark `(deprecated)`.
5. Before declaring a code-touching task done — run `/atlas:sync --check`. If drift > 0 — either `/atlas:sync` to fix, or explicitly tell the user the repo is out of sync.

## Commands

- `/atlas:init` — bootstrap in an empty/fresh repo. Scans code, creates AGENTS.md + `docs/` with meaningful content. No flags.
- `/atlas:sync` — drift audit + fix. Default: auditor → edit plan → single confirmation → apply. `--check` — report only.

## Mirrors frontmatter — how parsers resolve

The `remind-doc.sh` hook and the `atlas-auditor` subagent resolve the code↔docs mapping through YAML frontmatter in `docs/**/*.md`:

```yaml
---
mirrors:
  - src/api/auth.py
---
```

Each `docs/<file>.md` claims the exact path of its code file. Each `docs/<folder>/ABOUT.md` claims a glob over its folder (`<folder>/**`). The hook surfaces the most specific match.

The Code↔docs table in AGENTS.md is a human-readable summary. If it disagrees with the frontmatter, the frontmatter wins.

## End-of-turn report

If the turn changed code or docs — close with:
```
code: <files> | docs: <files or "no-op">
```
Skip this on discussion turns where no file was written.
