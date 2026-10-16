-- BAMC JSON-to-legacy habitat field correspondence (sampled)
--
-- Run in the FLH_Silver SQL endpoint, schema BiodiversityCalDBBAMC.
--
-- Purpose:
--   Quickly test whether the two currently unconsumed JSON child outputs have
--   enough field/grain correspondence to justify a full reconciliation and a
--   proposed recreation of stale direct tables.
--
-- Performance:
--   This intentionally samples 1,000 JSON rows per candidate and uses EXISTS
--   predicates against the legacy tables. It avoids the full-table GROUP BYs
--   used by the earlier version, which were expensive over multi-million-row
--   stale tables. Increase the TOP value only after this sampled result is
--   understood. A sampled match is evidence, not final parity proof.

/*
Block 1: PredictedPresence -> legacy HabitatConfirmation.

Candidate reconstruction:
  suitability.AssessmentId -> legacy AssessmentID
  suitability.SpeciesId    -> legacy SpeciesID
  JSON Presence.Name       -> legacy VegzoneName
  JSON Presence.IsPresent  -> legacy Confirmed
*/
WITH json_presence_sample AS (
    SELECT TOP (1000)
        s.Id AS HabitatSuitabilityId,
        s.AssessmentId,
        s.SpeciesId,
        p.Name AS VegzoneName,
        p.IsPresent AS Confirmed,
        p.PresenceKey
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitabilityPredictedPresence] AS p
    INNER JOIN [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitability] AS s
        ON p.ID = s.Id
    WHERE p.PresenceKey IS NOT NULL
    ORDER BY p.PresenceKey
),
presence_evaluated AS (
    SELECT
        j.*,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatConfirmation] AS l
            WHERE l.AssessmentID = j.AssessmentId
              AND l.SpeciesID = j.SpeciesId
              AND l.VegzoneName IS NOT DISTINCT FROM j.VegzoneName
        ) THEN 1 ELSE 0 END AS HasLegacyParentVegzone,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatConfirmation] AS l
            WHERE l.AssessmentID = j.AssessmentId
              AND l.SpeciesID = j.SpeciesId
              AND l.VegzoneName IS NOT DISTINCT FROM j.VegzoneName
              AND l.Confirmed IS NOT DISTINCT FROM j.Confirmed
        ) THEN 1 ELSE 0 END AS HasExactLegacyFieldMatch
    FROM json_presence_sample AS j
)
SELECT
    COUNT(*) AS SampleRows,
    SUM(HasLegacyParentVegzone) AS RowsWithLegacyParentVegzone,
    SUM(HasExactLegacyFieldMatch) AS RowsWithExactLegacyFieldMatch,
    COUNT(DISTINCT CONCAT(j.AssessmentId, '|', j.SpeciesId, '|', COALESCE(j.VegzoneName, '<NULL>'))) AS DistinctSampleBusinessKeys,
    COUNT(DISTINCT j.PresenceKey) AS DistinctSampleJsonKeys
FROM presence_evaluated AS j;


