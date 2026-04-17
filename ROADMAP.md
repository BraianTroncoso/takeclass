# Roadmap

## v0.1 — text-only class (current)

- `/takeclass` slash command
- `dev-english-practice` skill
- 4-section output: vocabulary, script, rephrase, self-check
- Memory: level, style, weak points, session counter
- Install via symlinks

---

## v0.2 — Mirror mode

**Goal.** Invert the flow: instead of Claude generating a script for the user to read, the user narrates first in their own English, and Claude returns a polished version with a clear diff of what changed and *why*.

**Rationale.** Active learning beats passive reading. Once the user has baseline comfort with v0.1's flow, mirror mode is how they find their own blind spots — the words they don't know they're missing, the tenses they quietly avoid.

### Trigger

- `/takeclass mirror`
- Natural language: *"correct my English about what I did today"*, *"I'll explain my work and you clean it up"*.

### Flow

1. **Gather context.** Same Phase 1 as v0.1 (git diff, commits, fallback if no git).
2. **Prompt the user.** *"In your own words, narrate what you did today — don't worry about being correct. Paste when ready."*
3. **User pastes** 100–400 words of English. Dictation is fine; typing is fine; this is a text input, not a voice feature.
4. **Claude returns** a single Markdown block:
   - **Polished version** — same meaning, same register, upgraded English. Keep the user's voice; don't over-formalize.
   - **What changed** — 3–6 bullets, each with `original → fix — one-line reason`. Example: `"I was do the refactor" → "I was doing the refactor" — past continuous needs -ing on the main verb.`
   - **Pattern callout** — the single most important recurring issue in the paste, promoted to `english_weak_points.md`.
   - **Try again?** — a prompt inviting a second attempt with the fixes in mind, same prompt, same session.

### Memory

- Append pattern callouts to `english_weak_points.md` (feedback type).
- Track a per-session "mirror attempts" counter inside `english_session_log.md`, so we can eventually show "attempt 3 this week" and build in-session pressure, not just cross-day pressure.

### Scope notes

- No grammar engine. Correction is done by Claude reading the paste against the diff context. Keep it conversational.
- Strip secrets from the paste before any memory write (same rules as v0.1).
- Cap paste length at ~800 words. Over that, ask the user to narrow to one part of the day.
- Share the 4-section Markdown aesthetic of v0.1 so the product feels cohesive.

### Files to add

- Extension inside `skills/dev-english-practice/SKILL.md`: a new `## Mode: mirror` section that diverges from Phase 3 when invoked with the `mirror` arg.
- Extension inside `commands/takeclass.md`: recognize `mirror` as a third arg that forces the mirror flow regardless of `[level]`/`[style]`.

### Open questions

- Should the polished version be shown before or after the diff bullets? Leaning *diff first, polished version last* so the user processes corrections before seeing the clean form.
- Do we enforce the user's current level, or let the polished version drift upward so it's aspirational? Likely the latter, with a 1-line note: *"Here's a slightly harder version than your current level."*

---

## v0.3 — Streak + weekly recap

**Goal.** Install a habit loop that survives month one. Devs who practice 5 minutes daily beat devs who practice 1 hour weekly — but only if they keep showing up.

### Streak

- Every successful `/takeclass` or `/takeclass mirror` session writes today's date to `english_session_log.md`.
- Streak = consecutive calendar days with at least one session, computed from the dates list.
- At the top of every class output, show: `🔥 Streak: 7 days — don't break it.` (hidden on day 0).
- **No freeze tokens, no grace days in v1.** Miss a day, streak resets. Honest feedback > gamified cushion. We can add freezes later if drop-off data justifies it.
- Timezone: use the `currentDate` provided in the session context; no timezone math required.

### `/takeclass-recap` command

A separate slash command so reflection is always user-initiated, never auto-fired.

**When invoked**, Claude:

1. Reads the last 7 days from `english_session_log.md` and `english_weak_points.md`.
2. Produces a single Markdown block with these sections:
   - **Sessions this week** — "5 of 7 days 🔥". List the days with a ✅/⬜ grid.
   - **Vocabulary learned** — deduplicated 10–15 terms from the week's warm-ups.
   - **Top 3 weak points** — the most-mentioned recurring issues, each with a 1-line rule and a fresh example.
   - **Sentence you probably still can't say cleanly** — pick one example from weak points, drill it in 3 register variants (formal / casual / hedged).
   - **Next week's focus** — one concrete goal, extracted from the weak points. Example: *"Get 'thorough' and 'through' to feel distinct in your mouth."*
