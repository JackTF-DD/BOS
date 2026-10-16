-- BAMC CandidateApplicableVegZones to legacy HabitatValues probe
--
-- Run in the FLH_Silver SQL endpoint, schema BiodiversityCalDBBAMC.
--
-- This probe uses the live column names observed in the current SQL endpoint:
--   b.tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey
--   a.tblAssessmentHabitatSuitabilityKey
--
-- Purpose:
--   Test the user's observed relationship a.Id = b.ID against the legacy
--   HabitatValues table. It is a bounded 1,000-row sample; it does not mutate
--   any table and is not a full reconciliation.
--
-- Important:
--   The legacy table is stale. Field mismatches may reflect either a false
--   mapping or changed source state. This query reports individual-field
--   correspondence so the relationship can be assessed rather than assumed.

/*
Block 1: sampled aggregate correspondence by legacy Id = JSON parent ID.

The output records whether at least one legacy values row for the same ID agrees
with each proposed field separately. This avoids joining/grouping all 6M+ rows.
*/
WITH json_candidate_sample AS (
    SELECT TOP (1000)
        b.[tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey] AS JsonChildKey,
        b.[ID] AS JsonParentId,
        a.[AssessmentId] AS JsonAssessmentId,
        a.[SpeciesId] AS JsonSpeciesId,
        a.[UnitOfMeasure] AS JsonUnitOfMeasure,
        b.[Name] AS JsonName,
        b.[IsChecked] AS JsonIsChecked,
        b.[IsCompleteLossChecked] AS JsonCompleteLoss,
        CAST(b.[AreaForVegZone] AS DECIMAL(10, 2)) AS JsonValue
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitability] AS a
    INNER JOIN [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitabilityCandidateApplicableVegZones] AS b
        ON a.[Id] = b.[ID]
    WHERE b.[tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey] IS NOT NULL
    ORDER BY b.[tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey]
),
evaluated AS (
    SELECT
        j.*,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
        ) THEN 1 ELSE 0 END AS HasLegacyId,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
              AND v.[AssessmentId] IS NOT DISTINCT FROM j.JsonAssessmentId
        ) THEN 1 ELSE 0 END AS HasAssessmentMatch,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
              AND v.[SpeciesId] IS NOT DISTINCT FROM j.JsonSpeciesId
        ) THEN 1 ELSE 0 END AS HasSpeciesMatch,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
              AND v.[UnitOfMeasure] IS NOT DISTINCT FROM j.JsonUnitOfMeasure
        ) THEN 1 ELSE 0 END AS HasUnitOfMeasureMatch,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
              AND v.[VegZoneName] IS NOT DISTINCT FROM j.JsonName
        ) THEN 1 ELSE 0 END AS HasVegZoneNameMatch,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
              AND v.[IsChecked] IS NOT DISTINCT FROM j.JsonIsChecked
        ) THEN 1 ELSE 0 END AS HasIsCheckedMatch,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
              AND v.[CompleteLoss] IS NOT DISTINCT FROM j.JsonCompleteLoss
        ) THEN 1 ELSE 0 END AS HasCompleteLossMatch,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
            WHERE v.[Id] = j.JsonParentId
              AND v.[Value] IS NOT DISTINCT FROM j.JsonValue
        ) THEN 1 ELSE 0 END AS HasValueMatch
    FROM json_candidate_sample AS j
)
SELECT
    COUNT(*) AS SampleRows,
    SUM(HasLegacyId) AS RowsWithLegacyId,
    SUM(HasAssessmentMatch) AS RowsWithAssessmentMatch,
    SUM(HasSpeciesMatch) AS RowsWithSpeciesMatch,
    SUM(HasUnitOfMeasureMatch) AS RowsWithUnitOfMeasureMatch,
    SUM(HasVegZoneNameMatch) AS RowsWithVegZoneNameMatch,
    SUM(HasIsCheckedMatch) AS RowsWithIsCheckedMatch,
    SUM(HasCompleteLossMatch) AS RowsWithCompleteLossMatch,
    SUM(HasValueMatch) AS RowsWithValueMatch,
    COUNT(DISTINCT JsonChildKey) AS DistinctJsonChildKeys,
    COUNT(DISTINCT JsonParentId) AS DistinctJsonParentIds
FROM evaluated;


/*
Block 2: small paired-row inspection.

Returns at most 20 JSON child rows and up to five legacy values rows per parent
ID. Use this only to inspect field patterns; do not commit business values.
*/
WITH json_candidate_sample AS (
    SELECT TOP (20)
        b.[tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey] AS JsonChildKey,
        b.[ID] AS JsonParentId,
        a.[AssessmentId] AS JsonAssessmentId,
        a.[SpeciesId] AS JsonSpeciesId,
        a.[UnitOfMeasure] AS JsonUnitOfMeasure,
        b.[Name] AS JsonName,
        b.[IsChecked] AS JsonIsChecked,
        b.[IsCompleteLossChecked] AS JsonCompleteLoss,
        b.[AreaForVegZone] AS JsonAreaForVegZone
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitability] AS a
    INNER JOIN [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitabilityCandidateApplicableVegZones] AS b
        ON a.[Id] = b.[ID]
    WHERE b.[tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey] IS NOT NULL
    ORDER BY b.[tblAssessmentHabitatSuitabilityCandidateApplicableVegZonesKey]
)
SELECT
    j.JsonChildKey,
    j.JsonParentId,
    j.JsonAssessmentId,
    j.JsonSpeciesId,
    j.JsonUnitOfMeasure,
    j.JsonName,
    j.JsonIsChecked,
    j.JsonCompleteLoss,
    j.JsonAreaForVegZone,
    v.[Id] AS LegacyId,
    v.[HabitatSuitabilityId] AS LegacyHabitatSuitabilityId,
    v.[AssessmentId] AS LegacyAssessmentId,
    v.[SpeciesId] AS LegacySpeciesId,
    v.[UnitOfMeasure] AS LegacyUnitOfMeasure,
    v.[VegZoneName] AS LegacyVegZoneName,
    v.[IsChecked] AS LegacyIsChecked,
    v.[CompleteLoss] AS LegacyCompleteLoss,
    v.[Value] AS LegacyValue
FROM json_candidate_sample AS j
OUTER APPLY (
    SELECT TOP (5)
        v.[Id],
        v.[HabitatSuitabilityId],
        v.[AssessmentId],
        v.[SpeciesId],
        v.[UnitOfMeasure],
        v.[VegZoneName],
        v.[IsChecked],
        v.[CompleteLoss],
        v.[Value]
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS v
    WHERE v.[Id] = j.JsonParentId
    ORDER BY v.[VegZoneName], v.[HabitatSuitabilityId]
) AS v
ORDER BY j.JsonParentId, v.[VegZoneName];
