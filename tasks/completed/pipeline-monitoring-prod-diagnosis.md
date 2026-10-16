---
task: pipeline-monitoring-prod-diagnosis
owner: Jack Foster / daily-driver
status: completed
opened: 2026-10-15
base_commit: dda38ba
---

# Pipeline monitoring report — production diagnosis and local Desktop read-only follow-up — BOS

## Objective
Diagnose the production `pipeline_monitoring` report defects without changing live Fabric artefacts: (1) master-pipeline status shows `Unknown`, (2) Past Day/Past Week has no active-state indication, and (3) Failure Investigation does not operate as expected. Establish a read-only local Power BI Desktop MCP connection so the diagnosis can be validated against the open Desktop model.

## Acceptance criteria
- [x] Read-only inspection identifies evidence-backed root causes for the three reported report behaviours.
- [x] No live Fabric artefact, deployment, refresh, or repository-owned `data/` submodule content was changed by this task.
- [x] Daily-driver configuration launches Power BI Authoring MCP as a Windows-local stdio process; connection test discovers its tools.
- [x] Fresh Hermes session connects read-only to the user's open Power BI Desktop model and verifies the status measure / relationship behaviour with DAX or exported metadata.

## Status
Diagnosis is complete. The final Power BI Desktop validation was performed read-only against the locally open `pipeline_monitoring(2)` model. No live Fabric or Desktop artefact was changed.

## Confirmed facts
- Production workspace is `BOS Data Engineering Prod` (`4789eb5e-6d33-495d-be2c-f19a1167eed6`). It contains report `pipeline_monitoring` (`9947b354-1c95-473f-9ce7-48802c81f3eb`) and semantic model `pipeline_monitoring` (`1ae5286c-c174-4fa5-bd2d-63bb6941c76f`). The non-prod logical IDs match (`e131c39e-e7f8-4100-b620-f2cb64b9cffe` report and `bae8fc4d-8bd5-46c0-b42c-3ad91a158dbb` model). [Read-only Fabric REST `GET /v1/workspaces/.../items`, 2026-10-15]
- The checked-out pull-only `data/` submodule remains at `ed1d5fb` and does not contain `pipeline_monitoring`. The report/model/notebook snapshot is available read-only at commit `88b170ba029095ae1434ee214328b21f1759e355` on `data` branch `origin/dev`, subject `pipeline monitoring updates` dated 2026-10-15. [Git commands recorded in session]
- The prod report page definition matches the dev snapshot for report interactions; only `.platform` and `definition.pbir` differ, reflecting production binding. [Temporary decoded prod definition compared with archived dev definition, 2026-10-15]
- `Master Status (TriColour)` reads `SELECTEDVALUE('Fact Pipeline Runs'[Status])`, though the primary visual is at `Fact Latest Master Pipeline Runs` grain. Its final `SWITCH` fallback is `"Unknown"`. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.SemanticModel/definition/tables/Measure Table.tmdl:4-31`]
- The relationship from `Fact Pipeline Runs[ItemId]` to `Fact Latest Master Pipeline Runs[ItemId]` is one direction, so a selected master-row filter does not flow backward to `Fact Pipeline Runs`. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.SemanticModel/definition/relationships.tmdl:57-59`]
- The same status measure counts failed/succeeded child activities without filtering them to the selected master pipeline/run. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.SemanticModel/definition/tables/Measure Table.tmdl:9-19`]
- `[Latest Run Time]` works differently: it explicitly applies the selected master `ItemId` to `Fact Pipeline Runs`. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.SemanticModel/definition/tables/Measure Table.tmdl:45-56`]
- Past Day and Past Week are action buttons calling bookmarks `4bd067970e96a9edca9b` and `436866324307b9144271`. Their bookmarks apply date filters but do not persist a selected visual state for either button. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.Report/definition/pages/09ce50c56a98a2233118/visuals/0b3d049c9d8e489dab28/visual.json:58-107`; `.../cbdc9e475d08c2157089/visual.json:58-108`; `.../definition/bookmarks/bookmarks.json:3-10`]
- Failure Investigation is a drillthrough action requiring selected `Fact Latest Master Pipeline Runs[ItemName]`, and its styling/availability is driven by `[Can Drill Through]`. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.Report/definition/pages/09ce50c56a98a2233118/visuals/dcda0a9043a0ee268530/visual.json:255-287`]
- `[Can Drill Through]` returns 1 only for `Partial`, not `Failed`; all `Unknown` rows therefore disable the button. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.SemanticModel/definition/tables/Measure Table.tmdl:467-476`]
- The hidden drillthrough page retains a hard-coded initial filter for `P_BAMC_Ingestion_Master`, in addition to its ItemName drillthrough binding. [`data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.Report/definition/pages/ff6dbaa077ea551d98b0/page.json:8-85`]
- User reviewed and explicitly authorised acceptance of the Power BI Authoring MCP EULA at `https://go.microsoft.com/fwlink/?LinkId=2381247`; it was accepted for daily-driver. [MCP `accept_eula`, 2026-10-15]
- Before reconfiguration, the WSL-hosted Power BI MCP returned `Found 0 local PowerBI Desktop and Analysis Services instances`. [MCP `connection_operations/ListLocalInstances`, 2026-10-15]
- Daily-driver MCP config now launches Windows `npx.cmd` through `/mnt/c/Windows/System32/cmd.exe`; `hermes mcp test powerbi-modeling-mcp` connected in 3878 ms and discovered 22 tools. [`/home/jackfoster/.hermes/profiles/daily-driver/config.yaml`; command output, 2026-10-15]
- Fresh MCP discovery found the user-opened Desktop instance `pipeline_monitoring(2)` at `localhost:59283`; a read-only connection named `PBIDesktop-pipeline_monitoring(2)-59283` was established. [MCP `ListLocalInstances` and `Connect`, 2026-10-15 13:56 AEDT]
- The live Desktop measure definitions exactly match the static source diagnosis: `Master Status (TriColour)` uses `SELECTEDVALUE('Fact Pipeline Runs'[Status])`, while `Can Drill Through` returns 1 only for `Partial`; `[Latest Run Time]` explicitly filters pipeline runs by selected master `ItemId`. [MCP read-only `measure_operations/Get`, 2026-10-15 13:56 AEDT]
- The live Desktop model has the same active one-direction relationship from `Fact Pipeline Runs[ItemId]` (many) to `Fact Latest Master Pipeline Runs[ItemId]` (one). [MCP read-only `relationship_operations/List`, 2026-10-15 13:56 AEDT]
- Read-only DAX directly reproduces the defect: the latest-master row with source status `Failed` for ItemId `192156c9-516d-433b-9d1b-2f9a3c0b6fd2` evaluates `[Master Status (TriColour)]` as `Partial` and `[Can Drill Through]` as 1. Across all eight latest-master rows, `[Master Status (TriColour)]` returned `Partial` despite source statuses including `Failed` and `Completed`; explicit `ItemId` filtering returns 75–161 matching pipeline-run rows per latest-master row. [MCP read-only `dax_query_operations/Execute`, 2026-10-15 13:56 AEDT]

