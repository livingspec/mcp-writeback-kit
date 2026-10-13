---
name: livingspec-writeback
description: Summarize what happened in this working session and write it back to the relevant Living Spec page via the Living Spec MCP, on a branch for review. Use when the user says "write back to Living Spec", "update the spec", "record progress in Living Spec", "spec writeback", "sync to Living Spec", or when a reminder prompts you to capture progress. Requires the livingspec MCP to be connected.
---

# Living Spec write-back

Record the meaningful outcome of this working session back into Living Spec, so
the spec stays the source of truth instead of the decisions living only in the
chat. **Writes always go to a branch for a human to review, never straight to
main.**

## When to use

- The user asks to write back / update the spec / record progress.
- A reminder (the write-back hook, or project rules) prompts a checkpoint after
  meaningful work.
- A coherent unit of work just finished: a decision made, a feature built, a
  question resolved.

## What to write

Capture outcomes, not a transcript:

- **What changed**: a decision, a built feature, a resolved question.
- **Why**: the reason or trade-off, only where it isn't obvious.
- **Next**: what is left open.

Do **not** paste the conversation, tool logs, or code dumps. **If nothing
meaningful happened this session, say so and skip the write.** Don't
manufacture an entry.

If it's unclear which outcomes the user wants recorded, record decisions and
resolved questions, and say in your report what you left out.

## The entry shape

Every entry is a date line followed by a bullet list. Never paragraphs.

- Two to five bullets. More than five usually means two entries.
- One plain statement per bullet, roughly under 20 words.
- Order: what changed first, why in the middle, next last.
- Sentence fragments are fine. Name the thing: the screen, the field, the
  endpoint, the ticket. Every bullet has to make sense to someone who wasn't in
  the session.

Good:

> **2026-10-13**
> - Checkout skips the address step for returning customers
> - Saved address is reused only if it passed validation in the last 90 days
> - Guest checkout unchanged
> - Open: what to show when the saved address fails validation

> **2026-10-13**
> - Export endpoint now streams the zip instead of building it in memory
> - Large documents were timing out at the 30s proxy limit
> - Next: add a size cap once we see real bundle sizes

Bad, and why:

> In this session we worked extensively on the checkout flow. After exploring
> several options, we decided that it would be beneficial to skip the address
> step for returning customers, which ensures a more seamless experience.

Paragraph instead of bullets, narrates the session ("we worked extensively",
"after exploring"), sells the change ("beneficial", "seamless") instead of
stating it, and drops the 90-day condition that a reviewer needs.

> - Updated the code
> - Fixed some issues
> - Made improvements to performance

Right shape, no content. Nobody outside the session can tell what changed.

## Voice

Match the document. Before drafting, read a recent entry or a nearby section
and copy its person ("you" vs "the user"), terminology, and formality. See
[`authoring/voice-and-template.md`](../../authoring/voice-and-template.md).

Whatever the document's voice, strip AI tells:

- **No filler or persuasion:** "It's worth noting", "This ensures that", "It is
  important to", "might be worth considering". State it and stop.
- **No reflexive adjectives:** "robust", "seamless", "comprehensive",
  "powerful", "streamlined".
- **No AI phrasing:** "leverage", "delve", "Let's", "not just X but Y",
  three-beat lists added for rhythm.
- **No clever closers.** End the bullet when the fact ends.
- **No invented jargon.** Spell a mechanism out the first time instead of
  coining a name for it.

## Steps

1. **Pick the document.** If you've already been reading/writing one Living Spec
   document this session, use that. Otherwise call `ListDocuments` (if the tool
   is available) and choose the most relevant (most-recently-visited is a good
   default), or ask the user which document to write to. Never guess a document
   id.
2. **Pick the destination page.** Prefer a page or section that holds running
   progress, e.g. a "Progress log" or "Session notes" section. Use `ListPages`
   / `GetPage` to find it. If none exists, append to the most relevant page, or
   create a "Progress log" page (`CreatePage`). Ask first if it's unclear where
   it belongs.
3. **Open the branch and read before writing.**
   - `EnsureBranch({ documentId, name: "writeback" })`. A stable branch name, so
     repeated write-backs collect on the same review branch.
   - `GetPage` the destination **on the branch**. Earlier write-backs may already
     be sitting there unmerged. If an outcome is already recorded, on main or on
     the branch, don't record it again. If everything is already recorded, skip
     the write and say so.
4. **Draft the entry** in the shape and voice above. Markdown **body only**, no
   `#` H1 title (the page title is a separate field).
5. **Write it.** `UpsertSection` for a dated "Progress log" section, or
   `AppendToPage` for a fresh dated entry. **Do not merge.** Leave it in the
   Branches tab for a human to review.
6. **Read it back.** `GetPage` the destination on the branch again and confirm
   the entry is there once, under the right heading.
7. **Mark the write-back done** so the reminder hooks go quiet for a while.
   Best-effort (skip if you can't run shell): write the current epoch seconds to
   the marker for whichever client you're in. Covering both is harmless:
   `mkdir -p ~/.claude/livingspec ~/.cursor/livingspec; date +%s | tee ~/.claude/livingspec/last-writeback ~/.cursor/livingspec/last-writeback >/dev/null`
8. **Report** the document, page, and branch (names and ids), the entry as
   written, and anything you chose not to record.

## Corrections

If the user says an entry is wrong, fix that entry on the branch with
`UpsertSection`. Don't append a second "correction" entry. The branch is
unmerged, so nothing has landed yet and there is no history to preserve.

If the user asks what a word in an entry means, the entry is unclear. Answer,
then rewrite the bullet.

Once an entry is merged to main, it is history: add a new dated entry instead
of editing the old one.

## Never

- Never merge the branch.
- Never write straight to main.
- Never record the same outcome twice.
- Never rewrite merged entries.

## Notes

- Writes are branch-gated by design. Write freely; a human reviews before
  anything lands on main.
- This works in any MCP client (Claude Code, Cursor, …). The reminder *hook* is
  Claude Code and Cursor only; the skill itself is portable.
