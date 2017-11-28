USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLocoDetails]    Script Date: 11/28/2017 07:00:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLocoDetails](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT 
		C.TrainId AS trainid,
		SUBSTRING(A.Source, 11, 4) AS locoid,
		'SYMBOL' AS symbol,
		CASE A.HeadEndPTCSubdiv
			WHEN 2 THEN 'POMBAL-GUAIBA'
			WHEN 3 THEN 'LINHA DO CENTRO'
			WHEN 100 THEN 'FERROVIA DO ACO'
			ELSE ''
		END AS route,
		A.MessageTime AS lastcommtime,
		'1900-01-01 00:00:00' AS lastdepttest,
		A.LocomotiveState AS ptcstate,
		A.LocoStateSummary AS ptcs_state,
		A.Speed AS speed,
		A.HeadEndMilepost AS h_mp,
		A.RearEndMilepost AS r_mp,
		CASE A.HeadEndPTCSubdiv
			WHEN 2 THEN 'POMBAL-GUAIBA'
			WHEN 3 THEN 'LINHA DO CENTRO'
			WHEN 100 THEN 'FERROVIA DO ACO'
			ELSE ''
		END AS sub,
		A.DirectionOfTravel AS direction,
		C.SoftwareVer AS sw_version,
		'MRS' AS emprr,
		'MRS' AS o_rr,
		99 AS activefaultcount,
		'Ready' AS bosreadiness,
		'Ready' AS locoreadiness,
		A.HeadEndPositionLat AS he_lat,
		A.HeadEndPositionLon AS he_lon,
		'MRS' AS railroad,
		CASE A.HeadEndPTCSubdiv
			WHEN 2 THEN 'POMBAL-GUAIBA'
			WHEN 3 THEN 'LINHA DO CENTRO'
			WHEN 100 THEN 'FERROVIA DO ACO'
			ELSE ''
		END AS region,
		C.EmpLastName + ', ' + C.EmpFirstName AS engineer 
	FROM (
		SELECT
			*, ROW_NUMBER() OVER (PARTITION BY Source ORDER BY MessageTime DESC) AS ROWNUM
		FROM 
			tblOCM2080Log WITH (NOLOCK)
		WHERE 
			MessageTime >= @StartDate AND MessageTime <= @EndDate
	) A
	OUTER APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2003Log B WITH (NOLOCK)
			WHERE 
				B.Source = A.Source 
				AND DATEDIFF(SECOND, B.MessageTime, A.MessageTime) >= 0
			ORDER BY DATEDIFF(SECOND, B.MessageTime, A.MessageTime) ASC
		) C
	WHERE A.ROWNUM = 1
);

GO

