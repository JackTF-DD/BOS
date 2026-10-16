---
task: pipeline-monitoring-desktop-remediation
owner: Jack Foster / daily-driver
status: review
opened: 2026-10-15
base_commit: dda38ba
---

# Pipeline monitoring report — Desktop remediation — BOS

## Objective
Update the user-opened local `pipeline_monitoring(2)` Power BI Desktop report and semantic model to calculate master status at the selected master-run grain, enable Failure Investigation for failed and partial runs, and make the active rolling Past Day/Past Week range visible. Do not publish, deploy, refresh, or alter live Fabric artefacts.

## Acceptance criteria
- [x] `Master Status (TriColour)` returns `Failed` for a failed master run; returns `Partial` where a completed master run has one or more failed child activities; and does not derive global child activity status outside the selected master run.
- [x] `Can Drill Through` is enabled for corrected `Failed` and `Partial` master-run statuses.
- [x] Past Day applies the preceding 24 hours; Past Week applies the preceding seven days; the active period is visibly identified. [Owner-reported Desktop completion, 2026-10-16]
- [x] The local semantic-model TMDL and report definition changes are persisted locally and parse successfully. No Fabric publication, deployment, refresh, or source/submodule change occurred.

## Status
Implementation is complete locally and awaiting owner review only. The local TMDL export contains the corrected status, drillthrough, and activity-flow measures. The report definition contains the generic drillthrough binding without the hard-coded BAMC value. The owner configured the period selector and active visual state in Desktop; this is recorded as owner-reported because the saved report definition was not re-read after that Desktop authoring step. No Fabric publication, deployment, refresh, or repository `data/` submodule mutation occurred.

## Confirmed facts
- The open Desktop model is `pipeline_monitoring(2)` at `localhost:59283`, connected read-only during the completed diagnosis as `PBIDesktop-pipeline_monitoring(2)-59283`. [`tasks/completed/pipeline-monitoring-prod-diagnosis.md`]
- `Master Status (TriColour)` currently reads `Fact Pipeline Runs[Status]` without a selected-master filter and counts child activity results outside the selected master-run context. [`tasks/completed/pipeline-monitoring-prod-diagnosis.md`]
- `Can Drill Through` currently returns 1 only for computed `Partial`; the drillthrough page has a hard-coded `P_BAMC_Ingestion_Master` filter. [`tasks/completed/pipeline-monitoring-prod-diagnosis.md`]
- Owner-confirmed rules: source `Completed` with failed children is `Partial`; Failure Investigation is available for `Failed` and `Partial`; Past Day/Past Week are rolling preceding 24-hour/seven-day periods. [`tasks/completed/pipeline-monitoring-prod-diagnosis.md`]
- `Master Status (TriColour)` was updated in the open model to use the selected latest-master `ItemId`, retrieve matching `pipelineRunId` values, and apply them explicitly to activity rows with `TREATAS`. The updated `Can Drill Through` returns 1 for corrected `Failed` and `Partial` statuses. [MCP `measure_operations/Update` and read-back `Get`, 2026-10-15]
- Read-only DAX verification returns `Failed` and `Can Drill Through = 1` for latest-master ItemId `192156c9-516d-433b-9d1b-2f9a3c0b6fd2`; all completed master rows with failed scoped children return `Partial` and `Can Drill Through = 1`. [MCP `dax_query_operations/Execute`, 2026-10-15]
- The PBIP report and sibling `pipeline_monitoring(2).SemanticModel` folder are available in `C:\Users\JackFoster\Downloads`; `definition.pbir` binds the report by relative path to that model. [PBIP/report definition inspection, 2026-10-16]
- Removed the fixed `P_BAMC_Ingestion_Master` filter from the Failure Investigation page while retaining its `ItemName` drillthrough binding. All 62 report JSON files parse after the change. [`C:\Users\JackFoster\Downloads\pipeline_monitoring(2).Report\definition\pages\ff6dbaa077ea551d98b0\page.json`; local JSON validation, 2026-10-15]
- The open Desktop model evaluates `[Failed KPI SVG]`, `[Partial KPI SVG]`, `[Successful KPI SVG]`, and `[Total KPI SVG]` to SVG strings with valid XML/SVG structure and expected live values; the data/model layer is therefore not the cause of the rendering failure. [MCP read-only `dax_query_operations/Execute`, 2026-10-16]
- The saved report's five affected HTML Content visuals had `objects.compatibility.legacyRendering = true`; the known working report definition at `data@88b170ba` has no such override. Removed the override from four overview KPI visuals and the Failure Investigation pipeline-flow visual. All 64 PBIP/report JSON files parse after the change. [Definition comparison and local JSON validation, 2026-10-16]
- On the screenshot's selected `P_BAMC_Ingestion_Master` row, the live `Pipeline Flow SVG` measure has four matching activities and returns SVG content. In its unfiltered context, the former measure returned `width=-40`, which is invalid SVG and can make the HTML Content visual blank. The updated measure instead emits `width=600` and “Select a master pipeline…” when no run is selected; for BAMC it emits valid `width=920` SVG with inline polygon arrowheads. [MCP read-only DAX before/after and `measure_operations/Update`, 2026-10-16]
- Exported the current open Desktop model to `C:\Users\JackFoster\Downloads\pipeline_monitoring(2).SemanticModel\definition`; the resulting `Measure Table.tmdl` contains the corrected `Master Status (TriColour)`, `Can Drill Through`, and `Pipeline Flow SVG` expressions. [MCP `database_operations/ExportToTmdlFolder`, followed by file read-back, 2026-10-16]
- Owner reported completion of the Past Day/Past Week Bookmark Navigator formatting after adopting the white selected pill treatment on the navy header. [Owner report, 2026-10-16]

