#!/bin/bash
# SessionStart hook: show the AVA banner at the start of every new session.

# Built as a JSON string: \n and \u001b stay escaped. Keep double quotes and backslashes out of the text.
rows=(
  ' █████╗ ██╗   ██╗ █████╗'
  '██╔══██╗██║   ██║██╔══██╗'
  '███████║██║   ██║███████║'
  '██╔══██║╚██╗ ██╔╝██╔══██║'
  '██║  ██║ ╚████╔╝ ██║  ██║'
  '╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝'
)
colors=(141 177 213 212 211 210) # lavender fading to coral, one per row
msg='\n'
for i in "${!rows[@]}"; do msg+="\\u001b[38;5;${colors[$i]}m${rows[$i]}\\u001b[0m\\n"; done
printf '{"systemMessage": "%s"}\n' "$msg"
