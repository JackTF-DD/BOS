---
task: bamc-json-ingestion-validation
owner: unassigned
status: active
opened: 2026-10-15
base_commit: dda38ba5e786bcc778e8d287ecec1ae104cd29dd
---

# BAMC JSON ingestion documentation and validation — BOS

## Objective
Document and validate the existing BAMC replacement path from `dbo.tblAssessmentHabitatSuitability.VegzoneDataJson` through Bronze, Silver, Gold, and reporting views. Establish whether the reconstructed output is fit to replace the stale legacy Gold table for reporting; do not redesign or publish the pipeline under this task.

## Acceptance criteria
- [ ] A reviewed validation plan defines legacy-cohort-scoped checks from source extraction through reporting views and records what each check can and cannot prove.
- [ ] The stale legacy table is treated as a freshness-qualified regression baseline, with two-directional comparison on business fields rather than generated IDs.
- [ ] Bronze/split operational evidence and Silver/Gold/reporting regression evidence is captured for the chosen legacy cohort.
- [ ] Differences are classified and supported by counts/keys/query results; historic provisional-plan percentages are not treated as approved thresholds.
- [ ] The final evidence record is saved under `docs/investigations/`, and no external write/run is performed without separate authorization.

## Status
Active. Scope reset on 2026-10-15: today's deliverable is documentation and a validation plan, not pipeline implementation. The route has successful live execution evidence, but data-level and reporting-level validation remains to be performed.

