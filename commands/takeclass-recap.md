---
description: Weekly recap of your English practice — sessions, vocabulary, weak points, next focus
argument-hint: ""
---

Invoke the `dev-english-practice` skill in **recap mode**. No arguments accepted — if the user passes any, mention that recap takes no args and continue anyway.

Recap mode is a pure report: it reads the last 7 days from memory (`english_session_log.md`, `english_weak_points.md`, `english_warm_up_history.md`) and returns a single Markdown block with:

- Streak counter at the top.
- Sessions grid for the rolling 7-day window (Mon–Sun ✅/⬜).
- Vocabulary learned this week (10–15 deduplicated terms).
- Top 3 weak points by recurrence.
- One drill sentence drawn from the top weak point, in 3 register variants (formal / casual / hedged).
- Next week's focus — one concrete, specific goal.

A snapshot is saved as `english_recap_{YYYY}-W{WW}.md` under the project's memory dir for long-term progress tracking. Recap is read-only against session and weak-point memory — it does **not** log a new session or append weak points.

If there is no session history yet, the skill returns a single-line nudge asking the user to take their first `/takeclass`. Do not fabricate a recap from nothing.

## Output

The recap block from the skill is the final user-facing message. Do not add extra commentary.
