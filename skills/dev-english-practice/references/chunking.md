# Chunking reference

How to mark a read-aloud script so a non-native speaker knows **where to breathe, what
to stress, and which words never come apart**.

Read this before producing any chunked output. It defines five marks and three
formats. The marks are the same in every format; only the rendering changes.

---

## Why chunking exists

A learner reading a plain paragraph out loud makes three predictable mistakes,
and none of them are grammar:

1. **They pause in the wrong place** — usually wherever they run out of air, which
   lands mid-phrase and makes fluent English sound broken.
2. **They stress every word equally.** English is stress-timed: one beat per
   group, everything else deflates. Even stress is the single loudest tell of a
   Spanish, Italian or Portuguese speaker, louder than any conjugation error.
3. **They split fixed blocks.** `pick up`, `look for`, `at face value` behave like
   single words. Said with a gap in the middle, they stop sounding like English
   even when every phoneme is correct.

Chunking fixes all three on the page, before the mouth gets involved. It is a
reading aid, not a grammar aid.

---

## The five marks

| Mark | Meaning | Rule the reader follows |
|---|---|---|
| **Breath group** (two alternating shades) | A unit said in one push of air | Never pause inside one. The two shades carry no meaning — they alternate only so the eye can see where one ends and the next begins. |
| **Fixed block** (orange) | Phrasal verb or fixed collocation | Memorize it as one word. If a pause creeps into the middle, it isn't learned yet. |
| **Bold** | The stressed syllable | Exactly **one per group**. Never two. Everything else in the group deflates. |
| `‿` (U+203F) | Linking | Final consonant binds to the next vowel: `pick‿up` is *"pi-kap"*, not two words. |
| `▸` | Real pause | The only place a stop is allowed. Breathe here. |

### Sizing rules

- **An anchor** (one block the reader says without stopping) is **6–12 words**.
  Longer than that and the learner runs out of air, loses the thread, and restarts
  the sentence — which is the failure mode chunking exists to prevent.
- **A breath group** inside an anchor is **2–5 words**.
- **Fixed blocks** should be 8–18 per script. Fewer and the drill has no weight;
  more and nothing stands out.

### Recovery rule (state it to the user once per session)

> If you trip, **repeat the group, not the whole sentence.**

A group is three words. Repeating it costs a second and leaves the recording
editable. Restarting the sentence is what turns a stumble into a spiral.

---

## Format 1 — `cli` (default)

Inline in the conversation. No files, no dependencies, no rendering step. This is
the default because most of the time the user wants to read and move on.

Colored backgrounds are not available inline, so the five marks map onto markdown
that renders correctly in every terminal:

| Mark | Rendered as |
|---|---|
| Breath group boundary | ` │ ` (U+2502, spaces on both sides) |
| Fixed block | `` `backticks` `` |
| Stress | `**bold**` |
| Linking | `‿` unchanged |
| Pause | `▸` unchanged |

One anchor per line. Blank line between anchors.

```
I **asked** my agent │ if its own **work** │ was any **good**. ▸

And a **mod**el │ `goes along with` │ whatever it just **said**.

I would `take it at face value` ▸ but a**noth**er agent │ `tries to tear it‿apart`.
```

Do not put `**bold**` inside backticks — inline code does not render nested
formatting. A fixed block carries its own emphasis; it does not need bold too.

## Format 2 — `html`

Full color, identical to the PDF, and it scrolls — which is what you want if you
are reading off a second screen while recording.

Build it with `assets/chunking.css` (inline the file inside a `<style>` tag so the
document is self-contained and survives being moved or emailed). Markup:

```html
<div class="say">
  <span class="g1">I <b>asked</b> my agent</span>
  <span class="g2">if its own <b>work</b></span>
  <span class="g1">was any <b>good</b>.</span>
  <span class="pz">▸</span>
</div>
<div class="say">
  <span class="g1">And a <b>mod</b>el</span>
  <span class="gf"><b>goes</b><span class="lk">‿</span>along with</span>
  <span class="g2">whatever it just <b>said</b>.</span>
</div>
```

`g1` and `g2` alternate strictly. `gf` is a fixed block and breaks the alternation
without resetting it.

Write to a temp path, then open it: `wslview`, `xdg-open`, or `open`, whichever
exists. If none do, print the path and let the user open it.

## Format 3 — `pdf`

Same HTML, rendered with `weasyprint <in.html> <out.pdf>`. For printing, for a
tablet, or for keeping.

**`weasyprint` is optional and often absent.** Check before offering it:

```bash
command -v weasyprint
```

If it is missing, do not offer `pdf` as a choice and do not try to install it.
Offer `cli` and `html`, and mention in one line that `pip install weasyprint`
unlocks the PDF. Never let a missing optional dependency block the class.

---

## What gets chunked

Only **section 2, the script to read aloud**. It is the only section spoken
continuously.

Vocabulary, rephrase drills and self-check questions stay as they are — they are
reference and prompts, not performance. Chunking them adds visual noise and
teaches nothing, because nobody reads a definition out loud in one breath.

If the chunked output is `html` or `pdf`, the file carries the whole class (all
four sections) so it stands alone, but only section 2 uses `.say` blocks.

---

## Fixed-block table (html/pdf only)

When the format is `html` or `pdf`, follow the script with a table of every orange
block in it — three columns:

| Column | Content |
|---|---|
| Block | The words, exactly as they appear in the script |
| Sounds like | A rough respelling in the **user's own language**, not IPA |
| What it is | Meaning, plus the one thing that goes wrong with it |

Respelling beats IPA here. A Spanish speaker reads *"pi-kap"* correctly on sight
and needs a lookup table for /pɪk ʌp/. The goal is a mouth that moves, not
phonetic literacy.

Then a **90-second drill**, always the same three steps: read the block column out
loud top to bottom three times — slow and exaggerating the joins, then normal,
then fast. Teach opposing pairs together when the script has them
(`backed down` / `stood up to`) — a phrasal verb learned against its opposite
sticks far better than one learned alone.

Skip both the table and the drill in `cli` format. Inline, they push the script
off screen, and the script is the thing being practiced.