/*
Block 2: CandidateApplicableVegZones -> legacy HabitatValues.

Identifier interpretation:
  JSON child ID is the parent tblAssessmentHabitatSuitability.Id. This is
  confirmed by the Silver join below. ApplicableVegZoneKey is the JSON child-row
  key, not a legacy integer ID.

Candidate reconstruction:
  JSON child ID / suitability.Id     -> legacy HabitatSuitabilityId
  suitability.AssessmentId           -> legacy AssessmentId
  suitability.SpeciesId              -> legacy SpeciesId
  suitability.UnitOfMeasure          -> legacy UnitOfMeasure
  JSON ApplicableVegZones.Name       -> legacy VegZoneName
  JSON IsChecked                     -> legacy IsChecked
  JSON IsCompleteLossChecked         -> legacy CompleteLoss
  JSON AreaForVegZone                -> legacy Value

The final two mappings are hypotheses under test. The result also tests whether
legacy Id, rather than legacy HabitatSuitabilityId, matches the JSON parent ID.
*/
WITH json_values_sample AS (
    SELECT TOP (1000)
        s.Id AS HabitatSuitabilityId,
        s.AssessmentId,
        s.SpeciesId,
        s.UnitOfMeasure,
        a.Name AS VegZoneName,
        a.IsChecked,
        a.IsCompleteLossChecked AS CompleteLoss,
        CAST(a.AreaForVegZone AS DECIMAL(10, 2)) AS Value,
        a.ApplicableVegZoneKey
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitabilityCandidateApplicableVegZones] AS a
    INNER JOIN [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitability] AS s
        ON a.ID = s.Id
    WHERE a.ApplicableVegZoneKey IS NOT NULL
    ORDER BY a.ApplicableVegZoneKey
),
values_evaluated AS (
    SELECT
        j.*,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS l
            WHERE l.HabitatSuitabilityId = j.HabitatSuitabilityId
              AND l.VegZoneName IS NOT DISTINCT FROM j.VegZoneName
        ) THEN 1 ELSE 0 END AS HasLegacyParentVegzone,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS l
            WHERE l.Id = j.HabitatSuitabilityId
        ) THEN 1 ELSE 0 END AS HasLegacyRowIdMatchesJsonParentId,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS l
            WHERE l.Id = j.HabitatSuitabilityId
              AND l.VegZoneName IS NOT DISTINCT FROM j.VegZoneName
        ) THEN 1 ELSE 0 END AS HasLegacyRowIdAndVegzoneMatch,
        CASE WHEN EXISTS (
            SELECT 1
            FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS l
            WHERE l.HabitatSuitabilityId = j.HabitatSuitabilityId
              AND l.AssessmentId = j.AssessmentId
              AND l.SpeciesId = j.SpeciesId
              AND l.UnitOfMeasure IS NOT DISTINCT FROM j.UnitOfMeasure
              AND l.VegZoneName IS NOT DISTINCT FROM j.VegZoneName
              AND l.IsChecked IS NOT DISTINCT FROM j.IsChecked
              AND l.CompleteLoss IS NOT DISTINCT FROM j.CompleteLoss
              AND l.Value IS NOT DISTINCT FROM j.Value
        ) THEN 1 ELSE 0 END AS HasExactLegacyFieldMatch
    FROM json_values_sample AS j
)
SELECT
    COUNT(*) AS SampleRows,
    SUM(HasLegacyParentVegzone) AS RowsWithLegacyParentVegzone,
    SUM(HasLegacyRowIdMatchesJsonParentId) AS RowsWhereLegacyRowIdMatchesJsonParentId,
    SUM(HasLegacyRowIdAndVegzoneMatch) AS RowsWhereLegacyRowIdAndVegzoneMatch,
    SUM(HasExactLegacyFieldMatch) AS RowsWithExactLegacyFieldMatch,
    COUNT(DISTINCT CONCAT(j.HabitatSuitabilityId, '|', COALESCE(j.VegZoneName, '<NULL>'))) AS DistinctSampleParentVegzoneKeys,
    COUNT(DISTINCT j.ApplicableVegZoneKey) AS DistinctSampleJsonKeys
FROM values_evaluated AS j;


/*
Block 3: paired-row inspection for the corrected values parent identity.

Returns at most 20 JSON child rows and up to five legacy value rows for each,
joined on legacy Id = JSON suitability parent ID. Inspect the relationship of
JSON Name/AreaForVegZone/flags to the legacy fields before proposing a transform.
Do not commit returned business values to the repository.
*/
WITH json_values_sample AS (
    SELECT TOP (20)
        s.Id AS JsonParentSuitabilityId,
        s.AssessmentId AS JsonAssessmentId,
        s.SpeciesId AS JsonSpeciesId,
        s.UnitOfMeasure AS JsonUnitOfMeasure,
        a.Name AS JsonName,
        a.IsChecked AS JsonIsChecked,
        a.IsCompleteLossChecked AS JsonCompleteLoss,
        a.AreaForVegZone AS JsonAreaForVegZone,
        a.ApplicableVegZoneKey
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitabilityCandidateApplicableVegZones] AS a
    INNER JOIN [BiodiversityCalDBBAMC].[tblAssessmentHabitatSuitability] AS s
        ON a.ID = s.Id
    WHERE a.ApplicableVegZoneKey IS NOT NULL
    ORDER BY a.ApplicableVegZoneKey
)
SELECT
    j.JsonParentSuitabilityId,
    j.JsonAssessmentId,
    j.JsonSpeciesId,
    j.JsonUnitOfMeasure,
    j.JsonName,
    j.JsonIsChecked,
    j.JsonCompleteLoss,
    j.JsonAreaForVegZone,
    j.ApplicableVegZoneKey,
    l.Id AS LegacyId,
    l.HabitatSuitabilityId AS LegacyHabitatSuitabilityId,
    l.AssessmentId AS LegacyAssessmentId,
    l.SpeciesId AS LegacySpeciesId,
    l.UnitOfMeasure AS LegacyUnitOfMeasure,
    l.VegZoneName AS LegacyVegZoneName,
    l.IsChecked AS LegacyIsChecked,
    l.CompleteLoss AS LegacyCompleteLoss,
    l.Value AS LegacyValue
FROM json_values_sample AS j
OUTER APPLY (
    SELECT TOP (5)
        l.Id,
        l.HabitatSuitabilityId,
        l.AssessmentId,
        l.SpeciesId,
        l.UnitOfMeasure,
        l.VegZoneName,
        l.IsChecked,
        l.CompleteLoss,
        l.Value
    FROM [BiodiversityCalDBBAMC].[tblAssessmentHabitatValues] AS l
    WHERE l.Id = j.JsonParentSuitabilityId
    ORDER BY l.VegZoneName, l.HabitatSuitabilityId
) AS l
ORDER BY j.JsonParentSuitabilityId, l.VegZoneName;
