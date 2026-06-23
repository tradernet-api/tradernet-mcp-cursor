#!/usr/bin/env bash
#
# Tradernet MCP guard: ask for explicit confirmation before write/trade tools.
#
# Cursor calls this on `beforeMCPExecution` with JSON on stdin:
#   { "tool_name": "<name>", "tool_input": "<json params string>", ... }
#
# We emit a permission decision on stdout:
#   {"permission":"allow"}                       -> proceed
#   {"permission":"ask", "user_message":"..."}   -> require user confirmation
#
# Read-only tools (quotes, portfolio, history, tariffs, reports) pass through.
# Write/trade tools require confirmation so the agent can't silently mutate a
# real Tradernet account. Hook is failClosed in hooks.json, so any failure here
# blocks the call rather than letting it slip through.

set -euo pipefail

payload="$(cat || true)"

# Extract tool_name without requiring jq (fallback to grep/sed).
tool_name=""
if command -v jq >/dev/null 2>&1; then
  tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null || true)"
fi
if [ -z "$tool_name" ]; then
  tool_name="$(printf '%s' "$payload" \
    | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n1 \
    | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' || true)"
fi

# Normalize: server-prefixed names like "TN:orders_put" or "mcp_TN_orders_put".
short_name="${tool_name##*:}"
short_name="${short_name##*_TN_}"

# Write/trade tools that touch a real account. Extend as needed.
case "$short_name" in
  orders_put|orders_delete|orders_set_stop_loss|orders_cancel_all|\
  tariff_select|\
  alerts_add|alerts_delete|\
  quotes_add_list|quotes_add_list_ticker|quotes_delete_list|\
  quotes_delete_list_ticker|quotes_update_list|quotes_make_list_selected|\
  auth_by_login)
    printf '{"permission":"ask","user_message":"Tradernet MCP: «%s» изменяет реальный аккаунт (заявки/списки/сессия). Подтвердите выполнение.","agent_message":"Tool «%s» is a write/trade action on a real Tradernet account; confirm intent and parameters with the user before proceeding."}\n' \
      "$short_name" "$short_name"
    exit 0
    ;;
  *)
    printf '{"permission":"allow"}\n'
    exit 0
    ;;
esac
