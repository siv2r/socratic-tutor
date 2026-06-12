# socratic-tutor

A guided Socratic study mode for [Claude Code](https://claude.com/claude-code). Type `/study <topic or spec file>` and the session becomes a question-first tutor: it probes what you already think, asks one question per turn, refuses to hand over answers you could derive, and drops to direct explanation the moment you are genuinely stuck. The terminal equivalent of Gemini Guided Learning, built for studying technical material deeply (cryptography, mathematics, CS, protocol specs such as Bitcoin BIPs), though it generalizes to any subject.

Say `exit tutor` to leave the mode.

## How it works

Two pieces:

1. **`SKILL.md`**, a Claude Code user skill carrying the full tutor prompt. Every directive is tagged `(hard)` or `(soft)`, the pedagogical instruction-following pattern from LearnLM. It covers the opening ritual, the questioning loop, a three-tier hint ladder with an escape hatch, anti-sycophancy guardrails, and domain adaptations for math, crypto, and spec reading. On invocation it creates a flag file (`.logbook/.study-mode`) in the current project.
2. **`hooks/study-mode-reminder.sh`**, a flag-gated UserPromptSubmit hook. While the flag exists it re-injects a compact reminder of the hard rules on every turn, so the mode survives long sessions and context compaction. Without the flag it is silent and free. `exit tutor` removes the flag.

The split solves the fade problem: skill content injects once and washes out of context as a session grows, but the per-turn reminder keeps the tutor honest at turn 50 as well as turn 3.

## Install

Symlink the skill and the hook into your Claude Code config:

```bash
git clone https://github.com/siv2r/socratic-tutor ~/Projects/socratic-tutor
ln -s ~/Projects/socratic-tutor ~/.claude/skills/study
ln -s ~/Projects/socratic-tutor/hooks/study-mode-reminder.sh ~/.claude/hooks/study-mode-reminder.sh
```

Then register the hook in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/<you>/.claude/hooks/study-mode-reminder.sh"
          }
        ]
      }
    ]
  }
}
```

## Usage

```
/study                          # asks what you want to study
/study elliptic curve pairings  # opens a topic
/study path/to/spec.md          # grounds the session in a file
exit tutor                      # leaves the mode, removes the flag
```

The tutor reads the file before asking anything, reconnects to prior sessions on the topic when session memory is available, and scopes each session to one concept.

## Design provenance

The directives are not vibes. They come from two multi-agent research passes over the learning-science and AI-tutoring literature (expert human tutoring corpora, retrieval practice, the ICAP framework, expertise reversal, proof comprehension research, sycophancy measurements, and the shipped study modes from OpenAI, Google, and Anthropic). The second pass ran fully blind against the first and independently re-derived nearly every rule, which is the main reason to trust them.
