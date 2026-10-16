---
task: bamc-json-ingestion-validation
owner: unassigned
status: active
opened: 2026-10-15
---

# Task card: document and validate BAMC JSON ingestion — BOS

**Work record:** [`tasks/active/bamc-json-ingestion-validation.md`](../../tasks/active/bamc-json-ingestion-validation.md).  
**Repository:** `/home/jackfoster/hermes-work/repos/bos` (resolve the current worktree before editing).

## Outcome
Produce and execute a defensible validation plan for the existing BAMC JSON replacement route: source SQL table → Bronze JSON landing → JSON split → Silver child tables → Gold stored procedures → Gold reconstruction/reporting views. The output is a legacy-cohort-scoped evidence record and documented conclusion, not a pipeline redesign or a direct publication.

The retired Gold table is a **stale regression reference**, not the source of truth. It can establish parity over its known historical overlap; it must not be used to require exact current row counts or to reject newer rows produced by the replacement route.

## Start here: evidence and boundaries
- Read `AGENTS.md`, the linked work record, the source mapping and BAMC control exports under `metadata/source/`, and the evidence paths recorded below.
- `data/` is a read-only workspace-mirror submodule at reviewed revision `74be42c8318ba1580074ee848936f4f5e5c77a91`; do not edit, generate files into, commit inside, push, or deploy from it.
- The current design trace is:
  1. `P_BAMC_Ingestion_Master` invokes Bronze, ordinary Silver, JSON Silver, then Gold. [`data/Fabric/&#32;P_BAMC_Ingestion_Master.DataPipeline/pipeline-content.json:44-215`]
  2. `P_BAMCIngestion_TopLevel` → `L_BAMCIngestion_MiddleLevel` → `L_BAMCIngestion_BottomLevel` selects enabled BAMC control rows and switches by `dataLoadingBehavior`. [`data/Fabric/01 Bronze/01 Pipelines/P_BAMCIngestion_TopLevel.DataPipeline/pipeline-content.json:45-106`; `data/Fabric/01 Bronze/01 Pipelines/03 Pipeline Modules/L_BAMCIngestion_MiddleLevel.DataPipeline/pipeline-content.json:5-93`]
  3. The `JsonDeltaLoad` row extracts `ID` and `VegzoneDataJson`, lands a batch JSON file, invokes `N_BAMC_Constraints_json`, then advances its watermark. [`metadata/source/BAMCMainControlTable.csv`; `data/Fabric/01 Bronze/01 Pipelines/03 Pipeline Modules/L_BAMCIngestion_BottomLevel.DataPipeline/pipeline-content.json:474-770`]
  4. The constraints notebook classifies source rows as predicted, candidate, blank, or invalid; writes predicted/candidate JSON only; and fails on an unrecognised nonblank shape. [`data/Fabric/01 Bronze/01 Pipelines/02 Notebooks/N_BAMC_Constraints_json.Notebook/notebook-content.py:25-68`, `:277-348`, `:507-539`, `:562-730`]
  5. `N_BronzeToSilver` maps those outputs to four Silver child tables, and `N_TSQLSilverToGold_BAMC` runs the four corresponding Gold procedures. [`metadata/source/SourceToTargetMappingNonProd(BronzeToSilver).csv`; `data/Fabric/03 Gold/01 Pipelines/02 Notebooks/N_TSQLSilverToGold_BAMC.Notebook/notebook-content.sql:675-727`]
