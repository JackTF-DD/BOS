---
task: project-setup
owner: hermes-ops
status: active
opened: 2026-10-15
base_commit: 389729d
---

# Project setup — BOS

## Objective
Tailor the repository template for ad-hoc work across the Biodiversity Offset Scheme's Fabric platform, confirming boundaries and local checks with the owner before changing assumptions.

## Acceptance criteria
- [ ] Project purpose, ownership, source folders, and reference-data boundary are documented.
- [ ] Template placeholders and irrelevant folders are resolved with owner input.
- [ ] `just orient`, `just verify-state`, and a configured `just test` are run; results recorded.

## Status
Identity, purpose, intended authored content, and read-only reference boundary confirmed. Exact authored folder layout, clone placement/provenance, and checks are pending.

## Confirmed facts
- BOS means Biodiversity Offset Scheme, part of DCCEEW; repository is for ad-hoc work across its Fabric platform. [Owner, conversation 2026-10-15]
- Authored work will include Fabric item definitions, notebooks, scripts, and investigation notes; `data/` will hold a Git clone of the live Fabric workspace. [Owner, conversation 2026-10-15]
- `data/` currently contains only a tracked `.gitkeep`, not a clone. [`git ls-files data`; local directory check]
- The repository already has a Git remote and initial commit `389729d`. [`git status --short --branch`; `git log -1`]
- `just orient` and `just verify-state` ran successfully before this record existed; `just test` intentionally fails until configured. [`justfile:16`]

## Hypotheses
- None.

## Decisions
- None yet.

## Rejected alternatives
- None.

## Open questions
1. What is the authored folder layout for Fabric item definitions, notebooks, and scripts?
2. Should the clone be rooted at `data/` or a child of `data/`? What is its provenance and safe refresh procedure?
3. What checks can run locally for this ad-hoc project?
4. Does this project need a dedicated Kanban board or other project-specific runbooks?

## Risks and constraints
- No Fabric deployment or external publication is authorized by repository setup alone.
- Do not infer workspace IDs, live targets, or source provenance from other projects.

## Checks and evidence
- `just orient` — passed before record creation, 2026-10-15.
- `just verify-state` — passed before record creation (no active records), 2026-10-15.
- `just test` — failed intentionally with the unconfigured recipe, 2026-10-15.
- External publication/read-back: not applicable.

## Next action
Confirm authored folder layout and placement of the live-workspace clone with the owner.

## Handoff notes
None.
