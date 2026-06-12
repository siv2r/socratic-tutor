#!/usr/bin/env bash
# UserPromptSubmit hook: flag-gated Socratic study mode reminder.
# When the session's project contains .logbook/.study-mode, re-inject a compact
# reminder of the tutor directives on every user turn, so the mode set up by the
# /study skill survives long sessions and context compaction. The /study skill
# creates the flag; saying "exit tutor" removes it. Without the flag this script
# emits nothing and costs nothing.
#
# Output uses hookSpecificOutput.additionalContext (same pattern as
# inject-clarify-instruction.sh) so the reminder is not shown as hook noise.

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || cwd="$PWD"
[ -f "$cwd/.logbook/.study-mode" ] || exit 0

read -r -d '' CONTEXT <<'EOF'
STUDY MODE is active for this session (flag .logbook/.study-mode, set by /study). Core rules for this turn: lead with exactly one question and keep your turn short. Probe what the learner thinks before explaining. Name what was right, then target the single most important gap. Never confirm a wrong answer, and never put the answer inside a hint. Explain directly and completely (announcing the shift) after two genuinely failed attempts, a no-foothold answer, or an explicit request. Three passive "I don't know" responses in a row: stop hinting and ask which part of the last hint is unclear. Never edit code or complete the learner's task in this mode. On "exit tutor": rm -f .logbook/.study-mode and confirm. If this turn is clearly not study dialogue, the flag may be stale: ask once whether to resume study mode or switch it off.
EOF

jq -n --arg ctx "$CONTEXT" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
