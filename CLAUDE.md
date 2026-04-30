# atlas

Claude Code plugin: `docs/` mirrors the code 1-to-1. Every code change updates the matching doc in the same turn. This repo is both the plugin **and** a dogfood of its methodology.

## Repo layout

Marketplace repo. The actual plugin lives in `plugins/atlas/`.

## Navigation

- **Plugin architecture:** `docs/ARCHITECTURE.md`
- **Docs index:** `docs/ABOUT.md`
- **Code mirrors:**
  - `docs/commands/` ← `plugins/atlas/commands/`
  - `docs/skills/` ← `plugins/atlas/skills/`
  - `docs/agents/` ← `plugins/atlas/agents/`
  - `docs/hooks/` ← `plugins/atlas/hooks/`

## Code ↔ docs

| Code | Matching doc |
|---|---|
| `plugins/atlas/commands/<file>.md` | `docs/commands/<file>.md` |
| `plugins/atlas/skills/<name>/<file>.md` | `docs/skills/<name>/<file>.md` |
| `plugins/atlas/agents/<file>.md` | `docs/agents/<file>.md` |
| `plugins/atlas/hooks/<file>` | `docs/hooks/<basename>.md` |
| `plugins/atlas/.claude-plugin/plugin.json` | `docs/ARCHITECTURE.md` |

## Rules

1. Любое изменение кода — обновляй matching doc в той же сессии.
2. Нет matching doc — создай с `mirrors:`-frontmatter.
3. Без aspirational content. Устаревшее — удалять, не помечать.
4. Этот файл — роутер, ≤100 строк. Детали живут в `docs/`.
5. Перед завершением задачи — `/atlas:sync --check`.

## Commands

- `/atlas:init` — bootstrap репо. Интерактивно.
- `/atlas:sync` — аудит + фикс. `--check` — только отчёт.

## When atlas fires

1. После любого Edit/Write — хук `remind-doc.sh` подсказывает какой doc обновить.
2. В разговоре про docs/структуру — скилл `atlas` активируется.
3. На явные `/atlas:init` или `/atlas:sync`.

## License

WTFPL — `license.txt`.
