USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLocoEnforcements]    Script Date: 11/28/2017 07:00:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLocoEnforcements](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	WITH tblOCM2083LogDD AS (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY MessageTime, Source ORDER BY MessageTime) AS ROWNUM FROM tblOCM2083Log 
			WHERE (WarnEnfType = 'Predictive Enforcement' OR WarnEnfType = 'Reactive Enforcement')
			AND MessageTime >= @StartDate AND MessageTime <= @EndDate
		) T WHERE ROWNUM = 1
	)
	SELECT
		A.TrainId AS trainID,
		SUBSTRING(A.Source, 11, 4) AS locoID,
		A.Source AS OnboardID,
		CASE
			WHEN A.WarnEnfType = 'Predictive Enforcement' OR A.WarnEnfType = 'Reactive Enforcement' THEN 'Enforcement'
			ELSE 'Warning'
		END AS warningEnforcement,
		A.MessageTime AS warning_enforcement_date_time,
		A.WarnEnfType AS warnEnforcementType,
		A.SoftwareVer AS OnboardSoftwareVersion,
		'Active' AS trainStatus,
		A.TrgtTargetType AS targetType,
		A.TrgtTargetDesc AS targetDescription,
		CASE 
			WHEN A.TrgtTargetType = 'Track device' AND A.TrgtTargetDesc = 'SWITCH ALIGNMENT' THEN 'True'
			WHEN A.TrgtTargetType = 'Form based authority' AND B.MessageTime IS NULL THEN 'True'
			WHEN A.TrgtTargetType = 'Form based authority' AND B.MessageTime IS NOT NULL 
				AND ((B.AuthSegStartingMilepost - B.AuthSegEndingMilepost > 0 AND A.EnfDirectionOfTravel = 'Decreasing Mileposts')
				OR (B.AuthSegStartingMilepost - B.AuthSegEndingMilepost <= 0 AND A.EnfDirectionOfTravel = 'Increasing Mileposts'))
				THEN 'True'
			ELSE 'False'
		END AS legitimateEnforcement,
		A.TrgtStartMilepost AS targetStartMilepost,
		A.TrgtStartTrackName AS targetStartTrackName,
		A.TrgtEndMilepost AS targetEndMilepost,
		A.TrgtEndTrackName AS targetEndTrackName,
		A.TrgtTargetSpeed AS targetSpeed,
		A.WarnTime AS warning_date_time,
		A.WarnStartMilepost AS warningStartMilepost,
		A.WarnStartTrackName AS warningStartTrackName,
		A.WarnDistance AS warningDistance,
		A.WarnDirectionOfTravel AS warningDirectionOfTravel,
		A.WarnTrainSpeed AS warningTrainSpeed,
		A.MessageTime AS enforcement_date_time,
		A.EnfStartMilepost AS enforcementStartMilepost,
		A.EnfStartTrackName AS enforcementStartTrackName,
		A.EnfBrakingDistance AS enforcementBrakingDistance,
		A.EnfDirectionOfTravel AS enforcementDirectionOfTravel,
		A.EnfTrainSpeed AS enforcementTrainSpeed,
		A.MessageTime AS emergencyBraking_date_time,
		A.BrkStartMilepost AS emergencyStartMilepost,
		A.BrkStartTrackName AS emergencyStartTrackName,
		A.BrkBrakingDistance AS emergencyBrakingDistance,
		A.BrkDirectionOfTravel AS emergencyDirectionOfTravel,
		A.BrkTrainSpeed AS emergencyTrainSpeed,
		A.CurrTime AS current_date_time,
		A.CurrMilepost AS currentMilepost,
		A.CurrTrackName AS currentTrackName,
		A.CurrDirectionOfTravel AS currentDirectionOfTravel,
		A.CurrTrainSpeed AS currentTrainSpeed
	FROM
		tblOCM2083LogDD A
	OUTER APPLY 
		(
			SELECT TOP 1 * 
			FROM tblOCM1051Log C 
			WHERE 
				C.Source = A.Source 
				AND DATEDIFF(SECOND, C.MessageTime, A.MessageTime) BETWEEN 0 AND 86400 
			ORDER BY DATEDIFF(SECOND, C.MessageTime, A.MessageTime) ASC
		) B
);

GO

