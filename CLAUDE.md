<!-- begin:framework -->
# Mandate: Centralized Brains (Claude Code)
1. Read the global framework rules from `~/.agent-brains/GLOBAL_AGENT.md`.
2. Read the local workspace directives from `./.agent-brains/AGENT.md`.
3. Use `./.agent-brains/memory/` for project context.
4. Always write plans to `./.agent-brains/plan/` BEFORE writing code.

## Agent-Brains Skill Invocation

When a user invokes a skill by name, resolve it using the [SK] entries in the session
context banner — do NOT use the built-in Skill tool. Resolution paths:
- [SK] global:<id>          -> `~/.agent-brains/skills/<id>/<id>.md`
- [SK] profile(<name>):<id> -> `~/.agent-brains/profiles/<name>/skills/<id>/<id>.md`
- [SK] workspace:<id>       -> `./.agent-brains/skills/<id>/<id>.md`

Read the file and execute its Procedure section. Innermost level wins on ID collision
(workspace > profile > global).

## Automatic Session Start

At the beginning of every session — on the first user message — automatically execute
the session-start skill without waiting to be asked.


## Automatic Skill Routing

When the user's request clearly matches a session workflow, execute the matching framework skill as if
they had typed the explicit `sk-...` token.

Use this v1 routing table:
- First user message in a new session, "start session", "resume work", "pick up where we left off"
  -> `session-start`
- "summarize this session", "what did we do?", "give me a recap"
  -> `session-summary`
- "end session", "close session", "we're done", "continue later", "handover"
  -> `session-end`

Rules:
- Only auto-route when the intent is unambiguous.
- Prefer the least side-effecting skill that satisfies the request.
- Do not route recap-only requests to `session-end`.
- If the user's wording is ambiguous, ask instead of guessing.
- If the user explicitly writes an `sk-*` token, that explicit invocation wins.
<!-- end:framework -->