- The provisional workbook [`BOS-52 Docs & Testing Plan.xlsx`](BOS-52%20Docs%20%26%20Testing%20Plan.xlsx) provides the original legacy-versus-view queries and a description of the intended reporting replacement. The stale baseline is confirmed to remain available as `BiodiversityCalDBBAMC.tblAssessmentHabitatConstraints` in both Silver and Gold; the workbook's statement that it was deleted is historical/documentation drift.
- Live Bronze metadata confirms that `tblAssessmentHabitatConstraints` has the legacy constraint fields, and identifies two additional plausible legacy comparisons: `tblAssessmentHabitatConfirmation` and `tblAssessmentHabitatValues`. Field resemblance alone is not evidence of supersession; each must be proved or rejected through schema/grain and value-level comparison.
- Current Gold view definitions establish the actual reporting dependency boundary: `vw_tblAssessmentHabitatConstraints` reconstructs constraints from the two JSON-derived constraint tables; `vw_BAMC_Habitat_Predicted` consumes that reconstruction but still joins direct `tblAssessmentHabitatConfirmation`; `vw_BAMC_Habitat_Candidate` still joins direct `tblAssessmentHabitatConstraints`, `tblAssessmentHabitatConfirmation`, and `tblAssessmentHabitatValues`. Neither reporting view consumes the JSON-derived `...PredictedPresence` or `...CandidateApplicableVegZones` tables. [Owner-provided Gold view definitions, 2026-10-15]
- Owner-run live freshness/control checks show the three direct legacy Bronze tables are not current: their latest source changes are 2026-06-05 and their latest batches are `202606162110010000`; all three related control rows retain initial watermarks and null `RunTimeUTC`. [Owner query results, 2026-10-15]
- Do not infer present live-workspace behaviour from the mirror or these local exports. Any publication, run, or live validation needs explicit authorization and exact read-back.

## Validation plan

### 1. Inventory possible legacy-table supersession, then define the comparable contract
Do **not** use `BatchId` as the regression join: it stamps independent incremental loads that ran at different times. Instead, define the cohort from the stale legacy table—normally all retained legacy rows, with optional stratified subsets by `AssessmentID`/business category for investigation.

The JSON splitter emits only four child outputs. Start with this evidence-based supersession inventory:

| JSON child output | Strong/possible legacy comparison | Initial rationale | Required proof |
|---|---|---|---|
| `ConstraintsWithVegZone` and `Constraints` | `tblAssessmentHabitatConstraints` | Both variants carry `Selected` and `Data`; predicted also carries a vegzone. `vw_tblAssessmentHabitatConstraints` uses exactly these two JSON-derived tables plus suitability. | **Confirmed reconstruction path.** Confirm parity at the defined business grain. Note that only the predicted reporting view consumes the reconstruction today; the candidate reporting view still uses the legacy table. |
| `Presence` | `tblAssessmentHabitatConfirmation` | `Name`/`IsPresent` resemble legacy `VegzoneName`/`Confirmed`, but the JSON mapping targets only `tblAssessmentHabitatSuitabilityPredictedPresence`. | **Not a replacement in the inspected reporting views.** Both current reporting views still use direct `tblAssessmentHabitatConfirmation`. Retain as an additional/unconsumed JSON grain unless another consumer is identified. |
| `ApplicableVegZones` | `tblAssessmentHabitatValues` | `Name`, `IsChecked`, `IsCompleteLossChecked`, and `AreaForVegZone` resemble `VegZoneName`, `IsChecked`, `CompleteLoss`, and `Value`, but the JSON mapping targets only `tblAssessmentHabitatSuitabilityCandidateApplicableVegZones`. | **Rejected for this contract.** In a 1,000-row live-schema sample, all JSON parent IDs equal a legacy `Id`, but zero share the same assessment, unit of measure, or vegzone and only six share species. The numeric ID equality is not lineage; do not recreate values from this child. |
| all four outputs | any other Bronze table | No current structural evidence. | Do not add candidates solely from similar naming; require a field/grain/value relationship or downstream-consumer dependency. |

Run [`bamc-json-legacy-field-correspondence.sql`](../investigations/bamc-json-legacy-field-correspondence.sql) in the FLH_Silver SQL endpoint before proposing any recreation. The 1,000-row sample supports the presence-to-confirmation contract. The paired-row values diagnostic rejects the candidate applicable-veg-zone-to-values contract: ID equality is not sufficient evidence of lineage. Run a full reconciliation only after a sampled result supports the particular contract.

The current SQL endpoint uses longer live key names than the repository mapping export. Use [`bamc-habitat-values-json-probe.sql`](../investigations/bamc-habitat-values-json-probe.sql) for a fresh field-by-field test based on the observed live `tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey` and `tblAssessmentHabitatSuitabilityKey` naming before treating the prior values conclusion as final.

