USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLORDEnforcements]    Script Date: 11/28/2017 07:03:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLORDEnforcements](@StartDate DATETIME, @EndDate DATETIME)
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
		A.TrainId AS trainid,
		SUBSTRING(A.Source, 11, 4) AS locoid,
		A.MessageTime AS messageTime,
		A.WarnEnfType AS Warning_Enforcement_Type,
		A.SoftwareVer AS Onboard_Software_Version,
		A.TrgtTargetType AS target_Type,
		A.TrgtTargetDesc AS target_Description,
		CASE 
			WHEN (A.WarnEnfType = 'Predictive Enforcement' OR A.WarnEnfType = 'Reactive Enforcement') THEN A.EnfStartTrackName
			ELSE A.WarnStartTrackName
		END AS Start_Track_Name,
		CASE (CASE WHEN (A.WarnEnfType = 'Predictive Enforcement' OR A.WarnEnfType = 'Reactive Enforcement') THEN A.EnfPTCSubdiv
				ELSE A.WarnPTCSubdiv 
				END)
			WHEN 2 THEN 'POMBAL-GUAIBA'
			WHEN 3 THEN 'LINHA DO CENTRO'
			WHEN 100 THEN 'FERROVIA DO ACO'
			ELSE ''
		END AS Start_PTC_Subdiv,
		CASE 
			WHEN (A.WarnEnfType = 'Predictive Enforcement' OR A.WarnEnfType = 'Reactive Enforcement') THEN A.EnfTrainSpeed
			ELSE A.WarnTrainSpeed
		END AS Train_Speed,
		CASE 
			WHEN (A.WarnEnfType = 'Predictive Enforcement' OR A.WarnEnfType = 'Reactive Enforcement') THEN A.EnfPosLat
			ELSE A.WarnPosLat
		END AS Pos_Lat,
		CASE 
			WHEN (A.WarnEnfType = 'Predictive Enforcement' OR A.WarnEnfType = 'Reactive Enforcement') THEN A.EnfPosLon
			ELSE A.WarnPosLon
		END AS Pos_Lon,
		'MRS' AS railroad,
		CASE (CASE WHEN (A.WarnEnfType = 'Predictive Enforcement' OR A.WarnEnfType = 'Reactive Enforcement') THEN A.EnfPTCSubdiv
				ELSE A.WarnPTCSubdiv 
				END)
			WHEN 2 THEN 'POMBAL-GUAIBA'
			WHEN 3 THEN 'LINHA DO CENTRO'
			WHEN 100 THEN 'FERROVIA DO ACO'
			ELSE ''
		END AS region,
		A.CurrPosLat AS Current_Lat,
		A.CurrPosLon AS Current_Lon,
		C.LocomotiveState AS ptcstate,
		E.EmpLastName + ', ' + E.EmpFirstName AS engineer
	FROM
		tblOCM2083LogDD A WITH (NOLOCK)
	OUTER APPLY 
		(
			SELECT TOP 1 * 
			FROM tblOCM2080Log B WITH (NOLOCK)
			WHERE B.Source = A.Source
			--AND  B.MessageTime >= A.MessageTime
			ORDER BY ABS(DATEDIFF(SECOND, B.MessageTime, A.MessageTime)) ASC
			--ORDER BY B.MessageTime ASC
		) C
	OUTER APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2003Log D WITH (NOLOCK)
			WHERE 
				D.Source = A.Source 
				AND DATEDIFF(SECOND, D.MessageTime, A.MessageTime) >= 0
			ORDER BY DATEDIFF(SECOND, D.MessageTime, A.MessageTime) ASC
		) E
);

GO

