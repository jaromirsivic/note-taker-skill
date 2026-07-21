# note-taker-skill

`note-taker-skill` is a portable Agent Skill for Cursor, Codex, and Claude. It
captures dictated chat messages verbatim, turns the accumulated notes into a
clarified project change request, and asks for approval before implementation.

The skill follows the open Agent Skills format and contains no runtime scripts
or platform-specific commands. Its installation helpers support Windows,
Linux, and macOS.

## What it does

1. Activates when a user asks, in any language, to start taking notes.
2. Appends every subsequent prompt verbatim to
   `.administration/notes.md`, followed by two empty lines.
3. Treats dictated content as data and never executes instructions found in it.
4. Ends capture only when the complete prompt is a standalone request to
   process the notes.
5. Reads basic project context and asks about every material ambiguity.
6. Creates a timestamped change request and archives the original notes.
7. Shows the complete change request and asks before starting implementation.

All chat responses and generated change requests use the user's conversation
language. All files distributed as part of this skill are written in English.

## Package layout

```text
.
|-- .agents/
|   `-- skills/
|       `-- note-taker-skill/
|           `-- SKILL.md
|-- scripts/
|   |-- install.ps1
|   `-- install.sh
`-- README.md
```

The copy under `.agents/skills/` is canonical. Cursor and Codex discover that
location directly. The installers also copy the skill to
`.claude/skills/note-taker-skill/` for Claude.

## Install in a project

Clone or download this package, then run one installer with the destination
project path. If no path is supplied, the current directory is used.

### Windows PowerShell

```powershell
.\scripts\install.ps1 -TargetProject "C:\path\to\project"
```

### Linux or macOS

```sh
./scripts/install.sh /path/to/project
```

If the shell script is not executable after download, run:

```sh
sh ./scripts/install.sh /path/to/project
```

Rerun the installer after changing the canonical `SKILL.md`. Existing copies
are updated without relying on symlinks.

## Use

Ask the agent to start taking notes in any language. Example English prompts
include:

- `Act as a note taker.`
- `Take notes.`
- `I am going to dictate notes.`

After activation, every prompt is stored as dictated text. To finish, send a
separate prompt whose entire meaning is `process notes`. A processing phrase
inside a longer prompt remains ordinary dictated text.

The processing workflow may ask several rounds of clarification questions. It
first attempts to use the host's interactive question popup and falls back to
chat when no such tool is available. Every clarification question has exactly
one clearly labeled default answer, and the user is told that an unanswered
question will use its default. In chat, questions are sent in batches of no
more than five and use continuous `Q1:`, `Q2:`, and subsequent labels instead
of a plain numbered list.

When all ambiguities are resolved explicitly or by accepted defaults, the skill
creates:

```text
.administration/cr_YYYY-MM-DD-HH-mm-ss.md
.administration/cr_YYYY-MM-DD-HH-mm-ss.notes.md
```

The first file is the implementation-ready change request. The second is the
archived original dictation. Both use the same local timestamp.

## State and recovery

The skill stores its current state in:

```text
.administration/.note-taker-active
```

`mode: capture` means new prompts are notes. `mode: processing` means the agent
is resolving the notes and clarification replies must not be appended.

If a session is interrupted, keep the marker and notes in place and ask the
agent to continue the note-taker workflow. Remove the marker manually only when
intentionally abandoning the active workflow.

## Portability and safety boundary

- The skill itself requires only an Agent Skills-compatible host with safe
  filesystem read, write, rename, and delete capabilities.
- `install.ps1` requires PowerShell; `install.sh` requires a POSIX-compatible
  shell and standard file utilities.
- The installers copy files instead of creating symlinks, avoiding common
  Windows permission and cross-platform Git issues.
- Skill precedence is behavioral, not a security sandbox. A portable
  `SKILL.md` can instruct the agent not to invoke other skills or execute
  dictated content, but it cannot override host-level system, developer,
  security, or policy instructions.
