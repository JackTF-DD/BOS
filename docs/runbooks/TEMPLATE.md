# <Repeatable procedure> — BOS

## Purpose and scope
What operation this covers; what it does not authorize.

## Prerequisites
Exact inputs, permissions to operate, and expected local state (avoid embedding mutable IDs).

## Procedure
1. Resolve the current target or source of truth.
2. Execute the smallest safe step with real project commands.
3. Record outputs and preserve the pre-change state if relevant.

## Verification
Specify exact local checks and, for separately authorized external changes, read-back of the affected target.

## Failure and recovery
When to stop, what can be rolled back, and what needs owner approval.

## References
Link to decisions, code, and task records.
