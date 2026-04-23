---
description: Bootstrap atlas docs in this repo. Scans the code, generates AGENTS.md + docs/ as a 1-to-1 mirror of the code tree (ABOUT.md per folder, same-named .md per file). Interactive; non-destructive (merges into existing AGENTS.md, skips other existing files).
---

# /atlas:init

Bootstrap atlas structure. Run once per repo. Idempotent — on re-run it only fills missing slots and never overwrites existing content.

Goal: after `/atlas:init`, the repo has an `AGENTS.md` with the real (scanned) stack and component mapping + `docs/` as a full 1-to-1 mirror of the code tree with per-file descriptions.

## Flow

### 1. Detect existing state — per-file, per-section

List what's present at the root: `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/`. For an existing AGENTS.md — list its `##` section headers.

**Non-destructive contract — per-file policy:**

| File exists? | AGENTS.md | CLAUDE.md | README.md | `docs/**/*.md` |
|---|---|---|---|---|
| No | CREATE | CREATE (wrapper or symlink — ask) | CREATE (if audience includes people) | CREATE |
| Yes, content | MERGE | PREPEND one-liner | SKIP | SKIP |
| Yes, symlink | — | SKIP (leave as is) | — | — |

Legend:
- **CREATE** — write from template.
- **MERGE** — only for AGENTS.md. Parse `##` headers; append only missing sections at the end under a single wrapper `## Added by /atlas:init <YYYY-MM-DD>` (or Russian equivalent if language=ru). Never touch content above the wrapper. For sections with matching names (case-insensitive) — ask "yours / template / merge manually" (default — yours).
- **PREPEND one-liner** — for a CLAUDE.md file with content. Insert one line `> See also: [AGENTS.md](AGENTS.md)` at the top (if not already there).
- **SKIP** — leave as is.

Ask one question: "Non-destructive mode. Proceed?" (default proceed).

### 2. Gather project metadata

- **Project name** — default to the repo folder name, confirm.
- **Documentation language** — `en` (default) / `ru`. Determines the language of generated template content.
- **One-sentence purpose** — "what does this repo do?" in the chosen language. If skipped — `<TODO>`.
- **Audience** — people + agents (default), agents only, people only (affects whether README.md is generated).

### 3. Scan the code

Walk the repo (exclude `.git`, `.idea`, `.vscode`, `.claude`, `node_modules`, `venv`, `.venv`, `__pycache__`, `dist`, `build`, `target`, gitignored paths, and `docs/`).

**Stack** — look for manifests:
- `package.json` → Node/JS (top-10 deps, framework)
- `pyproject.toml` / `requirements.txt` / `Pipfile` → Python + framework
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml` / `build.gradle` → Java
- `Gemfile` → Ruby
- `composer.json` → PHP
- `Dockerfile` / `docker-compose.yml` → containerization, services
- `.github/workflows/` → CI
- `tsconfig.json` → TypeScript

Report findings, ask "correct? (y / edit / add)".

**Code tree** — full recursive walk: all code folders and code files. Exclude housekeeping (`AGENTS.md`, `CLAUDE.md`, `README.md`, `INSTRUCTIONS.md`, `CHANGELOG.md`, `license.txt`, `LICENSE*`, `.gitignore`, `.gitkeep`, `.DS_Store`, `.env*`, `*.lock`, `*.pyc`, `*.map`, hidden dot-folders like `.github/`).

Special case: `.claude-plugin/`, `.github/`, and other top-level dot-configs — document via `docs/ARCHITECTURE.md` (Dependencies or Components section), not via a separate `docs/.claude-plugin/` folder.

### 4. Confirm the file list

Print the plan with per-file actions:

```
Will do:
  [create]  AGENTS.md
  [create]  CLAUDE.md                                  (symlink or wrapper — ask)
  [create]  README.md                                  (audience = people + agents)
  [create]  docs/ARCHITECTURE.md
  [create]  docs/ABOUT.md
  [create]  docs/src/ABOUT.md
  [create]  docs/src/api/ABOUT.md
  [create]  docs/src/api/auth.md
  [create]  docs/src/api/routes.md
  [create]  docs/src/core/ABOUT.md
  [create]  docs/src/core/config.md
  [create]  docs/tests/ABOUT.md
  [create]  docs/tests/test_auth.md
```

For existing repos — the appropriate `[merge]` / `[skip]` / `[prepend]` labels.

Ask "apply / drop: <items> / abort".

### 5. Generate — non-destructive

Four actions: create / merge / prepend / skip (see step 1).

Templates below are in English (the default language). For `language=ru` — translate headers and stock phrases equivalently using the en↔ru table at the end of this section.

---

**`AGENTS.md`** (≤100 lines):

```markdown
# <Project name>

<one-sentence purpose>

> This file is the entry point for agents and humans. The full working methodology for this repo lives here.

## Stack

<from step 3: Language, Framework(s), Containerization, CI, key libs>

## Components

<one bullet per top-level code folder + inferred role>

## Navigation

| Section | Path |
|---|---|
| Architecture (stack, components, flows, boundaries) | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| docs/ index | [`docs/ABOUT.md`](docs/ABOUT.md) |
| Code mirrors | `docs/<folder>/` for each code folder |

## Code ↔ docs

Rule: every code file has a corresponding `docs/<same-path>/<file>.md` (basename without extension); every code folder has `docs/<same-path>/ABOUT.md`.

