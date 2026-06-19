#!/usr/bin/env bash
#
# Cursor `afterMCPExecution` hook — marks a conversation as having used the
# Living Spec MCP, so the write-back `stop` hook only nudges in relevant
# sessions. afterMCPExecution is observe-only (it can't affect the MCP call),
# and this script fails open, so it never interferes with anything.

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"

# Broad, robust match: "livingspec" appears in the tool name, params, or result
# of a Living Spec MCP call. If this isn't a Living Spec call, do nothing.
printf '%s' "$input" | grep -qi "livingspec" || exit 0

conv="$(printf '%s' "$input" | jq -r '.conversation_id // "default"')"
dir="${HOME}/.cursor/livingspec"
mkdir -p "$dir" 2>/dev/null || exit 0
date +%s >"${dir}/used-${conv}"
exit 0
