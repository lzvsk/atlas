#!/usr/bin/env bash
# atlas — PostToolUse hook on Edit/Write/MultiEdit.
# Fires only in atlas-style repos (AGENTS.md + docs/ at cwd root).
# Resolves the edited code path against `mirrors:` frontmatter in docs/**/*.md
# and tells the agent which doc to update (or that no doc claims the path yet).
# Silent in non-atlas repos so the plugin can be installed globally without noise.
#
# Hook input (stdin): JSON with .tool_input.file_path (Edit/Write) or
# .tool_input.edits[].file_path (MultiEdit).
# Hook output (stdout): one reminder line per (path, matching doc), or a single
# "no doc claims this" line if mirrors didn't resolve anything.
# Exit code: always 0.

set -u

# Gate: atlas-style repo only.
[ -f "./AGENTS.md" ] || exit 0
[ -d "./docs" ] || exit 0

input=$(cat)
[ -z "$input" ] && exit 0

extract_paths() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$1" | jq -r '
      if .tool_input.file_path then .tool_input.file_path
      elif .tool_input.edits then .tool_input.edits[].file_path
      else empty end
    ' 2>/dev/null
  else
    printf '%s' "$1" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
  fi
}

paths=$(extract_paths "$input")
[ -z "$paths" ] && exit 0

# Filter: which edits deserve a reminder.
# Skip only files that never map to project docs (other docs, pure housekeeping, secrets,
# build artefacts, and specific dot-directories). Keep `.claude-plugin/`, `license.txt`,
# `README.md` in scope — they may be claimed by a mirror.
should_skip() {
  local p="$1"
  case "$p" in
    # Docs themselves.
    */docs/*|docs/*) return 0 ;;
    # Agent contract / router files (part of the doc ecosystem).
    */AGENTS.md|AGENTS.md|*/CLAUDE.md|CLAUDE.md) return 0 ;;
    # Human-facing README — conventionally self-documenting, not mirrored.
    */README.md|README.md) return 0 ;;
    # User cheatsheets / changelogs — not mirror targets.
    */INSTRUCTIONS.md|INSTRUCTIONS.md|*/CHANGELOG.md|CHANGELOG.md) return 0 ;;
    # Specific dot-directories to hard-exclude.
    */.git/*|.git/*|*/.idea/*|.idea/*|*/.vscode/*|.vscode/*|*/.claude/*|.claude/*) return 0 ;;
    # Housekeeping and OS debris.
    */.DS_Store|.DS_Store) return 0 ;;
    */.gitignore|.gitignore|*/.gitkeep|.gitkeep) return 0 ;;
    # Secrets.
    */.env|.env|*/.env.*|.env.*) return 0 ;;
    # Build artefacts.
    *.lock|*.pyc|*.map) return 0 ;;
  esac
  return 1
}

# Resolve mirrors: given a code path, print matching doc paths (one per line).
resolve_mirrors() {
  local edited="$1"
  python3 - "$edited" <<'PYEOF' 2>/dev/null
import sys, re, fnmatch, glob
edited = sys.argv[1]
for d in sorted(glob.glob('docs/**/*.md', recursive=True)):
    try:
        with open(d, encoding='utf-8') as f:
            head = f.read(8192)
    except Exception:
        continue
    m = re.match(r'^---\s*\n(.*?)\n---', head, re.DOTALL)
    if not m:
        continue
    fm = m.group(1)
    mm = re.search(r'^mirrors:\s*\n((?:[ \t]*-[ \t]*\S.*\n?)+)', fm, re.MULTILINE)
    if not mm:
        continue
    for line in mm.group(1).splitlines():
        pat = re.sub(r'^[ \t]*-[ \t]*', '', line).strip().strip('"').strip("'")
        if not pat:
            continue
        # fnmatch treats `*` and `**` identically against path strings
        # (both match any chars including `/`); normalize `**` -> `*`.
        norm = pat.replace('**', '*')
        if fnmatch.fnmatch(edited, norm):
            print(d)
            break
PYEOF
}

reminders=""
while IFS= read -r p; do
  [ -z "$p" ] && continue
  if should_skip "$p"; then continue; fi

  # Normalize path to repo-relative.
  p=${p#./}
  if [[ "$p" = "$PWD"/* ]]; then
    p="${p#"$PWD"/}"
  fi

  if command -v python3 >/dev/null 2>&1; then
    mirrors=$(resolve_mirrors "$p")
    if [ -n "$mirrors" ]; then
      while IFS= read -r doc; do
        reminders="${reminders}[atlas] edited ${p} — update matching doc: ${doc} (claims via \`mirrors:\` frontmatter)\n"
      done <<< "$mirrors"
    else
      reminders="${reminders}[atlas] edited ${p} — no doc claims this path via \`mirrors:\`. Create \`docs/<same-path>/<basename>.md\` with \`mirrors: [<this-path>]\`, or extend an existing ABOUT.md.\n"
    fi
  else
    reminders="${reminders}[atlas] edited ${p} — update the matching doc per your repo's \"Код ↔ docs\" (run /atlas:sync --check). [python3 unavailable — mirror resolution skipped]\n"
  fi
done <<EOF
$paths
EOF

[ -z "$reminders" ] && exit 0
printf '%b' "$reminders"
exit 0
