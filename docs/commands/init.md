---
mirrors:
  - commands/init.md
---

# commands/init.md

The `/atlas:init` command. Interactive bootstrap of the atlas structure in an empty or existing repo.

## What it does

1. Inspects what's already at the root: `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/`. Builds a per-file plan with create / merge / prepend / skip actions.
2. Asks 4 short questions: project name, doc language (ru/en, default ru), one-sentence purpose, audience.
3. Scans the repo root for stack manifests (`package.json` / `pyproject.toml` / `go.mod` / `Dockerfile` / `docker-compose.yml` / `.github/workflows/`) and the full code tree.
4. Prints the file plan with per-file actions. Waits for confirmation.
5. Generates: root `AGENTS.md` (+ `CLAUDE.md` symlink/wrapper, + `README.md` if missing), `docs/ARCHITECTURE.md`, `docs/ABOUT.md`, and a full code-tree mirror in `docs/` (per-folder `ABOUT.md`, per-file same-named `.md` with `mirrors:`-frontmatter).

## Non-destructive

Existing files are not overwritten. See `init.md` step 1 for the per-file policy table.

## Flags

None. Everything is controlled through the interactive dialogue.