## Confirmed facts
- `BAMC_MainControlTable` stores source/copy/sink/loading-behaviour JSON, copy enablement, last status, and runtime state. [`data/Fabric/09 Metadata/03 Datawarehouses/FDWH_IngestionControlStore.Warehouse/dbo/Tables/BAMC_MainControlTable.sql:1-18`]
- Live Bronze metadata confirms the stale legacy table `BiodiversityCalDBBAMC.tblAssessmentHabitatConstraints` with fields `AssessmentID`, `VegzoneName`, `SpeciesID`, `ConstraintType`, `HabitatConstraint`, and `Selected`. Two further tables are plausible but unproven candidates: `tblAssessmentHabitatConfirmation` (`VegzoneName`, `Confirmed`) and `tblAssessmentHabitatValues` (`VegZoneName`, `IsChecked`, `Value`, `CompleteLoss`). [Fabric Lakehouse table-metadata read-back, 2026-10-15]
- The JSON mapping source contains only two JSON source tables and four destinations: predicted → `...PredictedConstraintsWithVegZone`/`...PredictedPresence`, candidate → `...CandidateConstraints`/`...CandidateApplicableVegZones`. It does not map either JSON child directly to `tblAssessmentHabitatConfirmation` or `tblAssessmentHabitatValues`. The supplied control/mapping exports retain enabled direct routes for the three legacy tables, so the two additional semantic similarities are not proof of supersession. [`metadata/source/SourceToTargetMappingNonProd(BronzeToSilver).csv`; `metadata/source/BAMCMainControlTable.csv`; mapping/control inventory, 2026-10-15]
- Owner-provided Gold definitions confirm the actual migration boundary: `vw_tblAssessmentHabitatConstraints` reconstructs only constraints from JSON-derived candidate/predicted constraint tables; `vw_BAMC_Habitat_Predicted` consumes that reconstruction but directly joins legacy habitat confirmation; `vw_BAMC_Habitat_Candidate` directly uses legacy habitat constraints, confirmation, and values. The JSON-derived presence/applicable-veg-zone tables are not consumed by these two views. [Owner-provided Gold view definitions, 2026-10-15]
- The supplied candidate reporting-view definition establishes the intended existing Gold relationship for values: `tblAssessmentHabitatSuitability.Id = tblAssessmentHabitatValues.HabitatSuitabilityId`. It does not reference `tblBAMAssessment`, so it cannot establish a values-to-BAM-assessment relationship. `tblBAMAssessment` is loaded independently by the Gold notebook. [Owner-provided `vw_BAMC_Habitat_Candidate` definition; `data/Fabric/03 Gold/01 Pipelines/02 Notebooks/N_TSQLSilverToGold_BAMC.Notebook/notebook-content.sql:179-198`, `:419-423`]
- Owner-run live freshness/control queries show all three direct legacy Bronze tables are stale: their greatest source change is 2026-06-05 and greatest batch is `202606162110010000` (June 16, 2026). The associated control rows have `CopyEnabled=1` and `LastStatus=1`, but `RunTimeUTC` is null and each watermark remains the initial `1900-01-01T00:00:01`. This is not evidence of current direct ingestion. [Owner query results, 2026-10-15]
- A 1,000-row Silver sample supports the proposed `PredictedPresence` → `tblAssessmentHabitatConfirmation` correspondence: 896 rows matched the legacy assessment/species/vegzone parent key and 895 matched the `Confirmed` value as well. The single parent-key match with a value difference and 104 rows absent from the stale legacy snapshot require classification; this is strong sampled evidence, not full reconstruction proof. [Owner query results, 2026-10-15]
- The live-schema values probe rejects `CandidateApplicableVegZones` → `tblAssessmentHabitatValues`. All 1,000 JSON rows have a numerically equal legacy `Id`, but zero have the same `AssessmentId`, zero have the same `UnitOfMeasure`, zero have the same vegzone name, and only six have the same species. This is not lineage: the IDs collide numerically while referring to different records. High agreement on `IsChecked` (887), `CompleteLoss` (998), and value (876) is non-dispositive without parent identity. [Owner query results, 2026-10-15]
- The reviewed local control export has 44 enabled rows: 40 `DeltaLoadWithQuery`, three `FullLoad`, and one `JsonDeltaLoad`. [`metadata/source/BAMCMainControlTable.csv`; local CSV inventory, 2026-10-15]
- Two enabled local-control rows use `dbo.tblAssessmentHabitatSuitability` with the same watermark: the ordinary row selects the table's business fields plus `VegzoneDataJson`; the JSON row selects only `ID` and `VegzoneDataJson`. [`metadata/source/BAMCMainControlTable.csv`; local CSV review, 2026-10-15]
- The `ID` column in all four JSON-derived Silver tables is the unchanged source `[dbo].[tblAssessmentHabitatSuitability].[ID]`: the copy query lands it, the constraints notebook reads it into `PASSTHROUGH`, and both predicted/candidate outputs select `PASSTHROUGH`; the STTM maps source `ID` verbatim to destination `ID`. It is a parent suitability identifier, not a JSON-child key or proof of relation to a same-named legacy-table ID. [`metadata/source/BAMCMainControlTable.csv`; `data/Fabric/01 Bronze/01 Pipelines/02 Notebooks/N_BAMC_Constraints_json.Notebook/notebook-content.py:222-239`, `:428-505`; `metadata/source/SourceToTargetMappingNonProd(BronzeToSilver).csv`]
- `P_BAMCIngestion_TopLevel` counts enabled control rows, batches them, and invokes `L_BAMCIngestion_MiddleLevel`; it passes a run-wide `windowStart`. [`data/Fabric/01 Bronze/01 Pipelines/P_BAMCIngestion_TopLevel.DataPipeline/pipeline-content.json:5-125`]
- The middle-level pipeline orders enabled control rows by `TaskId`, then `Id` descending, and invokes `L_BAMCIngestion_BottomLevel` for each group. [`data/Fabric/01 Bronze/01 Pipelines/03 Pipeline Modules/L_BAMCIngestion_MiddleLevel.DataPipeline/pipeline-content.json:5-114`]
- The bottom-level `JsonDeltaLoad` branch calculates the source watermark, copies JSON to `Files/BiodiversityCalDBBAMCJsonDeltaLoad/tblAssessmentHabitatSuitability/<yyyy/MM/dd/HH>/tblAssessmentHabitatSuitability-<batchId>.json`, invokes `N_BAMC_Constraints_json` after the copy, then updates the control watermark. [`data/Fabric/01 Bronze/01 Pipelines/03 Pipeline Modules/L_BAMCIngestion_BottomLevel.DataPipeline/pipeline-content.json:474-770`]
- `N_BAMC_Constraints_json` routes two observed `VegzoneDataJson` shapes into `...predicted` and `...candidate` JSON output directories; blank values are counted but not output, while unknown/unparseable nonblank values fail the run. [`data/Fabric/01 Bronze/01 Pipelines/02 Notebooks/N_BAMC_Constraints_json.Notebook/notebook-content.py:25-68`, `:277-348`, `:455-539`, `:562-730`]
- The repository mapping source defines all four JSON child destinations under `BiodiversityCalDBBAMCJsonDeltaLoad`: 23 rows total, 19 active projection/key rows, and four inactive structural array rows at explode step 1. The active projection sets, four source keys, and destination-column uniqueness all match the constraints notebook's two output schemas. [`metadata/source/SourceToTargetMappingNonProd(BronzeToSilver).csv`; structural mapping check, 2026-10-15]
- `P_BAMC_Ingestion_Master` invokes ordinary Silver processing with `sourceType= bamc`, then invokes a second Silver route with `source_type= bamc_JSON` and `bronze_format=json`. [`data/Fabric/&#32;P_BAMC_Ingestion_Master.DataPipeline/pipeline-content.json:55-109`, `:167-215`]
- The refreshed `N_CommonUtils` has an explicit `bamc_JSON` branch resolving source schema `BiodiversityCalDBBAMCJsonDeltaLoad`, destination schema `BiodiversityCalDBBAMC`, and the matching Files-relative root. [`data/Fabric/02 Silver/01 Pipelines/02 Notebooks/N_CommonUtils.Notebook/notebook-content.py:423-443`; commit `74be42c`]
- The refreshed `N_BronzeToSilver` no longer skips all destinations outside the three training tables; it iterates every distinct active mapping pair and uses `load_json()` when `bronze_format=json`. [`data/Fabric/02 Silver/01 Pipelines/02 Notebooks/N_SFBronzeToSilver.Notebook/notebook-content.py:511-537`; commit `74be42c`]
- Each child destination has one active `SourceColumnKey` row: `ConstraintWithVegZoneKey`, `PresenceKey`, `ConstraintKey`, or `ApplicableVegZoneKey`. `get_merge_condition()` selects `SourceColumnKey=1` rows and therefore chooses `Merge`; it does not use `DestinationColumnCompositeKey`. [`metadata/source/SourceToTargetMappingNonProd(BronzeToSilver).csv`; `data/Fabric/02 Silver/01 Pipelines/02 Notebooks/N_CommonUtils.Notebook/notebook-content.py:286-379`]
- The latest live BAMC master run (`8ce09750-07e6-4a21-982f-0f9742351633`) completed without a failure reason on 2026-10-14. Its JSON Silver child used batch `202610141915040000`, `source_type=bamc_JSON`, `load_type=merge`, and `bronze_format=json`; the invoked Bronze-to-Silver notebook completed successfully with exit value `0`. This proves route execution, not row-level completeness. [Fabric pipeline run/activity read-back, 2026-10-15]
- For batch `202610141915040000`, live `FLH_Bronze` contains the expected source JSON file (124,556 bytes), plus both splitter outputs under the same timestamped path: predicted has `_SUCCESS` and five JSON part files; candidate has `_SUCCESS` and four JSON part files. The source landed at 19:18 UTC and both derived outputs completed around 19:21 UTC on 2026-10-14. [OneLake Files listing read-back, 2026-10-15]

