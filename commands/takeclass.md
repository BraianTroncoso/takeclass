---
description: Start an English practice session based on today's dev work
argument-hint: "[level] [style] | mirror"
---

Invoke the `dev-english-practice` skill via the Skill tool.

## Mode selection

Inspect `$ARGUMENTS`. If any token equals `mirror` (case-insensitive), run the skill in **mirror mode**. Otherwise run in **default mode**.

Mirror mode inverts the flow: the user narrates what they did today in their own English, and the skill returns a polished version with a diff of what changed and why. Level and style still apply to the polished output; defaults load from memory if not passed.

## Argument parsing

Any of `$1`, `$2`, `$3` may be one of:

- `beginner` / `intermediate` / `advanced` → level.
- `standup` / `pr-description` / `tech-talk` / `casual-explain` → style.
- `mirror` → activate mirror mode.

Order is flexible. Examples:

- `/takeclass` → default mode, load prefs from memory, ask if missing.
- `/takeclass advanced tech-talk` → default mode with those overrides.
- `/takeclass mirror` → mirror mode, prefs from memory.
- `/takeclass mirror intermediate pr-description` → mirror mode with those ceilings.

If an arg is present but doesn't match any of the categories above, stop and tell the user what the valid options are — do **not** guess.

## Context

Gather git context from the current working directory (do not `cd`). If the CWD is not a git repo or there is no activity today, follow the skill's fallback (ask the user to summarize their work in 1–2 sentences).

## Output

After the skill runs, do not add extra commentary — the class or mirror output from the skill is the final user-facing message.
