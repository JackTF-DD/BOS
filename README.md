# BOS

## Project boundary
Describe the purpose, ownership, reference-only data, and where authored work belongs. Link `AGENTS.md` for agent boundaries.

## Repository map
| Path | Purpose |
|---|---|
| `metadata/` | Data definitions and mappings, if applicable |
| `notebooks/`, `pipelines/`, `warehouse/` | Authored implementation, if applicable |
| `semantic/`, `reporting/` | Models and reports, if applicable |
| `tests/` | Focused checks |
| `docs/` | Decisions, investigations, and runbooks |
| `tasks/` | Work records |
| `data/` | Read-only reference inputs, if applicable |

Remove irrelevant rows/directories; document the actual code layout.

## Working commands
After configuring the `justfile`, document the tested commands here. Git changes do not imply an external deployment.
