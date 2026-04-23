---
description: Audit docs↔code drift and fix it in one batch. `--check` — report only, no edits. Heavy scan runs in a fresh atlas-auditor subagent context.
---

# /atlas:sync

Single maintenance entry point. Two modes — interactive fix (default) or read-only report (`--check`). Nothing else.

Prerequisite: the repo is atlas-style (see the `atlas` skill for detection). If not, output one line: `not an atlas repo — run /atlas:init to bootstrap`, and stop.

## Flow

### 1. Dispatch the audit

Call the `atlas-auditor` subagent via the Task tool. It runs in a fresh context, scans the repo, returns a compact structured report.

Prompt to the subagent (verbatim):

```
Audit this atlas-style repo for docs↔code drift. Working dir: <absolute path>.

Procedure:
1. List every file under the repo root, excluding: .git, .idea, .vscode, .claude, node_modules, venv, .venv, __pycache__, dist, build, and anything matched by .gitignore. Exclude docs/ from the code side.
2. Parse `mirrors:`-frontmatter in each docs/**/*.md. Build {doc → [glob, ...]}.
3. For each code file, test whether any doc's glob matches. If none — Undocumented.
4. For each file path referenced inside docs, verify it exists on disk. If not — Orphan.
5. Spot-check high-value claims (counts, command names, port numbers, plugin names). If contradicted by code — Drift.

Return ONLY the report in the exact format below, nothing else:

# atlas audit

## Undocumented (N)
- <code path> — <one-line reason>

## Orphan (N)
- <doc path> — <dead code path>

## Drift (N)
- <doc path>[:line] — <claim> vs <reality>

## Summary
<one sentence>

Empty sections print (0). No preamble, no extra commentary.
```

### 2. Print the report

Show the report to the user verbatim.

If all three counts are 0 → print `healthy. no edits.` and stop.

**If invoked as `/atlas:sync --check`** → stop here regardless of counts. Do not propose edits, do not apply anything.

### 3. Build the edit plan

For each item, classify into an edit:

- **Undocumented** → CREATE: create `docs/<same-path>/<basename>.md` for the code file (with `mirrors:`-frontmatter), and/or `docs/<folder>/ABOUT.md` if the containing folder has no ABOUT.md yet. Infer the 1-line purpose by reading the code.
- **Orphan** → DELETE: remove the doc file whose target code no longer exists. If an `ABOUT.md` still has live siblings, just strip the dead entry from its Contents list.
- **Drift** → UPDATE: rewrite the stale passage to match the code. Read the code (not just the doc) to produce the fix.

Print planned edits as a numbered list:

```
Planned edits (N):
  1. CREATE docs/src/api/info.md — for new file src/api/info.py
  2. UPDATE docs/deployments/ABOUT.md:12 — PORT=8080 → PORT_PROD=8090
  3. DELETE docs/src/api/old.md — src/api/old.py no longer exists
```

### 4. Single confirmation

Ask once: «Apply all N edits? (y / pick: 1,3,5 / n)».

- `y` → apply all
- `1,3,5` → apply only those indexes
- `n` → abort, print `no changes`, stop

One confirmation for the whole batch. No per-edit prompts, no auto-bypass flag.

### 5. Apply edits

One at a time, in order: ADDs first, then UPDATEs, then DELETEs. After each, print `✓ <verb> <path>`.

If an edit fails (file moved since the audit, conflict, etc.) — print `✗ <verb> <path> — <reason>` and continue with the rest.

### 6. Re-audit

Dispatch the auditor again. Print the new report. Final line:

```
sync: <applied>/<planned> edits, drift after: <remaining count>
```

## Rules

- Never invent content. If you cannot infer a file's purpose from reading it, use a TODO line (`TODO: describe <file>`).
- Preserve user-written prose. Rewrite only sections that drifted.
- On conflict between a hand-written AGENTS.md mapping and mirrors frontmatter, mirrors win (source of truth).
- Mirror-структура `docs/` 1-в-1 совпадает с кодом: каждый code-файл имеет одноимённый `<file>.md` в `docs/<path>/`, каждая code-папка — `ABOUT.md`. Добавляя — поддерживай этот параллелизм, не изобретай альтернативные имена.

## Failure modes

- **Auditor subagent unavailable** → fall back to inline audit in the main context. Warn: `auditor unavailable, running inline — context will be larger than usual`.
- **Repo is huge (>1000 code files)** → auditor may truncate. Suggest the user narrow scope to specific folders.
- **Mirrors frontmatter malformed** (e.g. invalid YAML) → stop, quote the malformed block, ask the user to fix.