Before comparison, profile the schemas and grain of:
- Silver legacy `BiodiversityCalDBBAMC.tblAssessmentHabitatConstraints`;
- Silver/Bronze legacy `tblAssessmentHabitatConfirmation` and `tblAssessmentHabitatValues`;
- Silver replacement child tables and `tblAssessmentHabitatSuitability`;
- Gold legacy `BiodiversityCalDBBAMC.tblAssessmentHabitatConstraints`;
- Gold replacement `vw_tblAssessmentHabitatConstraints` and the two downstream reporting views.

Create a field crosswalk and a supersession disposition (`confirmed replacement`, `not a replacement`, or `unresolved`) for each candidate. The provisional workbook proposes `AssessmentID`, `ConstraintType`, `HabitatConstraint`, `Selected`, `SpeciesID`, and `VegzoneName` for constraints; confirm those names/types and whether this tuple is unique before using it as a logical row identity.

### 2. Establish the stale baseline and scope its limitations
Record legacy-table row count, distinct assessment count, available source/load timestamps, null profile, and duplicate groups at the agreed logical grain. If the table has no defensible timestamp, label it an **unknown-date stale snapshot** rather than inventing a cutoff.

Use [`bamc-legacy-table-freshness.sql`](../investigations/bamc-legacy-table-freshness.sql) in the FLH_Bronze SQL endpoint and [`bamc-legacy-table-control-status.sql`](../investigations/bamc-legacy-table-control-status.sql) in `FDWH_IngestionControlStore` to check whether the three direct legacy routes remain current and have successful control status/watermarks.

The comparison question is: *for the population that survived in the stale table, does the replacement derive the same logical constraint records?* It is not: *do the old and new current states have equal row counts?*

### 3. Validate raw extraction and Bronze landing
Use completed runs only as operational evidence that the route executes; do not attempt to join their `BatchId` to the old snapshot. For representative recent runs:
- confirm the control row entered the `JsonDeltaLoad` route and capture the exact SQL watermark interval;
- count source records selected from `tblAssessmentHabitatSuitability` and record `ID` coverage, without exporting business values;
- verify the raw file exists at `Files/BiodiversityCalDBBAMCJsonDeltaLoad/tblAssessmentHabitatSuitability/<yyyy/MM/dd/HH>/...` and has the selected `BatchId`;
- read the file with the same `multiline=true` contract used downstream and count root rows, distinct non-null `ID`s, null IDs, and blank/nonblank `VegzoneDataJson` values.

**Pass:** selected source count, landed root count, and distinct ID coverage reconcile after any documented source-query semantics.

### 4. Validate split semantics
For one or more representative recent landed files, classify root rows as predicted (A), candidate (B), blank, or invalid using the notebook's documented discriminator. Reconcile:

```text
root rows = predicted rows + candidate rows + blank rows + invalid rows
```

Require `invalid rows = 0` for a successful batch. Verify both output directories' `_SUCCESS` marker and JSON-array part-file contract. For each nonblank variant, compare source nested-element counts to output element counts by parent `ID`; do not expect a root-row count to equal a child-row count.

### 5. Validate Silver replacement tables and merge behaviour
For the legacy comparison cohort, query the current Silver replacement tables and capture:

| Source output | Silver target | Key |
|---|---|---|
| predicted / `ConstraintsWithVegZone` | `tblAssessmentHabitatSuitabilityPredictedConstraintsWithVegZone` | `ConstraintWithVegZoneKey` |
| predicted / `Presence` | `tblAssessmentHabitatSuitabilityPredictedPresence` | `PresenceKey` |
| candidate / `Constraints` | `tblAssessmentHabitatSuitabilityCandidateConstraints` | `ConstraintKey` |
| candidate / `ApplicableVegZones` | `tblAssessmentHabitatSuitabilityCandidateApplicableVegZones` | `ApplicableVegZoneKey` |

For each target, record cohort row count, non-null key count, distinct key count, duplicate-key groups, orphan/null parent IDs, and its contribution to the reconstructed logical rows. Separately, confirm from representative completed runs that the Silver batch-control status is `SUCCESS` for populated variants and `NODATA` only for a genuinely absent variant.

**Pass:** no unexplained count difference, null key, duplicate key, or missing populated child output. A rerun of the same batch must not create an additional logical child row for an existing key.

