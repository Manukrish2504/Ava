#!/bin/bash
# Speak stdin out loud as Ava, in the background, and return right away.
# Uses the Kokoro neural voice once it's downloaded, macOS `say` until then.
# Settings live in ~/.cache/ava: `speed` (1.0 is normal), `auto-off` (see done.sh).

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
DATA="$HOME/.cache/ava" # ponytail: espeak-ng ignores data paths of 160+ chars, keep this short
UV_VERSION=0.9.24
MODELS=https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0
mkdir -p "$DATA"

text="$(cat)"
[ -n "$text" ] || exit 0
command -v afplay >/dev/null || { echo "Ava: no voice on this system (macOS only), text only."; exit 0; }

# One-time download: uv (if missing), Python packages, and the Kokoro model (~350 MB).
setup() {
  set -e
  trap 'rmdir "$DATA/setup.lock"' EXIT
  uv="$(command -v uv || echo "$DATA/bin/uv")"
  if [ ! -x "$uv" ]; then
    mkdir -p "$DATA/bin"
    curl -fsSL "https://github.com/astral-sh/uv/releases/download/$UV_VERSION/uv-$(uname -m | sed s/arm64/aarch64/)-apple-darwin.tar.gz" |
      tar -xz -C "$DATA/bin" --strip-components 1
  fi
  "$uv" venv -q --allow-existing --python 3.12 "$DATA/venv"
  "$uv" pip install -q --python "$DATA/venv/bin/python" kokoro-onnx==0.6.1
  for f in kokoro-v1.0.onnx voices-v1.0.bin; do
    [ -f "$DATA/$f" ] || { curl -fsSL -o "$DATA/$f.part" "$MODELS/$f" && mv "$DATA/$f.part" "$DATA/$f"; }
  done
  touch "$DATA/ready"
}

"$SCRIPTS/stop.sh" # a new message cuts off the old one
speed="$(cat "$DATA/speed" 2>/dev/null || echo 1.0)"
set -m # each background job gets its own process group, so stop.sh can end all of it

if [ -f "$DATA/ready" ]; then
  (printf '%s' "$text" | "$DATA/venv/bin/python" "$SCRIPTS/kokoro_say.py" "$DATA" "$speed"
    rm -f "$DATA/speaking.pid") >/dev/null 2>&1 </dev/null &
else
  find "$DATA/setup.lock" -maxdepth 0 -mmin +60 -exec rmdir {} \; 2>/dev/null # stale lock
  if mkdir "$DATA/setup.lock" 2>/dev/null; then
    (setup) >"$DATA/setup.log" 2>&1 </dev/null &
    echo "Ava: downloading her Kokoro voice in the background (about 350 MB, one time). Using the macOS voice until it's ready."
  fi
  voice=()
  say -v '?' | grep -q '^Ava (Premium)' && voice=(-v "Ava (Premium)")
  rate=$(awk -v s="$speed" 'BEGIN { printf "%d", 185 * s }')
  (printf '%s' "$text" | say "${voice[@]}" -r "$rate"; rm -f "$DATA/speaking.pid") >/dev/null 2>&1 </dev/null &
fi
echo $! >"$DATA/speaking.pid"
