#!/usr/bin/env bash
#
# Cursor `stop` hook — nudges you to write session progress back to Living Spec.
#
# Cursor's stop output is binary: emit a follow-up message (which re-engages the
# agent for another turn) or stay silent. So this is the **enforce** analog of
# the Claude Code hook — there is no non-blocking "reminder" mode in Cursor. For
# a soft, non-forcing nudge, use the rules snippet instead.
#
# Only fires in conversations that actually used the Living Spec MCP (set by the
# afterMCPExecution mark-usage hook), at most once per interval, and goes quiet
# after a write-back. Fails open: any problem exits silently.
#
# Config (env):
#   LIVINGSPEC_WRITEBACK_INTERVAL_MIN  minutes between nudges (default: 20)
#
# Pair with `loop_limit` in hooks.json as a hard cap on auto follow-ups.

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

INTERVAL_MIN="${LIVINGSPEC_WRITEBACK_INTERVAL_MIN:-20}"

input="$(cat)"
conv="$(printf '%s' "$input" | jq -r '.conversation_id // "default"')"

dir="${HOME}/.cursor/livingspec"
used_marker="${dir}/used-${conv}"
nudge_marker="${dir}/last-nudge-${conv}"
writeback_marker="${dir}/last-writeback" # the skill touches this

# Only nudge if this conversation actually used the Living Spec MCP.
[ -f "$used_marker" ] || exit 0

now="$(date +%s)"
interval_s=$(( INTERVAL_MIN * 60 ))

# Quiet for a while after a write-back.
if [ -f "$writeback_marker" ]; then
  last_wb="$(cat "$writeback_marker" 2>/dev/null || echo 0)"
  [ $(( now - last_wb )) -lt "$interval_s" ] && exit 0
fi

# Cadence + loop guard: at most one nudge per interval. After the follow-up runs
# and the agent stops again, this marker is fresh, so the next stop stays silent.
if [ -f "$nudge_marker" ]; then
  last_nudge="$(cat "$nudge_marker" 2>/dev/null || echo 0)"
  [ $(( now - last_nudge )) -lt "$interval_s" ] && exit 0
fi
echo "$now" >"$nudge_marker"

read -r -d '' msg <<'EOF' || true
You've been working with Living Spec this session without recording progress recently. Summarize this session's key changes, decisions, and next steps and write them back to the relevant Living Spec page — on a branch for review (writes are branch-gated, so this is safe). Prefer the livingspec-writeback skill if it's installed; otherwise use the livingspec MCP write tools directly. Keep it tight: the spec's voice, not a transcript. If nothing meaningful changed, skip it.
EOF

jq -n --arg m "$msg" '{followup_message:$m}'
exit 0
