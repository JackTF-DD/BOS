-- BAMC legacy habitat-table freshness checks
--
-- Purpose:
--   Determine whether the directly ingested legacy habitat tables still receive
--   current direct-ingestion data while the JSON replacement route is being validated.
--
-- Run this entire file in the FLH_Bronze SQL endpoint, in schema
-- BiodiversityCalDBBAMC. The separate control-store query is in
-- bamc-legacy-table-control-status.sql and must run in FDWH_IngestionControlStore.
--
-- Interpretation:
--   A table with no recent source change can still be current. Assess its latest
--   latest BatchId together with its control-row status and watermark.
--   Do not use BatchId to compare the stale legacy table with the JSON route.

/*
Block 1: Bronze table freshness

-- Expected output: one row per direct legacy table, with latest source business
-- change and the greatest BatchId observed.
*/
WITH table_freshness AS (
    SELECT
        'tblAssessmentHabitatConfirmation' AS TableName,
        COUNT(*) AS TotalRows,
        MAX(CreatedDate) AS MaxCreatedDate,
        MAX(UpdatedDate) AS MaxUpdatedDate,
        MAX(
            CASE
                WHEN UpdatedDate IS NULL THEN CreatedDate
                WHEN CreatedDate IS NULL THEN UpdatedDate
                WHEN UpdatedDate > CreatedDate THEN UpdatedDate
                ELSE CreatedDate
            END
        ) AS MaxSourceChangeDate,
        MAX(BatchId) AS LatestBatchId
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatConfirmation]

    UNION ALL

    SELECT
        'tblAssessmentHabitatValues' AS TableName,
        COUNT(*) AS TotalRows,
        MAX(CreatedDate) AS MaxCreatedDate,
        MAX(UpdatedDate) AS MaxUpdatedDate,
        MAX(
            CASE
                WHEN UpdatedDate IS NULL THEN CreatedDate
                WHEN CreatedDate IS NULL THEN UpdatedDate
                WHEN UpdatedDate > CreatedDate THEN UpdatedDate
                ELSE CreatedDate
            END
        ) AS MaxSourceChangeDate,
        MAX(BatchId) AS LatestBatchId
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues]

    UNION ALL

    SELECT
        'tblAssessmentHabitatConstraints' AS TableName,
        COUNT(*) AS TotalRows,
        MAX(CreatedDate) AS MaxCreatedDate,
        MAX(UpdatedDate) AS MaxUpdatedDate,
        MAX(
            CASE
                WHEN UpdatedDate IS NULL THEN CreatedDate
                WHEN CreatedDate IS NULL THEN UpdatedDate
                WHEN UpdatedDate > CreatedDate THEN UpdatedDate
                ELSE CreatedDate
            END
        ) AS MaxSourceChangeDate,
        MAX(BatchId) AS LatestBatchId
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatConstraints]
)
SELECT *
FROM table_freshness
ORDER BY TableName;



