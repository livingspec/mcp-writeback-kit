#!/usr/bin/env bash
#
# Living Spec write-back hook — a conditional Claude Code `Stop` hook that nudges
# you to record session progress back to Living Spec when you've been working
# with a spec for a while without writing one back.
#
# It is deliberately quiet: it only fires in sessions that actually used the
# Living Spec MCP, at most once per interval, and goes silent after a write-back.
#
# Two behaviours, chosen with LIVINGSPEC_WRITEBACK_MODE:
#   reminder  (default)  non-blocking — Claude sees a nudge it can act on, the
#                        turn still ends. Zero risk of interrupting you.
#   enforce              blocks the stop once per interval and tells Claude to
#                        write back before finishing.
#
# Config (env):
#   LIVINGSPEC_WRITEBACK_MODE          reminder | enforce      (default: reminder)
#   LIVINGSPEC_WRITEBACK_INTERVAL_MIN  minutes between nudges  (default: 20)
#
# Fail-open by design: any problem (no jq, unreadable state, etc.) exits 0 so a
# hook issue can never block your session.

set -uo pipefail

# No jq -> can't parse the hook payload; don't interfere.
command -v jq >/dev/null 2>&1 || exit 0

MODE="${LIVINGSPEC_WRITEBACK_MODE:-reminder}"
INTERVAL_MIN="${LIVINGSPEC_WRITEBACK_INTERVAL_MIN:-20}"

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // "default"')"
transcript="$(printf '%s' "$input" | jq -r '.transcript_path // ""')"

# Only nudge in sessions that actually touched the Living Spec MCP.
[ -n "$transcript" ] && [ -f "$transcript" ] &&
  grep -q "mcp__livingspec" "$transcript" 2>/dev/null || exit 0

state_dir="${HOME}/.claude/livingspec"
mkdir -p "$state_dir" 2>/dev/null || exit 0
nudge_marker="${state_dir}/last-nudge-${session_id}"
writeback_marker="${state_dir}/last-writeback" # the skill touches this

now="$(date +%s)"
interval_s=$(( INTERVAL_MIN * 60 ))

# Quiet if a write-back happened within the interval.
if [ -f "$writeback_marker" ]; then
  last_wb="$(cat "$writeback_marker" 2>/dev/null || echo 0)"
  [ $(( now - last_wb )) -lt "$interval_s" ] && exit 0
fi

# Cadence + loop guard: at most one nudge per interval, per session. This is
# also what stops an `enforce` block from looping — the continuation turn lands
# back here within the interval and exits quietly.
if [ -f "$nudge_marker" ]; then
  last_nudge="$(cat "$nudge_marker" 2>/dev/null || echo 0)"
  [ $(( now - last_nudge )) -lt "$interval_s" ] && exit 0
fi
echo "$now" >"$nudge_marker"

read -r -d '' msg <<'EOF' || true
You've been working with Living Spec this session without recording progress recently. Summarize this session's key changes, decisions, and next steps and write them back to the relevant Living Spec page — on a branch for review (writes are branch-gated, so this is safe). Prefer the livingspec-writeback skill if it's installed; otherwise use the livingspec MCP write tools directly. Keep it tight: the spec's voice, not a transcript. If nothing meaningful changed, skip it.
EOF

if [ "$MODE" = "enforce" ]; then
  jq -n --arg r "$msg" '{decision:"block", reason:$r}'
else
  jq -n --arg c "$msg" \
    '{hookSpecificOutput:{hookEventName:"Stop", additionalContext:$c}}'
fi
exit 0
