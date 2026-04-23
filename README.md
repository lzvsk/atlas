# atlas

> Harness engineering. Harness your repo before it harnesses you.

Claude Code plugin that keeps `docs/` as a 1-to-1 mirror of your codebase. Two slash commands, one skill, one subagent, one hook. Minimal footprint.

## Install

### Prerequisite — one-time git setup

Claude Code's `/plugin install` has a [known bug](https://github.com/anthropics/claude-code/issues/29722) that tries to clone plugins via SSH without falling back to HTTPS. If you don't have SSH keys set up for GitHub (most users don't by default), installation fails with `Permission denied (publickey)`.

Fix by telling git to rewrite GitHub SSH URLs to HTTPS — a harmless global git setting:

```bash
git config --global --add url."https://github.com/".insteadOf "git@github.com:"
git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/"
```

Run this once per machine. It does nothing for people who already have GitHub SSH keys configured; for people who don't, it makes every git-over-SSH call use HTTPS instead. No credentials needed — HTTPS works with the default GitHub credential helper.

### Install atlas

In any Claude Code session:

```
/plugin marketplace add lzvsk/atlas
/plugin install atlas@atlas
/reload-plugins
```

Verify with `/plugin` — you should see `atlas` as `enabled`.

### Alternative — include via another marketplace

If you maintain a collection marketplace, add this entry to its `marketplace.json`:

```json
{
  "name": "atlas",
  "source": {
    "source": "github",
    "repo": "lzvsk/atlas",
    "ref": "main"
  }
}
```

The same git-rewrite prerequisite applies.

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
