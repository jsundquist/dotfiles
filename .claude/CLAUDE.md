# Global Claude Instructions

## Knowledgebase

A knowledgebase MCP server (`knowledgebase`) is available in every session. Use it to
persist discoveries across sessions so future work starts with full context.

### Save proactively during sessions

Call `kb_add_entry` without being asked when you encounter any of the following:

- A non-obvious architectural decision or constraint in the codebase
- A bug root cause or a fix that required understanding subtle behavior
- A pattern, convention, or naming scheme specific to the project
- An external dependency quirk worth remembering
- An open question or known TODO that isn't tracked elsewhere
- A user preference or style rule that applied during the session

Use the project name matching the current working directory (e.g. `basename $PWD`).
Choose the most specific type: `finding`, `decision`, `understanding`, `idea`,
`context`, `question`, or `note`.

### At the end of a meaningful session

If files were edited, bugs were fixed, or significant decisions were made, do a
final sweep and save anything not yet captured. Prefer specific, self-contained
entries over long summaries — one entry per distinct idea is better than one
entry covering everything.

### Do not save

- Trivial exchanges or clarifying questions with obvious answers
- Information already derivable from reading the code or git history
- Entries that duplicate what is already in the knowledgebase

## Coding preferences

### JavaScript / TypeScript

- No single-line `if` statements — always use curly braces
- Return statements always on their own line, never inline

## General

- Keep responses concise; avoid trailing summaries of what you just did
