#!/bin/bash
# Checks the line Ava says after each task (done.sh). Run: ./test.sh
cd "$(dirname "$0")/skills/ava/scripts" || exit 1
export HOME="$(mktemp -d)" # so a real Ava session or auto-off file cannot affect results
fail=0
check() {
  got=$(printf '%s' "$1" | AVA_DRY_RUN=1 ./done.sh)
  [ "$got" = "$2" ] && echo "ok   $2" || { echo "FAIL expected '$2', got '$got'"; fail=1; }
}
check '{"last_assistant_message":"I pushed it, and the repo is **MIT**.\n\n- more"}' 'I pushed it, and the repo is MIT.'
check '{"last_assistant_message":"\n## Summary\nDone. Tests pass."}' 'Done.'
check '{"last_assistant_message":"Pushed to `main`. See [the repo](https://x.y) too."}' 'Pushed to main.'
check '{"last_assistant_message":"- Moved `SKILL.md` to the root! Next."}' 'Moved SKILL.md to the root!'
check '{}' 'Done.'
check "{\"last_assistant_message\":\"$(printf 'word %.0s' {1..60})end.\"}" 'Done.'
check '{"stop_hook_active":true,"last_assistant_message":"Hi."}' ''
exit $fail