## Hypotheses
- The two control rows for `tblAssessmentHabitatSuitability` are intended to coexist: one preserves the main table, while the JSON route supplies the normalized child grains.
- Most replacement-view rows absent from the legacy table will be explained by data newer than the legacy snapshot, rather than a reconstruction defect; this must be measured, not assumed.

## Decisions
- Treat the checked-out `data/` tree as evidence only; do not edit, generate into, or deploy from it.
- Keep control/mapping publication, repository implementation, and a runtime ingestion test as separate authorization gates.

## Rejected alternatives
- Editing the workspace mirror in `data/` because it is explicitly reference-only and would not create a reviewable authored source.
- Treating the notebook's own read-back as proof that Silver completed; it only validates the notebook's JSON output directories.

## Open questions
1. What are the Silver and Gold schemas and logical grains of the old table, replacement tables/view, and reporting views?
2. Does the legacy table have a trustworthy snapshot/load timestamp? If not, can it be accepted as an unknown-date stale baseline?
3. Is `vw_BAMC_Habitat_Candidate` intentionally retained on direct legacy habitat-constraint data, or should it consume `vw_tblAssessmentHabitatConstraints` like the predicted view?
4. How should measured mismatch/desynchronisation results be grouped for owner review, and what fields/grain must the two downstream reporting views provide?

