"""Speak stdin in Ava's Kokoro voice. Usage: kokoro_say.py <data dir> <speed>.

Synthesizes one sentence while the previous one plays, so she starts talking in under a second.
"""
import re
import subprocess
import sys
import wave

import numpy as np
from kokoro_onnx import Kokoro

data, speed = sys.argv[1], min(max(float(sys.argv[2]), 0.5), 2.0)
kokoro = Kokoro(f"{data}/kokoro-v1.0.onnx", f"{data}/voices-v1.0.bin")
# Split after a lowercase letter or digit, so acronyms like "U.S." don't break a sentence.
sentences = [s for s in re.split(r"(?<=[a-z0-9][.!?])\s+", sys.stdin.read().strip()) if s]

player = None
for i, sentence in enumerate(sentences):
    samples, rate = kokoro.create(sentence, voice="af_heart", speed=speed, lang="en-us")
    path = f"{data}/say{i % 2}.wav"  # two files: one playing, one being written
    with wave.open(path, "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        out.writeframes((np.clip(samples, -1, 1) * 32767).astype(np.int16).tobytes())
    if player:
        player.wait()
    player = subprocess.Popen(["afplay", path])
if player:
    player.wait()
