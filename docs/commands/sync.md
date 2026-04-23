---
mirrors:
  - commands/sync.md
---

# commands/sync.md

The `/atlas:sync` command. Drift audit between code and `docs/`, with optional fix.

## What it does

1. Invokes the `atlas-auditor` subagent in a fresh context.
2. The auditor scans the repo, resolves `mirrors:`-frontmatter, returns a structured report: Undocumented (code without a matching doc), Orphan (docs pointing at code that no longer exists), Drift (doc claims contradicting the code).
3. Prints the report to the user.
4. If `--check` → stops at the report.
5. Otherwise → builds an ADD/UPDATE/DELETE edit plan, asks one confirmation (`y` / `1,3,5` / `n`), applies.
6. Re-runs the auditor afterwards, prints the remaining count.

## Flags

- No flags: interactive fix.
- `--check`: report only, no edits.

## Rules

Sync does not invent content — if it can't infer a file's purpose, it leaves a `<TODO>`. It preserves user-written prose and only rewrites the parts that drifted. On conflict between a hand-written AGENTS.md mapping and `mirrors:`-frontmatter, frontmatter wins.

The `docs/` tree mirrors the code 1-to-1: every code file has a same-named `<file>.md` under `docs/<path>/`, every code folder has an `ABOUT.md`. When adding docs, preserve this parallelism — don't invent alternative naming.
