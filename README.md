# takeclass

> Turn your day's git diff into an English practice session.
> For devs who can ship the feature but choke when they have to explain it in English.

`takeclass` is a [Claude Code](https://claude.com/claude-code) skill + slash command. Run `/takeclass` in a repo where you worked today, and Claude turns your actual changes into a spoken-English workout built around your own code.

---

## Why this exists

Most English apps for developers give you generic dialogues about ordering coffee or booking hotels. That's not the gap.

The gap is this: you shipped the feature. You understand the code. You picked the trade-offs. But then you open your mouth in the standup, or in the code review, or on the tech talk — and it comes out flat. You reach for a word that isn't there. You default to "I changed some things" when what you did was *refactor the authentication middleware to support rotating refresh tokens*.

`takeclass` fixes that loop by practicing on the thing you already know: **today's diff**. You can't run out of material because you generate new material every day by doing your job.

---

## What it does

Each session produces four sections, tailored to your level and style:

**1. Warm-up vocabulary**
5–8 technical terms pulled from your diff — function names, domain concepts, libraries you touched — with pronunciation hints and a natural example sentence for each.

**2. A script to read aloud**
150–300 words narrating what you did today, in the register you chose (standup / PR description / tech talk / casual). Calibrated to your level: simpler sentences if you're starting, hedged and nuanced prose if you're advanced. Warm-up vocabulary bolded the first time it appears.

**3. Rephrase drills**
Three sentences from the script rewritten in two other registers (formal ↔ casual, simple ↔ advanced, active ↔ passive). The point is flexibility — saying the same idea three different ways so you can match the room.

**4. Self-check questions**
Three open prompts you answer out loud. No grading, no autocorrect. Just you talking to yourself about your own code in English: *Why did you pick this approach? What did you give up? How would you defend it in review?*

Your level, style, and recurring weak points are remembered across sessions. Every 5 classes, the difficulty nudges up.

---

## Install

Requires [Claude Code](https://claude.com/claude-code).

```bash
git clone https://github.com/BraianTroncoso/takeclass.git ~/dev-own/takeclass
bash ~/dev-own/takeclass/scripts/install.sh
```

The installer creates two symlinks inside `~/.claude/`:

- `~/.claude/skills/dev-english-practice` → `<repo>/skills/dev-english-practice`
- `~/.claude/commands/takeclass.md` → `<repo>/commands/takeclass.md`

Editing the skill in the repo updates what Claude sees live — no reinstall needed.

To uninstall:

```bash
bash ~/dev-own/takeclass/scripts/uninstall.sh
```

Only symlinks that point back to this repo are removed; the rest of your Claude config stays untouched.

---

## Usage

Inside Claude Code, from any git repo where you worked today:

```
/takeclass
```

First run asks for your level and style, saves them, and generates your class. Subsequent runs skip the setup.

Skip the setup from the start with args:

```
/takeclass advanced tech-talk
```

Valid levels: `beginner` · `intermediate` · `advanced`
Valid styles: `standup` · `pr-description` · `tech-talk` · `casual-explain`

You can also trigger it in plain language:

> *"take an English class on what I did today"*
> *"let me practice a standup in English"*
> *"I want to rehearse explaining this refactor"*

---

## A real example

```
📚 English class — session #3 — intermediate / standup — 2026-04-17

### 1. Warm-up vocabulary
- middleware /ˈmɪd.əl.wer/ — software that sits between layers.
  Example: I updated the auth middleware this morning.
- refactor /ˌriːˈfæk.tər/ — to restructure code without changing behavior.
  Example: I had to refactor the token handler.
- edge case /ˈɛdʒ keɪs/ — an unusual input or condition.
  Example: We missed an edge case when the token is empty.

### 2. Script to read aloud
Yesterday I worked on the refactor of the auth middleware. The goal was to
support refresh tokens without breaking existing flows. I moved the refresh
logic into its own helper so the middleware stays thin. Along the way I caught
an edge case: when the incoming token is valid but expired by less than a
second, the old code rejected it. I added a small buffer window and a test
that covers it. Today I'm going to wire the helper into the session endpoint
and open the PR. Blockers: none, though I want a second pair of eyes on the
buffer value before we ship.

### 3. Rephrase drill
- "I moved the refresh logic into its own helper."
  → Formal: "The refresh logic was extracted into a dedicated helper."
  → Casual: "I pulled the refresh logic out into a helper."
...

### 4. Self-check questions
1. Why did you add a buffer window instead of rejecting the token outright?
2. What trade-off comes with making the buffer configurable later?
3. If a reviewer said "this buffer hides bugs", how would you defend it?

💡 When you finish reading aloud, tell me which words tripped you up — I'll log
them for next time.
```

---

## Fallbacks and safeguards

- **Not in a git repo?** The skill asks you to summarize your day in 1–2 sentences and builds the class from that.
- **No commits today?** Same fallback.
- **Huge diff?** Summarized by file so the class stays focused on the important parts.
- **Secrets in your diff?** Anything that looks like a token, password, or `.env` value is stripped before it gets used as class material.
- **Diff is noise (formatters, auto-imports)?** Logic changes are prioritized over formatting-only changes.

---

## Roadmap

See [ROADMAP.md](./ROADMAP.md) for the detailed specs. In short:

- **v0.2 — Mirror mode.** Invert the flow: you narrate first, Claude returns a polished version with a diff of what changed and why. Active learning, not passive reading.
- **v0.3 — Streak + weekly recap.** Daily streak counter on every class, plus a separate `/takeclass-recap` command that summarizes the week — sessions, vocabulary learned, top weak points, next week's focus.
- **v0.4 — Voice loop.** Read the script aloud, Claude hears you, flags pronunciation and filler words. Bring your own STT (OS dictation, Whisper, etc.).
- **v0.5 — MCP server.** Decouple the logic so any MCP client can host the class, not just Claude Code.
- **v0.6 — Progression engine.** Spaced-repetition for weak words, automatic difficulty curve, vocabulary deck.
- **v0.7+** — interview-practice mode, team mode, Linear/Jira integration, persona mode.

---

## Contributing

PRs welcome. Good first contributions:

- New styles (e.g. `interview-practice`, `sprint-review`, `architecture-review`).
- Better phonetic hints for common Spanish-speaker pain points.
- Example outputs for levels that aren't well-represented yet.
- Translations of the teaching scaffolding (the *target* language stays English; the scaffolding around it can localize).

Open an issue first for bigger changes so we can align on direction.

---

## License

MIT — see [LICENSE](./LICENSE).

---

## More work by the same author

Selected projects from [@BraianTroncoso](https://github.com/BraianTroncoso):

- **Frontdeck** *(private)* — Design system platform that generates premium websites where every site has its own visual identity, narrative structure, and component architecture, from a single codebase. 474+ Vue components, 22 themes, 39 block types, 200+ variants, AI-native design pipeline. Not a template. A design engine. *(Laravel 12 + Vue 3 + Filament + Inertia + GSAP + Three.js + Tailwind 4)*

- **LevelUp** *(private)* — Stoic habit tracker PWA with 23 curated daily habits, an honest self-evaluation flow (*"did you actually do the work before feeling bad?"*), and a live chat with Marcus Aurelius, Seneca, and Epictetus powered by Llama 3.3. XP system, streaks, Memento Mori tracker, shareable progress cards. Trilingual (ES/EN/PT), fully offline-capable. *(Next.js 16 + Framer Motion + Groq AI + PWA)*

- **[myjarbis](https://github.com/BraianTroncoso/myjarbis)** — AI Dev Assistant with persistent memory for Claude Code.

- **GesturePilot** — Control Claude Code with hand gestures.

- **GymSphere** *(private)* — Gym management platform.

- **SecondBraian** *(private)* — My second brain. Personal knowledge vault powered by Obsidian. PARA method, Maps of Content, 10 custom templates. Where thoughts become connections and chaos becomes clarity.

- **GAME-JAM-FAD-CUYO-2022** — A complete game built in under 12 hours at a game jam. Ship or die.
