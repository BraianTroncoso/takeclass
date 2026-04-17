---
name: dev-english-practice
description: Generate an English practice session from the developer's daily work (git diff, commits, task context). Produces a reading script, technical vocabulary, rephrasing drills, and self-check questions tailored to the user's level and style. Triggers on /takeclass, or when the user says "let's do my English class", "practice English based on today's work", "prepare a standup in English", "take an English class about what I did today", or similar requests about narrating their dev work in English.
version: 0.1.0
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

## Inputs

- **Optional args from `/takeclass`**: `$1 = level`, `$2 = style`.
- **Current working directory**: used to gather git activity.
- **Memory**: prior level, style, weak points, session counter.

## Phase 1 — Gather today's work

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

Check the memory system at `~/.claude/projects/<project-slug>/memory/` for these files:

- `english_preferences.md` — level + style.
- `english_weak_points.md` — recurring grammar/vocabulary issues the user has flagged.
- `english_session_log.md` — session counter and last-run date.

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

After producing the output:

- If during the session the user asked "how do I say X?" or you detected a recurring issue (e.g., always confusing "make" vs "do"), append it to `english_weak_points.md` (type: `feedback`). Include the example and a one-line rule.
- Update `english_session_log.md` (type: `project`): increment counter, set last-run date to today's `currentDate` from context.
- Do **not** silently save weak points — mention to the user what you logged so they can correct you.

On subsequent sessions:

- Reference past weak points in the rephrase drill or warm-up (e.g., if "whereas" was flagged, include it in a drill sentence).
- Every 5 sessions, bump difficulty a notch within the chosen level (more complex sentence structures, richer vocab).

## Output format

Wrap the entire class in a single fenced output so the user can scroll it as one block. Begin with a one-line header:

```
📚 English class — session #{N} — {level} / {style} — {date}
```

Then the four sections. End with:

```
💡 When you finish reading aloud, tell me which words tripped you up — I'll log them for next time.
```

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