## Risks and constraints
- `vw_BAMC_Habitat_Predicted` still joins stale direct habitat confirmation, and `vw_BAMC_Habitat_Candidate` still joins all three stale direct legacy tables. Therefore neither view can be called current end-to-end solely because the JSON constraints route succeeds.
- The master pipeline allows `Process Silver` after Bronze is merely `Completed`, not necessarily successful; investigate expected failure semantics before changing orchestration.
- JSON paths must agree exactly with `N_CommonUtils.get_json_path()`; a root/schema mismatch can turn a missing input into a `NODATA` outcome.
- The constraints notebook deliberately writes JSON arrays per file because Silver reads with `multiline=true`; changing the file shape can silently drop rows.
- The current source mirror contains an HTML-escaped directory name (`data/Fabric/&#32;P_BAMC_Ingestion_Master.DataPipeline`); preserve its path literally when using it as evidence.

## Checks and evidence
- `git -C data fetch origin dev && git -C data merge --ff-only origin/dev` — current and clean at `74be42c8318ba1580074ee848936f4f5e5c77a91`, 2026-10-15.
- Local control/mapping CSV inventories — passed as read-only inspections, 2026-10-15.
- Pipeline/notebook route trace — completed from the checked-out definitions, 2026-10-15.
- Live run/activity read-back — master `8ce09750-07e6-4a21-982f-0f9742351633`; JSON Silver child `7ddd15bf-2913-4273-b293-15c6fc67d5e9`; Bronze-to-Silver notebook activity `2c5d5eee-af3c-4bb2-9b20-c7cad54c1822` succeeded with exit `0`, read 2026-10-15.
- Live Bronze Files read-back — `FLH_Bronze` item `b5432d5e-4c7c-47e4-ac09-dc7ba46a81bc`, batch `202610141915040000`; source and both split-output directories present with `_SUCCESS` markers, read 2026-10-15.
- Owner-run legacy-table freshness/control checks — confirmation: 3,872,166 rows; constraints: 2,117,886 rows; values: 6,162,933 rows. All have maximum source change on 2026-06-05, batch `202606162110010000`, null control `RunTimeUTC`, and initial control watermark; received 2026-10-15.
- External publication/read-back — not applicable; no Fabric workspace call or pipeline run was requested.

## Next action
Run `bamc-habitat-values-json-probe.sql` against the observed live schema, then decide whether `ApplicableVegZones` supports values reconstruction or requires source-contract recovery.

## Handoff notes
The two initially observed local source-contract defects are resolved in commit `74be42c`: `bamc_JSON` is recognised and the training-only destination guard is removed. Today's scope is validation planning: preserve the distinction between pipeline success, end-to-end data completeness, and freshness-qualified legacy regression parity.