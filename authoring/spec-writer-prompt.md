# Spec-writer prompt

A reusable prompt for drafting a spec that's **reviewable and buildable**,
instead of confident mush. Use it three ways:

- Paste it into a chat when you start a spec.
- Drop it in your always-on instructions (`CLAUDE.md` / `.cursor/rules`) so every
  spec the agent drafts follows the same shape.
- Save it as a skill / command (e.g. `/spec-writer`) for one-key access.

The prompt does little that's clever. Its whole job is to force the parts people
skip: explicit non-goals, acceptance criteria a reviewer can actually check, and
open questions surfaced instead of papered over with a plausible-sounding guess.
A spec is only as good as what it's grounded in — pair this with
[`voice-and-template.md`](./voice-and-template.md) so the draft matches the
customer's existing specs rather than a blank-page default.

The last instruction hands off to the other half of this kit: the draft ends by
writing itself back to Living Spec, on a branch. On its own that line is the weak
version of write-back enforcement — pair it with the
[Stop hook](../README.md#3-the-stop-hook-claude-code-automatic) for the reliable
version.

---

```markdown
You are writing a specification that will be reviewed and built from. Ground
every section in the provided source material (existing specs, tickets, notes,
this conversation); do not invent requirements. Where the source is silent, say
so explicitly rather than guessing.

Produce these sections, in this order:

1. Problem & context — what's broken or missing, for whom, and why now. One
   paragraph. No solution language here.
2. Goals — the outcomes that define success, as a short list.
3. Non-goals — what this explicitly does NOT cover. Required. If you can't name
   any, you haven't scoped tightly enough — go back and tighten.
4. Proposed behavior — what the user and system do, observably and concretely.
   Describe behavior, not implementation, unless the implementation is the point.
5. Acceptance criteria — each one a statement a reviewer can mark true or false
   by observation. If a criterion can't be checked, rewrite it until it can.
6. Open questions — every decision you had to assume, or couldn't resolve from
   the source. Tag each [blocking] or [non-blocking]. Do not hide these by making
   a confident-sounding choice; an unanswered question is more useful than a
   wrong answer.
7. Risks & dependencies — what could break this, block it, or change its shape.

Rules:
- Match the structure and voice of the example spec(s) provided. If none are
  provided, ask for one before writing — do not fall back to a generic template.
- No filler ("it is important to note", "in today's fast-paced…"). Every
  sentence carries information.
- Flag uncertainty inline rather than smoothing it over.
- Prefer the customer's terminology over your own; if you introduce a term,
  define it once.
- When you're done, write the spec back to Living Spec via the document MCP
  tools, on a branch for review. This is part of the task, not optional.
```

---

## Tuning it

- **For a lightweight spec** (a single feature, an RFC), drop sections 7 and
  collapse 4–5 into one — but keep non-goals and open questions. Those two are
  the sections that earn the spec its keep.
- **For a heavyweight spec** (a system, a migration), add a "Rollout / migration"
  section after 6 and ask for a sequencing plan.
- **The non-goals and open-questions discipline is the part not to cut.** Most
  bad specs are bad because they're silent on scope boundaries and quietly guess
  on the things nobody had decided yet. These two sections drag both into the
  open.
