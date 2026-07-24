# Global Claude Instructions

## Knowledgebase

A knowledgebase MCP server (`knowledgebase`) is available in every session. Its contents are
injected into future session prompts. Save things that would let a future session start working
immediately — without extra turns to investigate, read files, or reconstruct context. If Claude
could figure it out in one tool call, don't save it.

### Save proactively during sessions

Call `kb_add_entry` without being asked when the answer is yes to any of these:

- Would a future Claude need multiple tool calls to reconstruct this context?
- Does this prevent going down a wrong path that looked reasonable?
- Is this a decision that constrains future choices (so Claude doesn't re-propose rejected approaches)?
- Is this a gotcha or deviation from documented behavior that would cause wasted investigation?
- Does this point to the right entry file, module, or pattern for a given type of work in this project?

Use the project name matching the current working directory (e.g. `basename $PWD`).
Choose the most specific type: `finding`, `decision`, `understanding`, `idea`,
`context`, `question`, or `note`.

### At the end of a meaningful session

Before closing, ask: what would a future Claude get wrong, or waste turns figuring out, without
this context? Save those things. Don't summarize the session — save the insights. Prefer specific,
self-contained entries over long summaries — one entry per distinct idea is better than one entry
covering everything.

### Do not save

- Anything answerable by reading a single file (file paths, config values, package names, import paths)
- Confirmations that something works as expected/documented — only the surprising part is worth saving
- Step-by-step setup sequences that belong in a README, not a KB entry
- Context that `git log` or `git blame` would surface in one command
- Trivial exchanges or clarifying questions with obvious answers
- Entries that duplicate what is already in the knowledgebase

**Rule of thumb:** A good KB entry answers "what would Claude need to know to skip a turn?" —
not "what did we do?" or "what exists?"

## Coding preferences

### JavaScript / TypeScript

- No single-line `if` statements — always use curly braces
- Return statements always on their own line, never inline

## General

- Keep responses concise; avoid trailing summaries of what you just did