Example: `src/api/auth.py` → `docs/src/api/auth.md`. `src/api/` → `docs/src/api/ABOUT.md`.

| Code | Matching doc |
|---|---|
<one row per detected top-level code folder>
| `README.md`, `AGENTS.md`, `CLAUDE.md`, housekeeping | not documented |

## Rules for the agent

1. **Code change → update the matching doc in the same turn.** For a code file, the same-named `<file>.md` under the mirror. For folder-structure changes, the folder's `ABOUT.md`.
2. **No matching doc** — create a same-named `<file>.md` with `mirrors:`-frontmatter pointing at the exact code path.
3. **No aspirational content.** Either it describes real code, or don't write it. Stale content — delete.
4. **Before declaring done** in a code-touching session — run `/atlas:sync --check`. Drift > 0 → `/atlas:sync` (fixes it) or explicitly tell the user the repo is out of sync.

## Atlas commands

- `/atlas:init` — already done.
- `/atlas:sync` — drift audit + fix (one confirmation).
- `/atlas:sync --check` — report only.

## License

<from license.txt or TODO>
```

---

**`CLAUDE.md`** — ask: "symlink or wrapper file? (default wrapper)". Wrapper content: one line `# See [AGENTS.md](AGENTS.md)`. If already exists with content — prepend `> See also: [AGENTS.md](AGENTS.md)` at the top (if not already there).

---

**`README.md`** (if missing and audience ≠ agents-only):

```markdown
# <Project name>

<one-sentence purpose>

## Stack

<from scan>

## Quick start

<TODO: 1-3 lines install/run>

## Documentation

Technical documentation lives in `docs/`. Agents: start at `AGENTS.md`.

## License

<from license.txt or TODO>
```

---

**`docs/ARCHITECTURE.md`**:

```markdown
---
mirrors:
  - <manifest from scan: pyproject.toml / package.json / go.mod / etc>
---

# Architecture

<one paragraph: what this project is runtime-wise>

## Stack

<detailed from scan>

## Components

<top-level code folders, 1-2 sentence role + key files>

## Flows

<TODO: data/control flow between components>

## Boundaries

<TODO: what this project does NOT do; what lives in other repos/services>

## Dependencies

<external services/APIs/infra — from docker-compose, CI, env files, .claude-plugin/, .github/>
```

Flows and Boundaries are usually not fillable at init time — leave `TODO:`, mention in the final report.

---

**`docs/ABOUT.md`**:

```markdown
# docs/

Documentation for <Project name>.

## Structure

- `ARCHITECTURE.md` — technical architecture (stack, components, flows, boundaries).
- Code mirrors — one folder per code folder, 1-to-1 with the project tree:

<one bullet per top-level code folder:>
- `<folder>/` ← mirror of `<folder>/` at the root. Contains `ABOUT.md` + same-named `.md` files for each code file.
```

---

**`docs/<path>/ABOUT.md`** (per code folder, recursive):

```markdown
---
mirrors:
  - <path>/**
---

# <path>/

<one paragraph: what this folder contains, why it exists>

## Contents

<one bullet per item:>
- `<subfolder>/` — <1-line role> (see `<subfolder>/ABOUT.md`)
- `<file>.<ext>` — <1-line inferred purpose> (see `<file>.md`)
```

---

**`docs/<path>/<file>.md`** (per code file):

```markdown
---
mirrors:
  - <exact code path>
---

# <exact code path>

<one paragraph: what's in this file — inferred from reading the code>

<optionally — structural blocks based on file type:>
- For config files: list of keys/env vars with descriptions.
- For route files: endpoints table.
- For modules with a public API: list of exported functions/classes.
```

If a file is not auto-interpretable — leave `<TODO: describe <file>>`.

---

**Language override (ru):** when `language=ru`, translate headers and stock phrases equivalently:

| en | ru |
|---|---|
| Stack | Стек |
| Components | Компоненты |
| Navigation | Навигация |
| Code ↔ docs | Код ↔ docs |
| Rules for the agent | Правила для агента |
| Atlas commands | Команды atlas |
| License | Лицензия |
| Structure | Структура |
| Contents | Содержимое |
| Flows | Потоки |
| Boundaries | Границы |
| Dependencies | Зависимости |
| Documentation | Документация |
| Added by /atlas:init | Добавлено /atlas:init |

Not a machine translation — use the established equivalents.

### 6. Final report

```
atlas: initialized
  scanned: <X> code files across <N> folders
  generated: <N> doc files  (<created> created, <merged> merged, <skipped> skipped)
  TODO sections: ARCHITECTURE.md Flows/Boundaries; <N> per-file TODO descriptions

next: read AGENTS.md; then fill TODOs in docs/ARCHITECTURE.md and in mirror files where the agent couldn't infer a description.
```

Then the one-line summary per skill format.

## Rules

- **Non-destructive default.** Existing files are not overwritten. Merge / prepend / skip per the table in step 1.
- No empty markdown files. A TODO line is the placeholder.
- If the user declines a section, don't create it — and don't silently re-add on re-run.
- Don't invent content. If scan + user answers don't yield enough — TODO.
- Use `date +%Y-%m-%d` for dates, don't guess.
- On MERGE — a single wrapper section `## Added by /atlas:init <date>` (or Russian equivalent) at the end; never touch content above the wrapper, never reorder the user's sections.
- Mirror is strict 1-to-1: every code file → same-named `<file>.md`; every code folder → `ABOUT.md`. Don't invent alternatives.
