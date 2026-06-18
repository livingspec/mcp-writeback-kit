# Living Spec write-back kit

Tools to help people **remember to write their work back to Living Spec** when
using an AI coding agent with the Living Spec MCP. The problem this solves:
decisions and progress end up in the chat and never make it into the spec.

There's no single right form — different users want different amounts of
nudging. So this kit ships three layers; use any or all.

| Layer | What it is | Reminds you? | Works in |
|---|---|---|---|
| **Skill** | `livingspec-writeback` — the *action*: summarize the session and write it to a Living Spec page, on a branch. | No (you run it) | Claude Code, Cursor, any MCP client |
| **Rules snippet** | A line in your always-on instructions telling the agent to offer a write-back at checkpoints. | Soft (agent-driven) | Claude Code, Cursor, … |
| **Stop hook** | A conditional Claude Code hook that nudges automatically. Two modes: `reminder` (non-blocking) and `enforce` (blocks until you write back). | Yes (automatic) | Claude Code only |

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

## How the hook behaves

It's built to stay out of your way:

- **Only fires in sessions that actually used the Living Spec MCP** (it checks
  the transcript), so unrelated work is never nudged.
- **At most one nudge per interval** (default 20 min), per session — this is
  also the loop guard that keeps `enforce` from blocking repeatedly.
- **Goes quiet after a write-back.** The skill writes a timestamp to
  `~/.claude/livingspec/last-writeback`; the hook respects it for one interval.
- **Fail-open.** Any problem (no `jq`, unreadable state) exits silently — a hook
  issue can never block your session.

Config (set as env in the hook `command`, or your shell):

| Variable | Default | Meaning |
|---|---|---|
| `LIVINGSPEC_WRITEBACK_MODE` | `reminder` | `reminder` (non-blocking) or `enforce` (blocks) |
| `LIVINGSPEC_WRITEBACK_INTERVAL_MIN` | `20` | minutes between nudges, and the quiet window after a write-back |

## Uninstall

Remove the `Stop` block from your settings, delete
`~/.claude/hooks/livingspec-writeback-hook.sh`, and (optionally) clear
`~/.claude/livingspec/`.
