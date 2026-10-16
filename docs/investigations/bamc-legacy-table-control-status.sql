-- BAMC legacy habitat-table control status
--
-- Run this entire file in the FDWH_IngestionControlStore Warehouse.
-- It cannot run in the FLH_Bronze SQL endpoint because BAMC_MainControlTable
-- belongs to the control-store Warehouse.
--
-- Purpose:
--   Confirm that the direct ingestion routes for the legacy habitat tables
--   remain enabled, successful, and watermarked independently of the JSON path.

SELECT
    Id,
    JSON_VALUE(SourceObjectSettings, '$.objectApiName') AS SourceObject,
    CopyEnabled,
    LastStatus,
    RunTimeUTC,
    JSON_VALUE(DataLoadingBehaviorSettings, '$.dataLoadingBehavior') AS LoadBehaviour,
    JSON_VALUE(DataLoadingBehaviorSettings, '$.watermarkColumnStartValue') AS WatermarkStartValue,
    JSON_VALUE(DataLoadingBehaviorSettings, '$.watermarkQuery') AS WatermarkQuery
FROM dbo.BAMC_MainControlTable
WHERE JSON_VALUE(SourceObjectSettings, '$.objectApiName') IN (
    'dbo.tblAssessmentHabitatConstraints',
    'dbo.tblAssessmentHabitatConfirmation',
    'dbo.tblAssessmentHabitatValues'
)
ORDER BY SourceObject, Id;
