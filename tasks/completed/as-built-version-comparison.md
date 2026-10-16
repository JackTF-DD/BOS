---
task: as-built-version-comparison
owner: daily-driver
status: complete
opened: 2026-10-15
base_commit: dda38ba5e786bcc778e8d287ecec1ae104cd29dd
---

# Compare versioned as-built documents — BOS

## Objective
Determine the original source artefact among the imported as-built documents and whether the v1.4 and v1.5 drafts form a linear revision sequence or show divergent editing.

## Acceptance criteria
- [x] Establish byte identity, source/document metadata, and tracked-revision metadata for all four imported files.
- [x] Compare accepted and rejected textual views of the base, v1.4, and v1.5 documents.
- [x] Record a reproducible evidence-based conclusion in `docs/investigations/` and link it from `docs/INDEX.md`.
- [x] Run relevant repository state checks and `git diff --check`.

## Status
Analysis is complete. The unnumbered and `(1)` documents are byte-identical baseline copies; v1.5 refines the same outstanding tracked-change line as v1.4 rather than following an accepted v1.4 release.

## Confirmed facts
- `As Built` and `As Built (1)` have the same SHA-256 hash. [`docs/as-built/README.md`]
- v1.4 and v1.5 retain Word tracked changes. [`docs/as-built/README.md`]

## Hypotheses
- None.

## Decisions
- Compare both accepted and rejected revision views because a draft's visible text alone cannot establish its edit baseline.

## Rejected alternatives
- Treating filename order alone as proof of revision lineage, because Word documents can be copied, renamed, or edited in parallel.

## Open questions
1. None.

## Risks and constraints
- OOXML comparisons are evidence of content lineage, not an authoritative revision-control history.

## Checks and evidence
- `.agent/scratch/compare_asbuilt.py` — extracted OOXML metadata, revision records, accepted/rejected normalized text views, and comparison metrics on 2026-10-15.
- `docs/investigations/as-built-document-version-comparison.md` — recorded evidence, conclusion, method, and limits on 2026-10-15.
- `just orient && just verify-state` — passed on 2026-10-15.
- `git diff --check` — passed on 2026-10-15.
- External publication/read-back — not applicable.

## Next action
None; ready for review and commit when the surrounding working tree is ready.

## Handoff notes
