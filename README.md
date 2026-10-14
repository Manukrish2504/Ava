# Ava

```
 █████╗ ██╗   ██╗ █████╗
██╔══██╗██║   ██║██╔══██╗
███████║██║   ██║███████║
██╔══██║╚██╗ ██╔╝██╔══██║
██║  ██║ ╚████╔╝ ██║  ██║
╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝
```

A [Claude Code](https://code.claude.com) plugin that talks back.

When Claude finishes building something, ask Ava. She writes a clear debrief in the chat, then says the short version out loud in a natural voice, so you can hear what happened without reading a wall of terminal output. She also says one line on her own after every task.

[![Ava demo: click to watch with sound](assets/demo.png)](assets/demo.mp4)

▶️ [Watch the demo (sound on)](assets/demo.mp4). It shows an example session.

## Install

In Claude Code:

```
/plugin install ava --marketplace Manukrish2504/Ava
```

On older Claude Code versions, run this instead:

```
/plugin marketplace add Manukrish2504/Ava
/plugin install ava@ava
```

Start a new Claude Code session and Ava greets you with her banner (once, in color). The first time she speaks, she downloads her voice in the background (about 470 MB, one time, into `~/.cache/ava`). Until it's ready she uses the built-in macOS voice, so she's never silent.

## Her voice

Ava speaks with [Kokoro](https://github.com/thewh1teagle/kokoro-onnx), an open-source neural voice that runs entirely on your Mac. No account, no API key, and nothing leaves your machine. She sounds far more human than the built-in macOS voices.

The first time she speaks, a script sets everything up by itself:

1. It uses [uv](https://github.com/astral-sh/uv) to install Python 3.12 and the Kokoro package. If you don't have uv, it downloads a private copy into `~/.cache/ava`.
2. It downloads the Kokoro model from its GitHub release.

## How to use it

Once Claude has finished a task, just ask.

### Explain what was built

```
> ava, explain what you built
```

In the chat:

```
What it does
  Adds CSV export to the reports page. Click Export and
  the report you are viewing downloads as a .csv file.

Try it
  npm run dev  ->  open /reports  ->  click Export

What changed
  src/reports/export.ts    builds the CSV
  src/reports/Page.tsx     adds the Export button
  tests/export.test.ts     3 new tests

Watch out
  Very large reports are built in memory.
```

Out loud:

> 🔊 "CSV export is done. The reports page has a new Export button, and it downloads the report you're looking at as a CSV file. I added the export logic, the button, and three tests, and they all pass. One thing to watch: very large reports are built in memory, so they could get slow."

### Recap everything that ran

```
> ava, tell me everything you ran
```

In the chat:

```
1. npm install papaparse     added 1 package
2. npm test                  2 failed in export.test.ts
     Expected "a,b,c" but received "a;b;c"
3. Fixed the delimiter in src/reports/export.ts
4. npm test                  14 passed, 0 failed
5. npm run lint              no problems

Now: feature done, all tests green, nothing committed.
```

Out loud:

> 🔊 "Here's the run. I installed one package for writing CSV files. The first test run had two failures, because I used semicolons instead of commas. I fixed the delimiter, and the second run passed, all fourteen tests. Lint came back clean. The feature is done, and nothing is committed yet."

### Ask for one slice

```
> ava, just the errors
> ava, only the test results
> ava, what did the build print?
```

### After every task, without asking

When Claude finishes any task, Ava reads out the first sentence of its reply:

> 🔊 "CSV export is ready, and all fourteen tests pass."

She skips it while she's already talking, so she never talks over a debrief.

```
> ava, auto off          stop the after-task line
> ava, auto on           bring it back
```

### Control her

| Say | What happens |
| --- | --- |
| `ava, stop` | She stops mid-sentence. |
| `ava, talk faster` / `ava, talk slower` | Changes her speed and remembers it. |
| `..., text only` | Debrief in the chat only, no voice. |

She talks in the background, so you can keep typing while she speaks. A new message cuts off the old one.

## Phrases that trigger Ava

You don't have to say "ava". Any of these work after a task:

- "explain what you built"
- "talk me through it"
- "what did you just do?"
- "tell me what happened in the terminal"
- "read me the output"
- "recap the session"

## How it works

```
skills/ava/SKILL.md            what Ava says and how she says it
skills/ava/scripts/speak.sh    speaks text in the background (Kokoro, or macOS say until it's ready)
skills/ava/scripts/stop.sh     stops her mid-sentence
skills/ava/scripts/done.sh     the after-task line, run by a Stop hook
skills/ava/scripts/welcome.sh  the banner, shown once by a SessionStart hook
hooks/hooks.json               registers both hooks
```

The skill tells Claude to:

1. **Pick a mode.** *Explain* covers what the feature does, how to try it, what changed, and what to watch out for. *Recap* walks through every command in order, with the output that matters.
2. **Use evidence.** Ava reports from what actually happened, and checks `git status` and `git diff` when Claude's memory of the session is thin. Failed tests and skipped steps get reported, not hidden.
3. **Write the full details in the chat.**
4. **Speak a short version written for the ear:** the result first, contractions, no lists, no code or file paths, and punctuation placed where a person would breathe.

Kokoro generates one sentence while the previous one plays, so she starts talking in under a second.

Settings live in `~/.cache/ava`. `speed` holds her speed (1.0 is normal), and an `auto-off` file turns off the after-task line.

## Requirements and limits

- macOS for the voice. On other systems Ava still writes the debrief, just silently.
- Claude Code with plugin support.
- Ava only knows about commands Claude ran, plus ones you run inside Claude Code with `!`. She can't see output from your other terminal windows. Paste it in, or rerun the command with `!`.

## Uninstall

```
/plugin uninstall ava@ava
rm -rf ~/.cache/ava
```

## Development

`./test.sh` checks the line Ava picks after each task.

## License

[MIT](LICENSE)
