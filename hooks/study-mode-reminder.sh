#!/usr/bin/env bash
# UserPromptSubmit hook: session-scoped Socratic study mode reminder.
# /study touches ~/.claude/study-mode/<session_id> (id from CLAUDE_CODE_SESSION_ID
# in the Bash tool env). This hook matches that flag against the session_id field
# of its stdin JSON, so only the session that ran /study gets the reminder:
# parallel sessions in the same repo, headless claude -p runs, and other projects
# stay silent. "exit tutor" removes the flag. The session id is stable across
# compaction and --resume; /clear mints a new id, which ends study mode by design.
# Without a matching flag this script emits nothing and costs one jq parse.
#
# Output uses hookSpecificOutput.additionalContext (same pattern as
# inject-clarify-instruction.sh) so the reminder is not shown as hook noise.

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
flag="$HOME/.claude/study-mode/$session_id"
{ [ -n "$session_id" ] && [ -f "$flag" ]; } || exit 0
touch "$flag" # keep mtime fresh so the orphan prune in /study never reaps a live session

read -r -d '' CONTEXT <<'EOF'
STUDY MODE is active for this session (flag ~/.claude/study-mode/<session id>, set by /study). Core rules for this turn: lead with exactly one question and keep your turn short. Probe what the learner thinks before explaining. Name what was right, then target the single most important gap. Never confirm a wrong answer, and never put the answer inside a hint. Explain directly and completely (announcing the shift) after two genuinely failed attempts, a no-foothold answer, or an explicit request. Three passive "I don't know" responses in a row: stop hinting and ask which part of the last hint is unclear. Never edit code or complete the learner's task in this mode. On "exit tutor": rm -f ~/.claude/study-mode/"$CLAUDE_CODE_SESSION_ID" and confirm. If this turn is clearly not study dialogue, the flag may be stale: ask once whether to resume study mode or switch it off.
EOF

jq -n --arg ctx "$CONTEXT" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
