---
mirrors:
  - plugins/atlas/hooks/hooks.json
---

# hooks/hooks.json

Hook declaration for Claude Code.

## Contents

Registers a single hook:
- Event: `PostToolUse`
- Matcher: `Edit|Write|MultiEdit` — fires after any of these tools is applied
- Command: `${CLAUDE_PLUGIN_ROOT}/hooks/remind-doc.sh`

## How it's used

Claude Code reads this file when the plugin is installed and automatically registers the hook in user-level settings. On every Edit/Write/MultiEdit it runs the script, passing a JSON with `tool_input` via stdin.
