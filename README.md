# atlas

> Harness engineering. Harness your repo before it harnesses you.

Claude Code plugin that keeps `docs/` as a 1-to-1 mirror of your codebase. Two slash commands, one skill, one subagent, one hook. Minimal footprint.

## Install

In any Claude Code session:

```
/plugin marketplace add lzvsk/atlas-pack
/plugin install atlas@atlas-pack
/reload-plugins
```

Verify with `/plugin` — you should see `atlas` as `enabled`.

Naming:
- `atlas-pack` — the marketplace (this repo).
- `atlas` — the plugin inside, used in slash commands (`/atlas:init`, `/atlas:sync`).

### Alternative — include via another marketplace

If you maintain a collection marketplace, add this entry to its `marketplace.json`:

```json
{
  "name": "atlas",
  "source": {
    "source": "github",
    "repo": "lzvsk/atlas-pack",
    "ref": "main"
  }
}
```

## Usage

```
/atlas:init              interactive bootstrap: AGENTS.md + docs/ + full mirror of the code tree
/atlas:sync              drift audit + fix (one confirmation for the whole edit list)
/atlas:sync --check      report only, no edits
```

After install, it works mechanically:
- The `atlas` skill auto-activates in any repo with `AGENTS.md` + `docs/` at the root.
- A `PostToolUse` hook on Edit/Write/MultiEdit resolves the edited path via `mirrors:`-frontmatter and tells the agent which doc to update.
- The `atlas-auditor` subagent runs heavy drift scans in a fresh context.

## Principle

Optimize the repository for agent reading, not human reading. If the agent can't see it, it doesn't exist. Docs are the versioned source of truth; code is the implementation. Disagreement = a bug in docs.

Methodology adapted from [OpenAI harness engineering](https://openai.com/index/introducing-codex/) (Ryan Lopopolo, 2026-02-11).

## Documentation

- Agent entry point — `AGENTS.md` (navigation into `docs/` lives there)
- Plugin architecture (stack, components, flows, boundaries) — `docs/ARCHITECTURE.md`
- Top-level docs index — `docs/ABOUT.md`
- Code mirrors — `docs/{commands,skills,agents,hooks}/` (each with `ABOUT.md` + per-file descriptions)

## License

WTFPL — see `license.txt`.
