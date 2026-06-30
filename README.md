# Living Spec write-back kit

Tools for working a spec with an AI coding agent over the Living Spec MCP, across
two phases of a spec's life:

- **Authoring** — *writing the spec in the first place*, in the customer's own
  template and voice. See [`authoring/`](./authoring/).
- **Write-back** — *keeping it current* as work happens, so decisions and
  progress don't end up stranded in the chat. The rest of this README.

The two are independent — use either alone. The bulk of this kit is write-back,
because "remember to record what just happened" is the harder problem: a prompt
asking the agent to remember loses every race against the actual task, so it
needs a hook, not just an instruction.

## Authoring: writing the spec

Grounding beats prompting. A clever prompt is the small lever; the thing a raw
LLM can't match is drafting in the customer's *own* house style, learned from
their existing specs.

| File | What it is |
|---|---|
| [`authoring/spec-writer-prompt.md`](./authoring/spec-writer-prompt.md) | A reusable prompt that forces the parts people skip — explicit non-goals, checkable acceptance criteria, surfaced open questions. Paste it, drop it in your rules, or save it as a `/spec-writer` command. |
| [`authoring/voice-and-template.md`](./authoring/voice-and-template.md) | How to make a draft match the customer's template (structure) and voice (style) by grounding it in their existing Living Spec pages — a cheap prompt-only version that works today, and the better retrieval-based version. |

## Write-back: keeping the spec current

The problem this solves: decisions and progress end up in the chat and never make
it into the spec.

There's no single right form — different users want different amounts of
nudging. So this layer ships several pieces; use any or all.

| Layer | What it is | Reminds you? | Works in |
|---|---|---|---|
| **Skill** | `livingspec-writeback` — the *action*: summarize the session and write it to a Living Spec page, on a branch. | No (you run it) | Claude Code, Cursor, any MCP client |
| **Rules snippet** | A line in your always-on instructions telling the agent to offer a write-back at checkpoints. | Soft (agent-driven) | Claude Code, Cursor, … |
| **Stop hook (Claude Code)** | A conditional Claude Code hook that nudges automatically. Two modes: `reminder` (non-blocking) and `enforce` (blocks until you write back). | Yes (automatic) | Claude Code |
| **Stop hook (Cursor)** | A Cursor hook that nudges automatically by submitting a follow-up (the `enforce` analog — Cursor has no non-blocking mode). | Yes (automatic) | Cursor |

The skill is the *doing*; the rules snippet and hook are the *remembering*. Most
people want the **skill + rules snippet**. Add the **hook** if you want it
automatic; pick `enforce` only if you want it to actually stop you.

All write-backs go to a **branch for human review** — nothing lands on main
automatically.

## Install

Prereq: the `livingspec` MCP connected (see the "Connect Claude Code to Living
Spec" guide). The hook also needs `jq` and `bash`.

Get the kit (the install steps below run from inside it):

```bash
git clone https://github.com/livingspec/mcp-writeback-kit.git
cd mcp-writeback-kit
```

### 1. The skill (recommended)

Copy the skill into your skills directory:

```bash
# user scope (all projects)
cp -r skill/livingspec-writeback ~/.claude/skills/
# or project scope
cp -r skill/livingspec-writeback .claude/skills/
```

Then invoke it with `/livingspec-writeback`, or just ask "write this back to
Living Spec." Cursor users: point your skills/rules setup at the same
`SKILL.md`.

### 2. The rules snippet (portable, soft reminder)

Paste the block from [`rules-snippet.md`](./rules-snippet.md) into your
`CLAUDE.md` (Claude Code) or `.cursor/rules` (Cursor). This makes the agent
offer to write back on its own — no hook needed.

### 3. The Stop hook (Claude Code, automatic)

```bash
mkdir -p ~/.claude/hooks
cp hooks/livingspec-writeback-hook.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/livingspec-writeback-hook.sh
```

Then merge **one** of the `hooks` blocks into your settings:

- [`settings/reminder.settings.json`](./settings/reminder.settings.json) —
  non-blocking nudge (recommended).
- [`settings/enforce.settings.json`](./settings/enforce.settings.json) — blocks
  the stop once per interval until you write back.

into `~/.claude/settings.json` (all projects) or `.claude/settings.json` (one
project). Restart Claude Code, or run `/hooks` to confirm it's registered.

> The `command` uses `"$HOME/.claude/hooks/..."`; if your shell doesn't expand
> `$HOME` there, replace it with the absolute path.

### 4. The Stop hook (Cursor, automatic)

Cursor (v1.7+) has hooks too. The behaviour is the **enforce** analog only —
Cursor's stop hook can submit a follow-up message (which re-engages the agent)
or stay silent; it has no non-blocking "reminder" output. For a soft nudge in
Cursor, use the rules snippet above.

```bash
mkdir -p ~/.cursor/hooks
cp cursor/livingspec-mark-usage.sh cursor/livingspec-writeback-stop.sh ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/livingspec-*.sh
```

Then merge the `hooks` block from [`cursor/hooks.json`](./cursor/hooks.json) into
`~/.cursor/hooks.json` (global) or `<project>/.cursor/hooks.json` (project). It
registers two hooks:

- `afterMCPExecution` → `livingspec-mark-usage.sh` marks a conversation as having
  used the Living Spec MCP. It's observe-only — it never affects the MCP call.
- `stop` → `livingspec-writeback-stop.sh` submits the write-back follow-up, gated
  by the same interval / quiet-after-write-back logic, with `loop_limit: 3` as a
  hard cap on auto follow-ups.

> Same `$HOME` caveat as above. Detection matches `livingspec` in the MCP call
> payload; if you've named the server differently, adjust the match in
> `livingspec-mark-usage.sh`.

## How the hook behaves

It's built to stay out of your way:

- **Only fires in sessions that actually used the Living Spec MCP** — Claude
  Code checks the session transcript; Cursor uses the `afterMCPExecution` marker.
  Unrelated work is never nudged.
- **At most one nudge per interval** (default 20 min), per session — this is
  also the loop guard that keeps `enforce` from blocking repeatedly.
- **Goes quiet after a write-back.** The skill writes a timestamp to
  `~/.claude/livingspec/last-writeback`; the hook respects it for one interval.
- **Fail-open.** Any problem (no `jq`, unreadable state) exits silently — a hook
  issue can never block your session.

Config (set as env in the hook `command`, or your shell):

| Variable | Default | Meaning |
|---|---|---|
| `LIVINGSPEC_WRITEBACK_MODE` | `reminder` | Claude Code only — `reminder` (non-blocking) or `enforce` (blocks). Cursor is always follow-up (enforce-style). |
| `LIVINGSPEC_WRITEBACK_INTERVAL_MIN` | `20` | minutes between nudges, and the quiet window after a write-back (both clients) |

## Uninstall

Remove the `Stop` block from your settings, delete
`~/.claude/hooks/livingspec-writeback-hook.sh`, and (optionally) clear
`~/.claude/livingspec/`.
