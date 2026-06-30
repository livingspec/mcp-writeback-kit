# Writing in the customer's template and voice

"Write it in our voice" produces generic output every time. You don't prompt a
voice — you **show** it. The reliable move is to ground the draft in the
customer's own existing specs: derive the *template* (structure) and the *voice*
(style) from real examples, then constrain generation to both.

Living Spec is unusually well-positioned for this because it already stores the
customer's specs. The grounding — not the prompt — is what a blank LLM call can't
match. Two things come out of their existing pages:

- **Template = structure.** Heading order, section names, what each section
  contains, length norms. This becomes a fixed scaffold the draft fills, not a
  loose suggestion.
- **Voice = style.** Sentence length, formality, how much they hedge, domain
  jargon, person ("you" vs "the user"), bullet-vs-prose ratio. Fed as explicit
  constraints *and* as inline examples — the examples do most of the work.

## The cheap version (works today, any MCP client)

Point the agent at one existing page as the template, then have it clone the
structure and mimic the voice. Paste this alongside the
[spec-writer prompt](./spec-writer-prompt.md):

```markdown
Before drafting, study the example spec(s) I point you to (use the livingspec
MCP — GetPage / ListPages — to read them). Extract two things and state them
back to me in 3–4 lines before you write:

- Template: the section order and what each section contains.
- Voice: sentence length, formality, person ("you" vs "the user"), jargon, and
  bullet-vs-prose ratio.

Then draft the new spec to match BOTH. Reuse their section names and their
terminology verbatim. If the new spec needs a section the examples don't have,
add it but flag it as a departure. Match the voice — do not default to a generic
"clean" tone.
```

Stating the extracted template and voice back first is the cheap quality lever:
it surfaces a wrong read before a whole draft is built on it, and it gives the
generation an explicit target instead of an implicit one.

## The better version (a Living Spec feature, not a prompt)

The cheap version makes *you* pick the template page. The product move is to pick
it automatically: retrieve the customer's most-similar existing specs over their
page set and ground on those, so the user starts from their own house style
without choosing anything. Living Spec already has the page projections to do the
retrieval — this is a retrieval feature, not a prompting one, and it's the part
competitors drafting from a cold model can't copy.

Rough shape:

- On "new spec," retrieve the N nearest existing specs (by title/section
  similarity, tag, or document neighborhood).
- Derive a template scaffold from their common structure; derive a voice profile
  from their prose.
- Pre-fill the draft against both; show the user which specs it learned from so
  the grounding is inspectable, not magic.

## After drafting: a light de-AI pass

Grounding gets the voice close, but a first draft still leaks the usual AI
tells — filler ("it is important to note"), three-beat fragments, "not just X but
Y", reflexive corporate adjectives. A spec full of those reads as
machine-generated no matter how well it's structured, so it's worth one cleanup
pass before the spec goes to review:

```markdown
Do one pass over the draft to strip AI tells: filler phrases, three-beat
fragments, "not just X but Y" constructions, and reflexive adjectives. Keep the
spec's register and the customer's voice — do NOT rewrite toward a punchy,
spoken, or opinionated tone. The goal is to remove the machine seams, not to
change what kind of document this is.
```

The constraint in the second sentence is the whole point. General-purpose
"humanize this" tooling (e.g. the `humanize-writing` skill's `pattern-disruptor`
and `credibility-test` modes) is built for exactly this de-tell pass — but its
voice-shaping modes (`make-it-hit`, `voice-shaper`) optimize for spoken,
opinionated prose, which is the wrong register for a spec. Use the tell-stripping
modes; skip the voice-shaping ones.

## What not to do

- **Don't ask for "professional / polished / clean" tone.** That's how you get
  the generic AI voice. The customer's voice is whatever their existing specs
  are — even if that's terse, informal, or idiosyncratic. Match *them*, not an
  abstract ideal.
- **Don't ground on one weird outlier.** If you're picking a template page by
  hand, pick a representative one (or two or three), not the longest or the
  newest by reflex.
- **Don't let voice-matching override substance.** Structure and tone are the
  wrapper; the spec-writer prompt's discipline (non-goals, checkable acceptance
  criteria, surfaced open questions) still governs the content.
