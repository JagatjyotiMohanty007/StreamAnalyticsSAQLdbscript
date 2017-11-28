USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetFormBasedEnforcements]    Script Date: 11/28/2017 06:59:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ##########################################################
-- Form based enforcement
-- ##########################################################
CREATE FUNCTION [dbo].[fnGetFormBasedEnforcements](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	WITH tblOCM2083LogDD AS (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY MessageTime, Source ORDER BY MessageTime) AS ROWNUM FROM tblOCM2083Log 
			WHERE (WarnEnfType = 'Predictive Enforcement' OR WarnEnfType = 'Reactive Enforcement')
			AND TrgtTargetType = 'Form based authority'
			AND MessageTime >= @StartDate AND MessageTime <= @EndDate
		) T WHERE ROWNUM = 1
	)
	SELECT * FROM (
		SELECT 
			A.TrainId AS TrainID,
			SUBSTRING(A.Source, 11, 4) AS locoID,
			A.EnfStartMilepost AS enforcementStartMilepost,
			A.EnfStartTrackName AS enforcementStartTrackName,
			A.TrgtTargetDesc AS targetDescription,
			A.TrgtStartMilepost AS targetStartMilepost,
			A.TrgtStartTrackName AS targetStartTrackName,
			A.TrgtEndMilepost AS targetEndMilepost,
			A.TrgtEndTrackName AS targetEndTrackName,
			A.EnfBrakingDistance AS enforcementBrakingDistance,
			A.EnfDirectionOfTravel AS enforcementDirectionOfTravel,
			A.CurrTime AS enforcementTime,
			A.TrgtTargetSpeed AS targetSpeed,
			A.WarnTrainSpeed AS warningTrainSpeed,
			A.EnfTrainSpeed AS enforcementTrainSpeed,
			A.CurrTrainSpeed AS currentTrainSpeed,
			H.MessageTime AS authorityTime,
			H.PTCAuthorityRefNum AS authorityPTCAuthorityReferenceNumber,
			H.AuthorityType AS authorityType,
			H.NoOfAuthSegments AS numberOfAuthoritySegments,
			H.AuthSegStartingMilepost AS authorityStartMilepost,
			H.AuthSegEndingMilepost AS authorityEndMilepost,
			H.AuthSegTrackName AS authorityTrackName,
			H.SummaryTextLen AS sizeOfSummaryText,
			H.SummaryText AS bodyOfSummaryText,
			'Body of text' AS bodyOfText,
			C.MessageTime AS locoPositionTime,
			C.CurrentPTCRefNum AS locoPositionAuthorityReference,
			C.HeadEndMilepost AS headEndMilepost,
			C.HeadEndTrackName AS headEndTrackName,
			C.RearEndMilepost AS rearEndMilepost,
			C.RearEndTrackName AS rearEndTrackName,
			C.DirectionOfTravel AS directionOfTravel,
			J.MessageTime AS confirmationTime,
			J.PTCAuthorityRefNum AS confirmationAuthorityNumber,
			J.AckIndication AS acknowledgementIndication
		FROM 
			tblOCM2083LogDD A
		OUTER APPLY 
			(
				SELECT TOP 1 * 
				FROM tblOCM2080Log B 
				WHERE B.Source = A.Source 
				ORDER BY ABS(DATEDIFF(SECOND, B.MessageTime, A.MessageTime)) ASC
			) C
		OUTER APPLY 
			(
				SELECT TOP 1 * 
				FROM tblOCM1051Log G 
				WHERE 
					G.Source = A.Source 
					AND DATEDIFF(SECOND, G.MessageTime, A.MessageTime) BETWEEN 0 AND 86400 
				ORDER BY DATEDIFF(SECOND, G.MessageTime, A.MessageTime) ASC
			) H
		OUTER APPLY 
			(
				SELECT TOP 1 * 
				FROM tblOCM2052Log I 
				WHERE 
				I.Source = A.Source 
					AND DATEDIFF(SECOND, I.MessageTime, A.MessageTime) >= 0
				ORDER BY DATEDIFF(SECOND, I.MessageTime, A.MessageTime) ASC
			) J
	) K
	WHERE 
		K.authorityTime IS NULL
		OR (K.authorityTime IS NOT NULL
			AND ((K.authorityStartMilepost - K.authorityEndMilepost > 0 AND K.enforcementDirectionOfTravel = 'Decreasing Mileposts')
				OR (K.authorityStartMilepost - K.authorityEndMilepost <= 0 AND K.enforcementDirectionOfTravel = 'Increasing Mileposts')))
);

GO

