---
task: <slug>
owner: <agent-id or name>
status: active        # backlog | active | blocked | review | complete
opened: <YYYY-MM-DD>
base_commit: <sha at task start; omit only before first commit>
---

# <Task title> — BOS

## Objective
One or two sentences: what changes and why.

## Acceptance criteria
- [ ] Observable, checkable outcome.
- [ ] Relevant local test or verification with its exact command.

## Status
What is done, underway, or blocked. Keep current.

## Confirmed facts
Each fact has evidence: a path, a command result, or a commit.
- <fact> [`path/to/file:42`]

## Hypotheses
- <unverified question or belief; delete when resolved>

## Decisions
- <decision> [see docs/decisions/0001-example.md]

## Rejected alternatives
- <approach> because <reason>

## Open questions
1. <question or 'None'>

## Risks and constraints
- <risk or 'None'>

## Checks and evidence
- `<exact command>` — <result and date, or 'not yet run'>.
- External publication/read-back, if separately authorized: <target and evidence or 'not applicable'>.

## Next action
One literal next step; not a list.

## Handoff notes
Only what a fresh session cannot recover from Git or the records above. Leave empty if there is nothing.
