# Project repository template

A copyable starting point distilled from the repository conventions in `redp2` and `saa2`. This is a template, **not** a client project or a Fabric export. Do not copy their project-specific identities, workspace IDs, notebook rules, or history.

## Create a project

From this template directory:

```bash
./scripts/create-project.sh /home/jackfoster/hermes-work/repos/<project-slug>
cd /home/jackfoster/hermes-work/repos/<project-slug>
```

The script refuses an existing destination by default. To seed an **existing Git repository that has no commits and contains only `.git/`**, use `./scripts/create-project.sh --existing-empty-git /absolute/path/to/repo`; it refuses repositories with any other files. It copies the template without its Git history and leaves placeholders for review. It does **not** create a Kanban board, Git remote, deployment connection, or commit. A manual copy is also fine, but preserve hidden files and empty directories.

Before doing project work:

1. Replace every `PROJECT_*` placeholder in `AGENTS.md`, `README.md`, `tasks/TEMPLATE.md`, and the documentation templates. Use `rg 'PROJECT_[A-Z_]+' .` (or an equivalent search) to find them. Review all copied text for irrelevant assumptions.
2. Tailor `AGENTS.md` to the project: client/scope, editable repo, read-only reference data, authorized working folders, verification commands, deployment boundary, and any project-specific runbooks. Keep it short; put evolving status in task records, not the rules file. If you use a `CLAUDE.md`, keep it consistent with `AGENTS.md` instead of copying another project's file.
3. Decide which source folders are actually needed. Remove irrelevant empty placeholders (`semantic/`, `reporting/`, etc.) and add suitable code folders. If `data/` contains reference material, document whether it is a snapshot, submodule, or another source; **do not assume** REDP's submodule procedure applies to another project.
4. Edit `justfile` with **real, locally runnable** `test` and other commands. The initial `test` target deliberately fails until configured. Update `AGENTS.md` to match the actual command contract.
5. Fill `docs/INDEX.md`, start `docs/decisions/INDEX.md`, and document project-specific procedures in `docs/runbooks/`. Create work records from `tasks/TEMPLATE.md`; use `docs/task-cards/TEMPLATE.md` only when a detailed scoped plan is useful. Keep cards and live work records distinct and linked.
6. Run `just orient`, `just verify-state`, and your configured `just test`. Create a Git repository and remote only if the project requires them, then review the initial diff before committing. Do not treat Git activity as deployment.

## Layout

| Path | Purpose |
|---|---|
| `AGENTS.md` | Stable, project-wide agent boundaries and working method |
| `justfile`, `scripts/` | Explicit local commands and small repeatable helpers |
| `tasks/TEMPLATE.md`, `tasks/{backlog,active,completed}/` | Work records with status and evidence |
| `docs/task-cards/` | Optional, detailed task plans linked to work records |
| `docs/decisions/` | Hard-to-reverse decisions and index |
| `docs/runbooks/`, `docs/investigations/`, `docs/templates/` | Repeatable procedures, findings, and document templates |
| `metadata/`, `notebooks/`, `pipelines/`, `warehouse/`, `semantic/`, `reporting/` | Example authored-source folders; adapt to the project |
| `tests/` | Focused verification and regression tests |
| `data/` | Optional read-only reference boundary; remove if irrelevant |
| `.agent/scratch/`, `.agent/logs/`, `.worktrees/` | Ignored local state and temporary worktrees |

## Provenance

Patterned on `saa2/AGENTS.md`, `saa2/tasks/TEMPLATE.md`, `saa2/docs/INDEX.md`, `saa2/docs/task-cards/`, and `redp2/README.md` plus `redp2/AGENTS.md`. Examples are conventions, not automatic policy for a new project.
