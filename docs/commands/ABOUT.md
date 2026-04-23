---
mirrors:
  - plugins/atlas/commands/**
---

# commands/

Slash commands of the plugin. User entry points; they inject a prompt into the main context, while the real work is done by the skill and the subagent.

## Files

- `init.md` — `/atlas:init`. Bootstraps the atlas structure in a repo.
- `sync.md` — `/atlas:sync`. Drift audit + fix.
