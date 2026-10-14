---
task: <slug>
owner: <name or unassigned>
status: backlog
opened: <YYYY-MM-DD>
---

# Task card: <outcome> — BOS

**Work record:** [`tasks/backlog/<slug>.md`](../../tasks/backlog/<slug>.md) (update path when moved).  
**Repository:** `/home/jackfoster/hermes-work/repos/bos` (resolve current worktree before editing).

## Outcome
Describe the observable result and why it matters. State explicitly what is outside scope.

## Start here: evidence and boundaries
- Read `AGENTS.md`, the linked work record, relevant runbooks, and existing implementation.
- Distinguish verified facts from assumptions. Name source-of-truth paths and any read-only reference inputs.
- External publication or execution is not authorized by this card alone.

## Work breakdown
1. Inspect current behavior and record evidence.
2. Make a focused change on an isolated branch/worktree when needed.
3. Run focused and repository checks; review diff.
4. Update the work record with results and next action.

## Acceptance criteria
- [ ] Outcome has a concrete verification method.
- [ ] No unrelated paths changed; reference-only inputs remained unchanged.
- [ ] Local checks and limitations recorded accurately.
- [ ] Any external change was separately requested and read back.

## Decisions or blockers requiring owner input
- <question or 'None'>

## Handoff
Link the live work record. Do not duplicate its evolving status here.