3. Saves a snapshot `english_recap_YYYY-WW.md` under `memory/` so old recaps stay retrievable and the user can see progress over time.
4. Does not call `AskUserQuestion`. Takes no args. Pure report.

### Files to add

- `commands/takeclass-recap.md` — new slash command definition.
- `skills/dev-english-practice/SKILL.md` — add a "Phase 5 — Streak update" subsection (tiny addition; does not change the existing phases).
- Optionally a tiny `skills/dev-english-recap/SKILL.md` if the recap logic grows enough to deserve its own skill. For v0.3 it can live inside `dev-english-practice` as a mode.

### Rationale for it being a separate command

- The user should decide *when* to reflect. Auto-triggering recap on Sundays risks spam — especially if they skipped days and don't want the receipt.
- Recap is psychologically different from practice: it's a zoom-out, not a drill. Different command = different mental frame.

### Open questions

- Week boundary: Monday–Sunday (ISO) or rolling 7-day window? Rolling is friendlier; ISO is cleaner for snapshots. Default to rolling; re-evaluate once we have real recaps.
- Should missed-day streaks be mourned or downplayed? Draft stance: one-line mention, no shame, no emojis that look sad. Focus is forward.

---

## v0.4 — voice loop

**Goal.** The user reads the script aloud, Claude hears it, flags pronunciation and fluency issues.

### Components

- Companion skill `dev-english-voice` in the same repo.
- Push-to-talk capture is the user's responsibility (OS dictation, nerd-dictation, SuperWhisper, etc.). The skill accepts the transcript as input — no audio codec work on our side in v0.4.
- Scoring axes (prototype): pronunciation flags (words the user likely mispronounced), filler words, pace (words/min), grammar fixes, vocabulary reuse of warm-up terms.
- Optional TTS of a "reference reading" if a TTS MCP is available — so the user can compare.

### Open questions

- Score once at the end vs. per-sentence feedback? Start with end-of-session summary, iterate.
- How aggressive to be with pronunciation correction? Start minimal (flag only the 2–3 worst words per session), grow with feedback.

---

## v0.5 — MCP server

**Goal.** Decouple the logic from Claude Code so any MCP client can host the class.

```
mcp/
  src/
    tools/
      gather_git_context.ts      # returns normalized diff + metadata
      generate_script.ts         # takes context + prefs, returns class output
      generate_mirror.ts         # mirror-mode correction
      generate_recap.ts          # weekly recap
      record_weak_point.ts       # updates persistence
      list_past_sessions.ts
  package.json
  README.md
```

- Transport: stdio first, HTTP/SSE later.
- Persistence: move from Claude's memory files to a plain SQLite DB (`~/.takeclass/state.db`) so non-Claude clients can use it.
- The Claude Code skill becomes a thin wrapper that calls the MCP tools.

---

## v0.6 — progression engine

- Per-user difficulty curve: automatically bump level if the user reports zero trip-ups for N sessions in a row.
- Spaced-repetition style reuse: weak words resurface on day 1, 3, 7, 14.
- Cross-session vocabulary deck auto-built from warm-ups.

---

## v0.7+ — ideas

- `interview-practice` style (behavioral + system-design prompts built from the codebase).
- `pair-reading`: Claude reads alternating sentences with the user.
- Localization of the teaching scaffolding (Spanish, Portuguese, French) while keeping the target language always English.
- Teams mode: aggregate weak-point trends across a whole engineering team (opt-in, anonymized).
- Integration with Linear / Jira: pull ticket title and description into the class context, not just git.
- Persona mode: emulate a specific voice (staff engineer at FAANG, indie-hacker podcast, dev-teacher on YouTube).

---

## Non-goals

- Full-stack language tutor. If you want to learn English grammar from scratch, use a dedicated course. This tool is for devs who can already code in English-speaking teams and need fluency, not foundations.
- Replacing human review of your English. The drills are practice, not certification.
- Gamification that hides missed days (freeze tokens, streak shields). Honesty over retention-hacks.
