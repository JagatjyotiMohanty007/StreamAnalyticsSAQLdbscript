USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLocoHealth]    Script Date: 11/28/2017 07:01:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLocoHealth](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT locoid, trainid, faultTime, faultCat, railroad, region, ptcstate, engineer, count(*) faultCount
	FROM (
		SELECT
			A.LocoID AS locoid,
			E.TrainId AS trainid,
			CONVERT(DATE, A.TMCMessageTime) AS faultTime,
			CASE A.FaultCode
				WHEN '0746' THEN 'Invalid DIO Input'
				WHEN '0702' THEN 'Triplex Mismatch'
				WHEN '0741' THEN 'Incorrect Consist'
				WHEN '0680' THEN 'Invalid EBI Data'
				WHEN '0628' THEN 'Invalid	EAB Comm Loss (LIG)'
				WHEN '0620' THEN 'Others'
				WHEN '065B' THEN 'Others'
				WHEN '0740' THEN 'Triplex Mismatch'
				WHEN '0152' THEN 'Invalid EBI Data'
				WHEN '0650' THEN 'Invalid DIO Input'
				ELSE 'Others'
			END AS faultCat,
			'MRS' AS railroad,
			'POMBAL-GUAIBA' AS region,
			'Failed' AS ptcstate,
			/*CASE C.HeadEndPTCSubdiv
				WHEN 2 THEN 'POMBAL-GUAIBA'
				WHEN 3 THEN 'LINHA DO CENTRO'
				WHEN 100 THEN 'FERROVIA DO ACO'
				ELSE ''
			END AS region,
			C.LocomotiveState AS ptcstate,*/
			E.EmpLastName + ', ' + E.EmpFirstName AS engineer
		FROM
			tblTMCFLTLog A WITH (NOLOCK)
			OUTER APPLY 
				(
					SELECT TOP 1 * 
					FROM tblOCM2080Log B WITH (NOLOCK)
					WHERE B.Source = A.Source
					ORDER BY ABS(DATEDIFF(SECOND, B.MessageTime, A.TMCMessageTime)) ASC
				) C
			OUTER APPLY
				(
					SELECT TOP 1 * 
					FROM tblOCM2003Log D WITH (NOLOCK)
					WHERE 
						D.Source = A.Source 
						AND DATEDIFF(SECOND, D.MessageTime, A.TMCMessageTime) >= 0
					ORDER BY DATEDIFF(SECOND, D.MessageTime, A.TMCMessageTime) ASC
				) E
		WHERE 
			A.TMCMessageTime >= '2017-09-14 00:00:00' AND A.TMCMessageTime <= '2017-10-15 15:30:00'
			AND (A.FaultStatus = 'Active' OR A.FaultStatus = 'Intermittent')
			AND A.FaultSource NOT IN ('GPS1', 'GPS2')
	) T
	GROUP BY locoid, trainid, faultTime, faultCat, railroad, region, ptcstate, engineer
);

GO

