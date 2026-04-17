---
description: Start an English practice session based on today's dev work
argument-hint: "[level] [style]"
---

Invoke the `dev-english-practice` skill via the Skill tool.

Rules for parsing arguments (user's raw args are in `$ARGUMENTS`):

- If `$1` is one of `beginner` / `intermediate` / `advanced`, pass it to the skill as the level.
- If `$2` is one of `standup` / `pr-description` / `tech-talk` / `casual-explain`, pass it as the style.
- If an arg is present but invalid, tell the user what the valid options are and stop — do not guess.
- If no args are passed, let the skill load preferences from memory, or ask interactively if memory is empty.

Gather git context from the current working directory. Do not change directories. If the CWD is not a git repo or there is no activity today, follow the skill's fallback (ask the user to summarize their work).

After the skill runs, do not add extra commentary — the class output from the skill is the final user-facing message.
