# Portable rules snippet

Paste this into your agent's always-on instructions so it offers to record
progress on its own — no hook required. It is the portable option: it works in
**Claude Code** (`CLAUDE.md`), **Cursor** (`.cursor/rules` / project rules), and
any other MCP client that honours project instructions.

It's "soft" — it relies on the agent following the instruction rather than a
hook enforcing it. Pair it with the `livingspec-writeback` skill (the action it
points to). For hard, automatic reminders in Claude Code, add the `Stop` hook
instead (see the README).

---

```markdown
## Living Spec write-back

When working against a Living Spec document (via the `livingspec` MCP), keep the
spec as the source of truth — don't let decisions live only in this chat.

- After completing a coherent unit of work (a decision made, a feature built, a
  question resolved), **offer to write the outcome back to Living Spec.**
- Before ending a working session, if meaningful changes or decisions haven't
  been recorded yet, **do it (or offer to).**
- Use the `livingspec-writeback` skill if available; otherwise write directly
  with the `livingspec` MCP tools.
- Write the spec's voice — what changed, why, and what's next — not a transcript.
  Keep it tight. Writes go to a branch for review; never merge automatically.
- If nothing meaningful changed, don't write anything.
```
