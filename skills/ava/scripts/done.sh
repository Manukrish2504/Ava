#!/bin/bash
# Stop hook: when Claude finishes, Ava says the first sentence of its reply (or just "Done.").
# Stays quiet while Ava is already talking, or when ~/.cache/ava/auto-off exists.
# AVA_DRY_RUN=1 prints the line instead of speaking it.

DATA="$HOME/.cache/ava"
input="$(cat)"
[ -f "$DATA/auto-off" ] && exit 0
[ -f "$DATA/speaking.pid" ] && kill -0 "$(cat "$DATA/speaking.pid")" 2>/dev/null && exit 0

line=""
if command -v jq >/dev/null; then
  [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = true ] && exit 0
  # First non-empty, non-heading line, minus markdown, cut at the end of the first sentence.
  line=$(printf '%s' "$input" | jq -r '.last_assistant_message // ""' |
    awk 'NF && !/^[[:space:]]*#/ { print; exit }' |
    sed -E 's/\[([^]]*)\]\([^)]*\)/\1/g; s/[`*#>|]//g; s/^[[:space:]-]+//; s/([.!?])[[:space:]].*/\1/')
fi
[ -n "$line" ] && [ ${#line} -le 200 ] || line="Done."

if [ -n "${AVA_DRY_RUN:-}" ]; then echo "$line"; else printf '%s' "$line" | "$(dirname "$0")/speak.sh" >/dev/null; fi
