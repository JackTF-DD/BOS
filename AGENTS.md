# Agent instructions — BOS

## Project boundary

- Project: Biodiversity Offset Scheme (BOS, `bos`), part of DCCEEW. This repository supports ad-hoc work across its Microsoft Fabric platform. Treat the repository as project-scoped and client-confidential where applicable.
- The editable working copy is `/home/jackfoster/hermes-work/repos/bos`. Resolve the actual checkout/worktree before editing; do not edit a separate mirrored copy.
- Keep authored Fabric item definitions, notebooks, and scripts in repository-owned development folders; keep investigations in `docs/investigations/`. `data/` is a pull-only Git submodule of the live Fabric workspace and is reference-only: read for comparison and verification, never modify, generate into, commit inside, push, or deploy from it. Its provenance, authentication boundary, and refresh procedure are in `docs/runbooks/DATA-SUBMODULE.md`; stage only the parent gitlink for an explicitly requested pinned-revision update.
- Put transient analysis and non-deliverable working files in ignored `.agent/scratch/`. Keep code, tasks, and documentation distinct from snapshots and exports.

## Working method

- Read the relevant task record, documentation, and code before editing. Preserve unrelated work and make focused changes.
- Use the commands actually defined in `justfile`; do not invent test or deployment commands. Run `just orient`, `just verify-state`, and relevant configured checks before claiming completion. If a required check is not available, report that gap rather than claiming it passed.
- Record confirmed facts with paths, command output, or commit evidence; keep hypotheses separate. Review the complete diff as well as test results.
- Use a task branch or isolated worktree for changes when collaborative work requires it. Keep finished changes reviewable; do not push or merge unless requested.
- When delegating, provide the child with task scope, exact context files and paths, boundaries, and verification requirements. Do not assume it inherits this file or conversation history.

## Source and publication boundary

- Authored work belongs in this repository outside `data/`; the live-workspace clone under `data/` is a separate reference input, not the source to edit or publish from. Confirm the final authored folder layout and clone placement before populating them. Do not copy another project's Fabric/submodule rules without checking this project's actual source arrangement.
- Git commits and pushes are not deployments. Any direct external publication or execution requires an explicit request, exact target resolution, a preservation/rollback plan where applicable, and read-back of the affected target before reporting success.
- Avoid changes to shared or live environments as part of ordinary repository tasks. Keep runtime verification and local checks as separate claims.

## Durable records

- Start a work record from `tasks/TEMPLATE.md` in `tasks/active/<slug>.md`; move it to `tasks/completed/` when complete. Use `tasks/backlog/` for unstarted work. Keep status, evidence, blockers, and next action in that record, not in this file.
- For larger work, link a scoped plan in `docs/task-cards/`. Record hard-to-reverse decisions in numbered `docs/decisions/` and update its index. Put repeatable procedures and component contracts in `docs/runbooks/`; link documentation from `docs/INDEX.md`.
- PROJECT_SPECIFIC_RULES: add only stable project constraints and links to relevant runbooks. Remove this placeholder when tailored.
