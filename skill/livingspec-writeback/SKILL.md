---
name: livingspec-writeback
description: Summarize what happened in this working session and write it back to the relevant Living Spec page via the Living Spec MCP, on a branch for review. Use when the user says "write back to Living Spec", "update the spec", "record progress in Living Spec", "spec writeback", "sync to Living Spec", or when a reminder prompts you to capture progress. Requires the livingspec MCP to be connected.
---

# Living Spec write-back

Record the meaningful outcome of this working session back into Living Spec, so
the spec stays the source of truth instead of the decisions living only in the
chat. **Writes always go to a branch for a human to review — never straight to
main.**

## When to use

- The user asks to write back / update the spec / record progress.
- A reminder (the write-back hook, or project rules) prompts a checkpoint after
  meaningful work.
- A coherent unit of work just finished: a decision made, a feature built, a
  question resolved.

## What to write — and what NOT to

Write the spec's voice, not a transcript. Capture only:

- **What changed** — the concrete outcome (a decision, a built feature, a
  resolved question), not a play-by-play.
- **Why** — the rationale or trade-off, briefly, where it isn't obvious.
- **Open questions / next steps** — anything left for later.

Do **not** paste the conversation, tool logs, or code dumps. A few tight
sentences or bullets per item. **If nothing meaningful happened this session,
say so and skip the write** — don't manufacture an entry.

## Steps

1. **Pick the document.** If you've already been reading/writing one Living Spec
   document this session, use that. Otherwise call `ListDocuments` (if the tool
   is available) and choose the most relevant — most-recently-visited is a good
   default — or ask the user which document to write to. Never guess a document
   id.
2. **Pick the destination page.** Prefer a page or section that holds running
   progress — e.g. a "Progress log" or "Session notes" section. Use `ListPages`
   / `GetPage` to find it. If none exists, append to the most relevant page, or
   create a "Progress log" page (`CreatePage`) — ask first if it's unclear where
   it belongs.
3. **Draft the entry.** Lead with today's date. Keep it to the what / why / next
   above. Markdown **body only** — no `#` H1 title (the page title is a separate
   field).
4. **Write it on a branch.**
   - `EnsureBranch({ documentId, name: "writeback" })` — a stable branch name so
     repeated write-backs collect on the same review branch.
   - Add the entry with `UpsertSection` (idempotent — ideal for a dated
     "Progress log" section) or `AppendToPage` (for a fresh dated entry).
   - **Do not merge.** Leave it in the Branches tab for a human to review.
5. **Mark the write-back done** so the reminder hooks go quiet for a while.
   Best-effort (skip if you can't run shell): write the current epoch seconds to
   the marker for whichever client you're in — covering both is harmless:
   `mkdir -p ~/.claude/livingspec ~/.cursor/livingspec; date +%s | tee ~/.claude/livingspec/last-writeback ~/.cursor/livingspec/last-writeback >/dev/null`
6. **Report** the document, page, branch, and a one-line summary of what you
   wrote.

## Notes

- Writes are branch-gated by design — write freely, a human reviews before
  anything lands on main.
- Keep entries **additive**: append dated notes; don't rewrite earlier history.
- This works in any MCP client (Claude Code, Cursor, …). The reminder *hook* is
  Claude Code-only; the skill itself is portable.
