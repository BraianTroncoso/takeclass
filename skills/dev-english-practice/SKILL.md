---
name: dev-english-practice
description: English practice for developers built around their daily git diff. Three modes — default (read-aloud class with vocabulary, script, rephrase drills, self-check), mirror (user narrates first, Claude polishes with a diff), and recap (rolling 7-day summary). Triggers on /takeclass, /takeclass mirror, /takeclass-recap, or natural-language requests like "practice English on today's work", "correct my English", "how did I do this week".
version: 0.3.0
license: MIT
---

# dev-english-practice

Turn the developer's real daily work into a spoken-English practice session. The dev reads the generated script aloud and answers open questions to reinforce fluency with vocabulary they actually use.

## When to use this skill

Invoke this skill when:

- The user types `/takeclass` (primary trigger).
- The user asks to "practice English", "do my English class", "train English on today's work", "prepare a standup in English", etc.
- The user wants to explain in English what they built/fixed/refactored.

Do **not** use this skill for:

- General English tutoring unrelated to dev work (suggest a dedicated tutor or other tool).
- Translating code comments or documentation (that is a separate task, not practice).
- Writing English PR descriptions to ship (use a writing/review flow, not practice).

## Modes

The skill runs in one of three modes. Decide the mode **before** any other step:

- **default** — the v0.1 class flow (Phases 1–4 below). Picked when `/takeclass` is invoked without the word `mirror`, or when the natural-language ask is about practicing / explaining today's work.
- **mirror** — the user explains first in their own English, Claude returns a polished version with a diff of what changed and why. Picked when `/takeclass mirror` is invoked, or when the user says "correct my English", "I'll narrate, you polish", "rewrite my explanation", etc. See [Mirror mode flow](#mirror-mode-flow).
- **recap** — rolling 7-day report of sessions, vocabulary, and weak points. Picked when `/takeclass-recap` is invoked, or when the user asks for "this week's recap", "how did I do this week", "summarize my English practice". See [Recap mode flow](#recap-mode-flow).

When args conflict (e.g. `/takeclass mirror advanced`), mirror mode wins for flow; level/style still shape the polished output.

## Inputs

- **Optional args from `/takeclass`**: any of `$1`, `$2`, `$3` may be `beginner|intermediate|advanced` (level), `standup|pr-description|tech-talk|casual-explain` (style), or `mirror` (mode flag). Order is flexible.
- **`/takeclass-recap`**: takes no args.
- **Current working directory**: used to gather git activity in default and mirror modes. Ignored in recap mode.
- **Memory**: prior level, style, weak points, session log, past warm-up vocabulary, past recaps.

## Phase 1 — Gather today's work

*Applies to **default** and **mirror** modes. Skip in **recap** mode.*


Run these commands from the current working directory (do not cd elsewhere):

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
git diff --stat
git diff
git diff --cached
git log --since=midnight --pretty=format:"%h %s" --no-merges
```

Rules:

- If the first command fails → CWD is not a git repo. Skip to the fallback below.
- If the diffs are empty **and** there are no commits today → fallback.
- If diffs are huge (>500 lines), summarize by file (read file names + a short read of each changed file, not the full diff). Prioritize logic changes over formatting-only changes.
- Strip secrets, tokens, `.env` content, or anything that looks sensitive before using diff text in the output.

**Fallback (no git activity):**
Ask the user: *"I can't see git activity for today in this directory. Tell me in 1–2 sentences what you worked on and I'll build the class around that."*

## Phase 2 — Load preferences from memory

*Applies to **default** and **mirror** modes. Recap mode reads memory separately (see its flow).*

Check the memory system at `~/.claude/projects/<project-slug>/memory/` for these files:

- `english_preferences.md` — level + style.
- `english_weak_points.md` — recurring grammar/vocabulary issues the user has flagged.
- `english_session_log.md` — session dates (list), total counter, last-run date, mirror-attempts counter.
- `english_warm_up_history.md` *(optional)* — deduplicated list of warm-up terms from past sessions, used by recap.

If `english_preferences.md` is missing **and** the user did not pass args:

Use `AskUserQuestion` with two questions:

1. **Level** — beginner / intermediate / advanced.
2. **Style** — standup / pr-description / tech-talk / casual-explain.

Save both to `english_preferences.md` (type: `user`) and add a pointer to `MEMORY.md`. Format:

```markdown
---
name: english_preferences
description: User's English practice level and preferred narration style for dev-english-practice skill
type: user
---

- Level: intermediate
- Style: standup
- Last updated: 2026-04-17
```

If args were passed (`/takeclass advanced tech-talk`), use them and skip the questions. Still save/update memory with the new values.

## Phase 3 — Generate the practice output

*Applies to **default** mode only. If mode is `mirror`, jump to [Mirror mode flow](#mirror-mode-flow). If mode is `recap`, jump to [Recap mode flow](#recap-mode-flow).*

Produce a single Markdown block with exactly these four sections, in order:

### 1. Warm-up vocabulary

5–8 technical terms pulled from today's diff (function names, domain terms, library names, concepts touched). For each:

```
**term** /fəˈnɛ.tɪk/ — short definition.
Example: one natural sentence using it.
```

Use simple IPA-ish phonetic hints (no need for full IPA rigor). Pick words that are actually tricky for Spanish speakers (e.g., "thought", "through", "schedule", "queue") when relevant.

### 2. Script to read aloud

Narrative of **150–300 words** in the user's chosen style, calibrated to their level:

- **beginner**: short sentences, present tense heavy, common verbs, minimal subordination.
- **intermediate**: mix tenses, add connectors (however, although, meanwhile), 1–2 conditionals.
- **advanced**: nuanced vocabulary, hedging ("arguably", "it seems that"), tech-talk register.

Style registers:

- **standup**: "Yesterday I… Today I'm going to… Blockers:…" — short, first person, action-oriented.
- **pr-description**: structured paragraphs — Context / Changes / Trade-offs / Next steps.
- **tech-talk**: explanatory, second-person-friendly, anecdotal hooks, assumes audience.
- **casual-explain**: imagine explaining to a teammate over coffee. Contractions allowed.

Put warm-up vocabulary in **bold** the first time it appears so the user notices.

### 3. Rephrase drill

Pick 3 sentences from the script. For each, rewrite it 2 ways:

```
Original: "I refactored the auth middleware to support refresh tokens."
  → Formal: "The authentication middleware was refactored to accommodate refresh tokens."
  → Casual: "I cleaned up the auth middleware so it can handle refresh tokens now."
```

Pairs to rotate across sessions: formal ↔ casual, simple ↔ advanced, active ↔ passive, present ↔ past perfect.

### 4. Self-check questions

3 open questions for the user to answer **aloud** (no grading in v1, just prompts for self-reflection). Mix categories:

- **Decision**: "Why did you choose this approach over alternatives?"
- **Trade-off**: "What did you give up by taking this path?"
- **Defense**: "If a reviewer pushed back on this change, how would you respond?"

Tailor at least one question to something specific from today's diff.

## Phase 4 — Update memory

*Applies to **default** and **mirror** modes. Recap mode is read-only of memory (only writes its own snapshot).*

After producing the output:

- If during the session the user asked "how do I say X?" or you detected a recurring issue (e.g., always confusing "make" vs "do"), append it to `english_weak_points.md` (type: `feedback`). Include the example and a one-line rule.
- **Append today's date** to the `sessions:` list in `english_session_log.md` (type: `project`). If today is already listed, do **not** duplicate it.
- Increment `sessions_total` (create at 1 if file doesn't exist). Set `last_run` to today's `currentDate`.
- In mirror mode, also increment `mirror_attempts_week` (reset to 0 when the ISO week changes).
- Append the session's warm-up terms (default mode only) to `english_warm_up_history.md` as a dated block, so recap can aggregate them.
- Do **not** silently save weak points — mention to the user what you logged so they can correct you.

On subsequent sessions:

- Reference past weak points in the rephrase drill or warm-up (e.g., if "whereas" was flagged, include it in a drill sentence).
- Every 5 sessions, bump difficulty a notch within the chosen level (more complex sentence structures, richer vocab).

### Streak computation and display

Before emitting the final output (in default or mirror mode), compute the streak:

1. Read the `sessions:` list from `english_session_log.md` (or treat as empty if the file doesn't exist yet).
2. Append today's date to the list **in memory** (the persisted write happens in Phase 4 above; here we just reason about the final state).
3. Sort unique dates descending. Count consecutive calendar days ending at today's `currentDate`. That count is the **streak**.
4. No freeze tokens, no grace days. A missed calendar day resets streak to 1 (today's session).

Display rules:

- If streak ≥ 2 → prepend the output with: `🔥 Streak: {N} days — don't break it.`
- If streak == 1 **and** `sessions_total` > 1 → prepend: `🌱 Back after a break. Today counts as day 1.`
- If `sessions_total` == 1 (first ever session) → prepend: `🌱 First class. Welcome.`

## Output format (default mode)

Wrap the entire class in a single fenced output so the user can scroll it as one block. Order:

```
{streak banner}

📚 English class — session #{N} — {level} / {style} — {date}
```

Then the four sections. End with:

```
💡 When you finish reading aloud, tell me which words tripped you up — I'll log them for next time.
```

## Mirror mode flow

When mode is `mirror`, replace Phases 3 and "Output format" with this flow. Phases 1 (gather git), 2 (load preferences) and 4 (update memory, including streak) still run.

### Steps

1. **Reuse context** from Phase 1 (git diff, commits, or fallback summary).
2. **Prompt the user**:
   > *"In your own words, narrate what you did today — don't worry about being correct. Paste 100–400 words of English when ready."*
3. **Receive the paste.** If the paste is < ~30 words, ask them to expand ("give me a bit more to work with — aim for a full paragraph"). If > ~800 words, ask them to narrow to one topic.
4. **Strip secrets** from the paste (tokens, `.env` values, anything matching common secret patterns) before any processing or memory write.
5. **Produce output** — a single Markdown block with:

```
{streak banner}

🪞 Mirror — session #{N} — {level} ceiling — {date}

### What changed
- "original fragment" → "fix" — one-line reason.
- ... (3–6 bullets, ordered by impact — highest-value corrections first)

### Polished version
{the user's paragraph, rewritten in better English, same register, same voice, respecting their current level as a ceiling — a light stretch upward is fine, a dramatic jump is not}

### 📌 Pattern to watch
{the single most important recurring issue across the paste}
Examples from your paste:
- "quoted fragment"
- "quoted fragment"

🔁 Want to narrate again with these fixes in mind? Paste the new version and I'll check it.
```

### Mirror-specific rules

- **Order matters**: `What changed` goes before `Polished version`. The user should process corrections before seeing the clean form.
- **Preserve voice.** If the user writes casual, the polished version stays casual. Do not over-formalize.
- **Level as ceiling.** If the user's level is `beginner`, don't rewrite into `advanced` prose — keep it accessible.
- **One pattern only.** Even if there are many issues, elevate only the most impactful one to `Pattern to watch`. The others live in the bullets.
- **Do not** emit the default mode's warm-up, script, rephrase, or self-check sections — mirror is its own shape.
- **Memory**: append the pattern callout to `english_weak_points.md` (feedback type). Increment `mirror_attempts_week` in the session log.

## Recap mode flow

When mode is `recap` (triggered by `/takeclass-recap` or equivalent natural language), run this flow. Takes no args. Skip Phases 1, 2, 3, 4 above — recap has its own read/write cycle below.

### Steps

1. **Read memory:**
   - `english_session_log.md` → list of session dates; derive which of the last 7 calendar days had a session.
   - `english_weak_points.md` → all recorded weak points.
   - `english_warm_up_history.md` → warm-up terms from the last 7 days.
2. **Compute:**
   - Day grid: today going back 6 days. Mark each `✅` if a session occurred that day, `⬜` otherwise.
   - Streak (consecutive calendar days ending today with a session).
   - Top 3 weak points by recurrence count across recorded entries.
   - Deduplicated vocabulary list from the week (cap at 15 entries).
3. **Produce output** — single Markdown block:

```
📅 Weekly recap — rolling 7 days — {start_date} → {today}
🔥 Streak: {N} days

### Sessions this week
{N} of 7 days
{Mon ✅  Tue ⬜  Wed ✅  Thu ✅  Fri ⬜  Sat ⬜  Sun ✅}

### Vocabulary learned
- term1 — short gloss
- term2 — short gloss
... (10–15 entries; if history is thin, say "not enough history yet — keep showing up")

### Top 3 weak points
1. {rule} — example from your own paste/session.
2. {rule} — example.
3. {rule} — example.

### Sentence you probably still can't say cleanly
Pick one example from weak point #1 and drill it in 3 registers:
- Formal: "..."
- Casual: "..."
- Hedged: "..."

### Next week's focus
{one concrete, specific goal drawn from weak point #1. Example: "Get 'thorough' and 'through' to feel distinct in your mouth — read each out loud 10 times before next class."}
```

4. **Snapshot to memory:** write the full recap to `english_recap_{YYYY}-W{WW}.md` (ISO week) under the project's `memory/` dir. Add a pointer in `MEMORY.md`. These snapshots are immutable — future runs only read/append, never overwrite.
5. **Do not** mutate `english_session_log.md` or `english_weak_points.md` in recap mode. Recap is a read-only view of state (except for its own snapshot file).

### Recap-specific rules

- **No AskUserQuestion.** Recap is a pure report.
- **Empty memory** (no sessions yet): print a single-line message — *"No recap yet. Take your first class with `/takeclass`."* Don't fabricate.
- **Week boundary**: rolling 7-day window ending today. Not ISO Mon–Sun. The snapshot filename uses ISO week only for uniqueness/filing, not as the window definition.

## Examples

### Example A — intermediate / standup

```
📚 English class — session #3 — intermediate / standup — 2026-04-17

### 1. Warm-up vocabulary
- **middleware** /ˈmɪd.əl.wer/ — software that sits between layers.
  Example: I updated the auth **middleware** this morning.
- **refactor** /ˌriːˈfæk.tər/ — to restructure code without changing behavior.
  Example: I had to **refactor** the token handler.
- **edge case** /ˈɛdʒ keɪs/ — an unusual input or condition.
  Example: We missed an **edge case** when the token is empty.

### 2. Script to read aloud
Yesterday I worked on the **refactor** of the auth **middleware**. The goal was to support refresh tokens without breaking existing flows. I moved the token-refresh logic into its own helper so the **middleware** stays thin. Along the way I caught an **edge case**: when the incoming token is valid but expired by less than a second, the old code rejected it. I added a small buffer window and a test that covers it. Today I'm going to wire the new helper into the session endpoint and open the PR. Blockers: none so far, though I want a second pair of eyes on the buffer value before we ship.

### 3. Rephrase drill
- "I moved the token-refresh logic into its own helper."
  → Formal: "The token-refresh logic was extracted into a dedicated helper."
  → Casual: "I pulled the refresh logic out into a helper."
...

### 4. Self-check questions
1. Why did you decide to add a buffer window instead of rejecting the token outright?
2. What trade-off comes with making the buffer configurable later?
3. If a reviewer said "this buffer hides bugs", how would you defend it?

💡 When you finish reading aloud, tell me which words tripped you up — I'll log them for next time.
```

### Example B — advanced / tech-talk

Same structure, but the script sounds more like a conference talk: second-person hooks ("Imagine you're debugging…"), hedged claims ("arguably the cleanest way…"), nuanced vocabulary ("conflate", "orthogonal", "non-trivial").

### Example C — beginner / casual-explain

Shorter sentences, present tense dominant, warm-up favors words like "thought/through/tough", phrasal verbs kept minimal, drill focuses on simple ↔ slightly-formal pairs.

## Failure modes to avoid

- Do not fabricate details about the diff. If you're unsure what a change does, say so in the script ("I made some changes to X — I'm still mapping out exactly what") rather than inventing a narrative.
- Do not produce output longer than ~400 lines total; long walls of text defeat the "read aloud" purpose.
- Do not correct the user's code in this skill; the goal is English practice, not review.
- Do not leak secrets from the diff into the script.
