#!/bin/bash
# Stop Ava mid-sentence: end the whole process group speak.sh started.
pid_file="$HOME/.cache/ava/speaking.pid"
[ -f "$pid_file" ] && kill -- -"$(cat "$pid_file")" 2>/dev/null
rm -f "$pid_file"
exit 0