### 6. Validate Gold procedures, reconstruction view, and reporting views
Confirm the four relevant `sp_Ingest...` procedures are invoked by the Gold notebook and use a completed execution as operational evidence. Then compare the current Gold reconstruction view with the legacy Gold table at the agreed logical grain and validate:
- row count and null-rate profile;
- key uniqueness/grain;
- required join coverage, especially `AssessmentID`/related parent identifiers;
- no unexpected record multiplication across candidate/predicted joins;
- both downstream reporting views compile and return rows at their intended grain.

Record the current mixed migration state explicitly: `vw_BAMC_Habitat_Predicted` uses `vw_tblAssessmentHabitatConstraints`, while `vw_BAMC_Habitat_Candidate` still uses direct `tblAssessmentHabitatConstraints`. Do not call candidate reporting validated against the JSON replacement until the owner decides whether that legacy dependency is intentional.

Because direct habitat confirmation and values are also stale, do not call either reporting view current end-to-end. A current JSON constraints reconstruction cannot compensate for stale direct dependencies.

### 7. Use each confirmed stale table as a regression reference
For every confirmed replacement, run comparison in **both directions**:
- old rows missing from the replacement view;
- replacement-view rows absent from the old table;
- row-count difference;
- desynchronised rows caused by current source tables arriving at different times.

Use the confirmed logical comparison fields rather than generated IDs. Report mismatch and desynchronisation rates, their count denominators, and a bounded set of representative mismatch classifications. There is **no pre-approved acceptable percentage**: the task is to measure and explain the difference for owner decision. The workbook's historic observations (~1% old-to-new non-match, ~0.025% join desynchronisation, and ~11% additional new rows) apply only to the constraints comparison and are context only.

### 8. Publish the evidence record
Create `docs/investigations/bamc-json-validation-<cohort-label>.md` containing only aggregate counts, hashes/keys, object versions, query text, and exception classifications. Keep raw JSON and business-value samples in approved workspace storage or ignored scratch, not Git. Conclude `MEASURED — OWNER REVIEW REQUIRED`, `FAIL`, or `BLOCKED`, with the literal unresolved condition.

## Acceptance criteria
- [ ] The legacy cohort, table freshness/limitations, exact field crosswalk, logical grain, and current definition revisions are recorded.
- [ ] Every plausible legacy-table replacement is explicitly classified as confirmed, rejected, or unresolved; no field-name similarity is reported as proof.
- [ ] Bronze extraction, landing, and split reconciliation is complete for representative completed runs, including classification of every inspected root row and array-element counts by parent ID.
- [ ] The four Silver targets reconcile to their specific Bronze child outputs where operationally inspected and have no unexplained duplicate/null merge keys for the legacy cohort.
- [ ] Gold procedures, reconstruction view, and the two reporting views are validated at their agreed comparable grains.
- [ ] The old-table comparison is two-directional and uses confirmed logical business fields rather than `BatchId` or generated IDs.
- [ ] Mismatch/desynchronisation rates and their explanations are reported without inventing an acceptable threshold.
- [ ] The evidence record is written under `docs/investigations/`; no pipeline run, mapping publication, or data mutation is performed solely to satisfy this card.

## Decisions or blockers requiring owner input
- Help run schema and grain-discovery queries over the named Silver and Gold objects, then confirm the final field crosswalk.
- Confirm whether the legacy table carries a trustworthy snapshot/load timestamp; otherwise accept the `unknown-date stale snapshot` limitation.
- Review the measured mismatch/desynchronisation profile; there is no pre-approved threshold for this card.
- Decide whether `vw_BAMC_Habitat_Candidate` is intentionally retained on the direct legacy `tblAssessmentHabitatConstraints` table or should consume `vw_tblAssessmentHabitatConstraints` like the predicted view.
- Decide whether habitat confirmation must be refreshed/reconstructed from the supported JSON presence contract, then recover another current source/transform for habitat values; `ApplicableVegZones` is not its replacement.
- Confirm the intended reporting grain and required fields for `vw_BAMC_Habitat_Candidate` and `vw_BAMC_Habitat_Predicted`.

## Handoff
The live work record is [`tasks/active/bamc-json-ingestion-validation.md`](../../tasks/active/bamc-json-ingestion-validation.md). Start from the selected batch and preserve the difference between a pipeline activity succeeding, a batch being complete across every data layer, and a stale-table regression comparison passing within an approved tolerance.