## Hypotheses
- The required report-page button formatting can be changed safely through the currently open Desktop UI; the Power BI modelling MCP exposes semantic-model operations but no report visual authoring operation.

## Decisions
- Changes apply to the currently open local Desktop report/model only. Saving the Desktop file is authorised; Fabric publication or refresh is not.
- Preserve source-master `Failed` as `Failed`; use scoped child outcomes to distinguish `Partial` from success when the source master is `Completed`.

## Rejected alternatives
- Editing or deploying Fabric items: not authorised for this task.
- Retaining the current bookmark-only range selector: it cannot visibly identify the active range.
- Attempting unmanaged UI automation through shell keystrokes: it could save or edit the wrong foreground application and does not satisfy the required visual read-back.

## Open questions
1. None. The final local visual state and save are owner-reported rather than independently screen-read after the final change.

## Risks and constraints
- The Power BI MCP exposes write-capable model operations; only the two required measure updates have been invoked.
- The final Bookmark Navigator visual state was authored in Desktop and has not been independently re-read from PBIR after the owner-reported save.
- `data/` is pull-only and must remain unmodified.
- The saved PBIP is report-only: changing report visuals or bookmarks alone cannot add the selector table/measure required for a maintainable active-state implementation.

## Checks and evidence
- Read-only diagnosis and local Desktop validation — completed 2026-10-15; see `tasks/completed/pipeline-monitoring-prod-diagnosis.md`.
- Model read-back after measure updates — passed 2026-10-15 and 2026-10-16: MCP `measure_operations/Get` and `dax_query_operations/Execute` confirmed expressions and live results; final model state was exported to the paired TMDL folder at 2026-10-16 12:29 AEDT.
- Report definition JSON validation — passed 2026-10-15: 62 JSON files parsed after removing the hard-coded drillthrough filter.
- HTML Content regression investigation — completed 2026-10-16: live DAX returns SVG content, saved report definition comparison isolated an added `legacyRendering` override, and 64 PBIP/report JSON files parsed after removing it.
- Failure Investigation flow regression check — completed 2026-10-16: reproduced invalid unfiltered SVG width, updated the Desktop measure to produce valid selected/unselected SVG, and read back its selected BAMC and unselected output through DAX.
- PBIP/report JSON validation — passed 2026-10-16: all 64 JSON files parse after the report-definition edits.
- External publication/read-back — not applicable; no publication was authorised or made.

## Next action
Owner review the saved PBIP locally; if accepted, request a separate explicit publication/deployment action if a Fabric workspace update is required.

## Handoff notes
- The active-state fix is a Bookmark Navigator, not standalone action-button selected formatting. Existing Past Day/Past Week bookmarks retain their rolling 24-hour/seven-day filter semantics.
- Use the discovered `pipeline_monitoring(2)` Desktop instance only; do not connect to another local instance.
