---
mirrors:
  - plugins/atlas/agents/atlas-auditor.md
---

# agents/atlas-auditor.md

The `atlas-auditor` subagent. Read-only scan of an atlas-style repo for drift between code and `docs/`.

## Tools

Read, Bash, Grep, Glob. No Write/Edit.

## Input

Absolute path to the repo. Optionally, a limited scope (list of top-level folders).

## Output

Structured report:
- `Undocumented (N)` — code files that no doc claims via `mirrors:`.
- `Orphan (N)` — doc files referencing a code path that no longer exists.
- `Drift (N)` — spot-checked inconsistencies between doc claims and code reality (command names, file counts, port numbers, plugin names).
- `Summary` — one-sentence verdict.

## How it's used

Invoked from `commands/sync.md` step 1. Can also be called directly through the Task tool for an ad-hoc audit without a follow-up fix.

## Limits

Never writes files, never commits, never runs repo scripts. For very large repos (>1000 code files) it may truncate — it reports that in Summary and suggests narrowing the scope.
