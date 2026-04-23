# docs/

Project documentation. Two kinds of files:

- `ARCHITECTURE.md` — overall technical architecture of the project (stack, components, flows, boundaries).
- **Code mirror** — every code folder has a same-named folder inside `docs/` containing:
  - `ABOUT.md` — describes the folder: purpose, subfolders, files.
  - `<file>.md` — one markdown per code file, describes what's inside that code file.

The mirror file's name matches the code file's basename (extension stripped). Example: `commands/init.md` → `docs/commands/init.md` (here `.md` already existed). `hooks/remind-doc.sh` → `docs/hooks/remind-doc.md`.

## Folders

- `commands/` — mirror of `commands/` (slash commands of the plugin).
- `skills/` — mirror of `skills/`.
- `agents/` — mirror of `agents/`.
- `hooks/` — mirror of `hooks/`.
