# Roadmap

## v0.1 — text-only class (current)

- `/takeclass` slash command
- `dev-english-practice` skill
- 4-section output: vocabulary, script, rephrase, self-check
- Memory: level, style, weak points, session counter
- Install via symlinks

## v0.2 — voice loop

Goal: the user reads the script aloud, Claude hears it, flags pronunciation and fluency issues.

Likely components:

- Companion skill `dev-english-voice` in the same repo.
- Push-to-talk capture is the user's responsibility (OS dictation, nerd-dictation, SuperWhisper, etc.). The skill accepts the transcript as input.
- Scoring axes (prototype): pronunciation flags (words the user likely mispronounced), filler words, pace (words/min), grammar fixes, vocabulary reuse of warm-up terms.
- Optional TTS of a "reference reading" if a TTS MCP is available — so the user can compare.

Open questions:

- Score once at the end vs. per-sentence feedback? Start with end-of-session summary, iterate.
- How aggressive to be with pronunciation correction? Start minimal (flag only the 2–3 worst words per session), grow with feedback.

## v0.3 — MCP server

Goal: decouple the logic from Claude Code so any MCP client can host the class.

Structure:

```
mcp/
  src/
    tools/
      gather_git_context.ts      # returns normalized diff + metadata
      generate_script.ts         # takes context + prefs, returns class output
      record_weak_point.ts       # updates persistence
      list_past_sessions.ts
  package.json
  README.md
```

- Transport: stdio first, HTTP/SSE later.
- Persistence: move from Claude's memory files to a plain SQLite DB (`~/.takeclass/state.db`) so non-Claude clients can use it.
- The Claude Code skill becomes a thin wrapper that calls the MCP tools.

## v0.4 — progression engine

- Per-user difficulty curve: automatically bump level if the user reports zero trip-ups for N sessions in a row.
- Spaced-repetition style reuse: weak words resurface on day 1, 3, 7, 14.
- Weekly recap: a single "this week in your English" summary.

## v0.5+ — ideas

- `interview-practice` style (behavioral + system-design prompts built from the codebase).
- `pair-reading`: Claude reads alternating sentences with the user.
- Localization of the teaching scaffolding (Spanish, Portuguese, French) while keeping the target language always English.
- Teams mode: aggregate weak-point trends across a whole engineering team (opt-in, anonymized).
- Integration with Linear / Jira: pull the ticket title and description into the class context, not just git.

## Non-goals

- Full-stack language tutor. If you want to learn English grammar from scratch, use a dedicated course. This tool is for devs who can already code in English-speaking teams and need fluency, not foundations.
- Replacing human review of your English. The drills are practice, not certification.