## Hypotheses
- The underlying `meta.vw_latest_master_pipeline_runs`, `meta.vw_pipeline_runs`, and `meta.vw_pipeline_activity_runs` SQL view logic may add independent staleness/filter defects. Their definitions were not present in the source snapshot and were not changed or queried.

## Decisions
- Do not alter any live Fabric artefact, Power BI Desktop model, semantic model, report, refresh schedule, or source definition in this task without a separate user-authorised remediation request.
- Use Windows-local stdio Power BI MCP, not WSL-local `npx`, because Power BI Desktop runs in the Windows session.
- Limit next-session MCP work to `ListLocalInstances`, `Connect`, metadata export/get, and read-only DAX. Do not call Update, Create, Rename, refresh, transaction, deployment, or report/model writes.
- Owner-confirmed remediation rules: a master run with source status `Completed` and failed child activities is `Partial`; Failure Investigation must be enabled for `Failed` and `Partial`; Past Day and Past Week mean the preceding 24 hours and preceding seven days respectively. [Owner confirmation, 2026-10-15]

## Rejected alternatives
- WSL-hosted `npx` connection: it was proven unable to see local Desktop/Analysis Services instances.
- Fabric write/deploy to test a repair: prohibited by user and unnecessary for diagnosis.

## Open questions
1. Whether the three underlying `meta` view definitions add independent staleness or filter defects remains untested.
2. A remediation task still needs to select the concrete report interaction/formatting implementation for showing the active Past Day or Past Week period; its business meaning is confirmed.

## Risks and constraints
- `data/` is a pull-only submodule and must remain unmodified.
- Local Power BI MCP exposes write-capable operations; use only the explicit read-only operations above.
- The current TUI session retains the old MCP registry. A fresh session is mandatory to load the changed launcher.
- Existing worktree changes are unrelated and must be preserved.

## Checks and evidence
- `just orient` — completed 2026-10-15; repository root confirmed as `/home/jackfoster/hermes-work/repos/bos`.
- `just verify-state` — completed 2026-10-15; existing unrelated modified/untracked work is present; no task-owned repository changes existed before this record.
- `git -C data status --short` — clean 2026-10-15.
- Read-only Fabric REST list-items and get-definition operations — completed 2026-10-15; no update/refresh/deploy operation invoked.
- `hermes config get mcp_servers.powerbi-modeling-mcp` — confirms Windows `cmd.exe` / `npx.cmd` launcher, 2026-10-15.
- `hermes mcp test powerbi-modeling-mcp` — passed: connected in 3878 ms and discovered 22 tools, 2026-10-15.
- MCP `ListLocalInstances`, `Connect`, `measure_operations/Get`, `relationship_operations/List`, and two `dax_query_operations/Execute` calls — completed 2026-10-15 13:56 AEDT; all read-only operations succeeded against Desktop `pipeline_monitoring(2)`.
- External publication/read-back — not applicable; no publication or live modification was authorised or made.

## Next action
Create a separately authorised remediation task if the report is to be changed. Do not use this diagnostic record as authority to modify the report, semantic model, SQL views, refreshes, or live Fabric artefacts.

## Handoff notes
- Config was changed with Hermes CLI only, never by hand-editing YAML:
  - `mcp_servers.powerbi-modeling-mcp.command = /mnt/c/Windows/System32/cmd.exe`
  - `mcp_servers.powerbi-modeling-mcp.args = ["/d", "/s", "/c", "npx.cmd -y @microsoft/powerbi-modeling-mcp@latest --start"]`
- Restart/reopen with `/exit` then `hermes --tui --continue` (or open a new daily-driver session). The fresh tool registry should expose the Windows-launched MCP server.
- Start with `mcp__powerbi_modeling_mcp__connection_operations` request `{ "operation": "ListLocalInstances" }`. Connect only to the model visibly open in Desktop. Use `ListConnections`, `Get`, `ExportTMDL`, and DAX query operations as read-only evidence.
- Key source reference path once the checkout is at the correct historical commit: `data@88b170ba:Fabric/08 Alerting/pipeline_monitoring.SemanticModel/definition/tables/Measure Table.tmdl`. Do not switch or modify the submodule merely to inspect it; use `git -C data show 88b170ba:<path>` or archive into ignored scratch.
