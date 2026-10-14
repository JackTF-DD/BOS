# Biodiversity Offset Scheme (BOS)

## Project boundary
This repository supports ad-hoc work across the Biodiversity Offset Scheme's Microsoft Fabric platform, part of DCCEEW. It holds authored Fabric item definitions, notebooks, scripts, and investigation notes. `data/` is reserved for a read-only Git clone of the live Fabric workspace; do not author or publish from that clone. See [`AGENTS.md`](AGENTS.md) for agent boundaries.

## Repository map
| Path | Purpose |
|---|---|
| `metadata/` | Data definitions and mappings, if applicable |
| `notebooks/`, `pipelines/`, `warehouse/` | Authored implementation, if applicable |
| `semantic/`, `reporting/` | Models and reports, if applicable |
| `tests/` | Focused checks |
| `docs/` | Investigation notes, decisions, and runbooks |
| `tasks/` | Work records |
| `data/` | Read-only clone of the live Fabric workspace; exact clone placement and provenance pending |

Remove irrelevant rows/directories; document the actual code layout.

## Working commands
After configuring the `justfile`, document the tested commands here. Git changes do not imply an external deployment.
