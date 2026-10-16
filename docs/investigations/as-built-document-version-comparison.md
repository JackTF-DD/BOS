# As-built document version comparison

**Date:** 2026-10-15  
**Scope:** the four Word artefacts in [`docs/as-built/`](../as-built/README.md)

## Conclusion

### Original / baseline

The content baseline is the untracked-change document:

- `DCCEEW - MS Fabric Data Consolidation Enhancement Project - As Built.docx`

`DCCEEW - MS Fabric Data Consolidation Enhancement Project - As Built (1).docx` is **not a different version**. It is byte-identical (same SHA-256) to that baseline. The unnumbered file has an earlier source and Word core-property modification time (2026-07-07); `(1)` appears to be a later file-system copy of it.

The document's own revision-history table identifies the latest accepted document version as **Ver 1.3**, dated 2026-04-03. This means the unnumbered / `(1)` artefact is the best-supported original baseline for the v1.4 and v1.5 draft comparison. File names and Office metadata alone cannot prove the human workflow that produced it, but the content relationship is unambiguous.

### Do v1.4 and v1.5 form a linear series?

**They are not a clean “accept v1.4, then edit v1.5” sequence.** Both drafts retain their changes as Word tracked markup over almost the same pre-change baseline:

- The v1.4 rejected-change view is 99.7908% similar to the baseline (2,395 versus 2,385 normalized paragraphs).
- The v1.5 rejected-change view is 99.7699% similar to the baseline (2,396 versus 2,385 normalized paragraphs).
- The two rejected-change views are 99.9791% similar. v1.5 adds one baseline-side annotation: `Appropriate respondees`.
- Conversely, v1.5's rejected-change view is only 94.5250% similar to v1.4's accepted-change view. Therefore v1.5 was **not** made by accepting the v1.4 draft and continuing from that accepted result.

**v1.5 is a refinement of the same tracked draft line**, rather than an independently authored divergent branch. On 2026-10-15, Jack Foster confirmed that he updated v1.5 from the provisional v1.4 draft. This confirms the lineage indicated by the OOXML comparison: v1.5 preserves nearly the same review baseline and 618 of v1.4's 620 Word revision IDs, while changing the proposed result. Its accepted-change view is 99.4938% similar to v1.4's accepted-change view (2,564 versus 2,572 normalized paragraphs).

There is therefore **editorial evolution inside the outstanding changes**, not a parallel editing divergence or separately maintained baseline. The confirmed lineage is:

```text
Ver 1.3 accepted baseline
  ├─ As Built / As Built (1)       (identical baseline artefact)
  └─ tracked-draft line
       ├─ v1.4 DRAFT               (proposed update)
       └─ v1.5 DRAFT               (refines proposed update; changes still unaccepted)
```

Do not treat either draft as the authoritative final document until its remaining tracked changes have been reviewed and resolved.

## Material editorial differences from v1.4 to v1.5

In the accepted-change view, v1.5 changes the v1.4 proposal mainly around alerting and pipeline monitoring:

1. Replaces the single-recipient confirmation placeholder with `Appropriate respondees`.
2. States that the pipeline monitoring solution is deployed in both non-production and production.
3. Records one-day Eventstream retention as confirmed sufficient.
4. Replaces a broad “Items to be confirmed” list with two still-outstanding actions: alert recipients and source-controlling `meta.vw_master_pipeline_alert_state`.
5. Rewrites the high-level alerting-flow description.

The v1.4 revision-history addition is itself still tracked. Neither draft adds a final accepted `Ver 1.5` row to the document's revision-history table, so the `v1.5` filename identifies the latest working draft rather than evidence of a completed formal release.

## Evidence table

| Artefact | SHA-256 relationship | Word tracked revisions | Textual relationship |
| --- | --- | ---: | --- |
| `As Built` | Baseline hash `d213…82ed` | 0 | Baseline / latest accepted content (internal table: Ver 1.3) |
| `As Built (1)` | Exactly equal to `As Built` | 0 | Duplicate file, not a separate version |
| `v1.4 DRAFT` | Different file | 620 (517 insertions, 103 deletions) | Proposed update over the baseline |
| `v1.5 DRAFT` | Different file | 656 (520 insertions, 136 deletions) | Refined proposed update over almost the same baseline |

Revision records in both drafts are predominantly attributed to `Claude (AI draft)` (616 in v1.4; 652 in v1.5), with four attributed to Jack Foster in each. Their recorded revision dates are 2026-09-07; v1.5's file/package modification time is 2026-09-08. This is consistent with a copied-and-refined tracked draft, but it is not a substitute for a source-control history.

## Method and limits

The comparison used a read-only standard-library OOXML inspection of each `.docx` package:

- verified ZIP/package integrity and compared SHA-256 hashes;
- extracted core properties and `w:ins` / `w:del` records from Word document headers, footers, and main document parts;
- generated normalized paragraph text in two views: **accepted** (insertions kept, deletions removed) and **rejected** (insertions removed, deletions kept);
- compared these views with a sequence matcher and unified diffs.

This comparison assesses textual/revision lineage. It does not validate rendered layout, embedded images, comments, format-only changes, moves, or an external version-control history.

The reproducible local analysis output is transient and intentionally ignored: `.agent/scratch/as-built-version-comparison.json`.
