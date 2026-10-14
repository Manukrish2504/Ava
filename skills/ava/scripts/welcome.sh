#!/bin/bash
# SessionStart hook: show the AVA banner once, in the first session after install.
# The marker lives in the plugin's data dir, which uninstall deletes, so a reinstall shows it again.

marker="${CLAUDE_PLUGIN_DATA:-$HOME/.cache/ava}/welcomed"
[ -f "$marker" ] && exit 0
mkdir -p "$(dirname "$marker")" && touch "$marker"

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
msg+='\nAva is installed. She talks back after every task.'
msg+='\nTry it: finish a task, then say \u001b[1mava, explain what you built\u001b[0m'
printf '{"systemMessage": "%s"}\n' "$msg"
