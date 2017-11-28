USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetInitSuccess]    Script Date: 11/28/2017 06:59:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetInitSuccess](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT 
		C.TrainId AS trainid,
		SUBSTRING(A.Source, 11, 4) AS locoid,
		A.MessageTime AS initTime,
		E.LocomotiveState AS ptcstate,
		'MRS' AS railroad,
		CASE E.HeadEndPTCSubdiv
			WHEN 2 THEN 'POMBAL-GUAIBA'
			WHEN 3 THEN 'LINHA DO CENTRO'
			WHEN 100 THEN 'FERROVIA DO ACO'
			ELSE ''
		END AS region,
		C.EmpLastName + ', ' + C.EmpFirstName AS engineer
	FROM tblOCM2005Log A WITH (NOLOCK)
	CROSS APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2003Log B WITH (NOLOCK)
			WHERE 
				B.Source = A.Source 
				AND B.ReasonForSending = 'Initialization'
				AND DATEDIFF(SECOND, A.MessageTime, B.MessageTime) BETWEEN 0 AND 300 
			ORDER BY DATEDIFF(SECOND, A.MessageTime, B.MessageTime) ASC
		) C
	CROSS APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2080Log D WITH (NOLOCK)
			WHERE 
				D.Source = C.Source 
				AND D.LocomotiveState = 'Disengaged'
				AND DATEDIFF(SECOND, C.MessageTime, D.MessageTime) BETWEEN 0 AND 1200 
			ORDER BY DATEDIFF(SECOND, C.MessageTime, D.MessageTime) 
		) E
	WHERE A.MessageTime >= @StartDate AND A.MessageTime <= @EndDate

	UNION

	SELECT 
		C.TrainId AS trainid,
		SUBSTRING(A.Source, 11, 4) AS locoid,
		A.MessageTime AS initTime,
		E.LocomotiveState AS ptcstate,
		'MRS' AS railroad,
		CASE E.HeadEndPTCSubdiv
			WHEN 2 THEN 'POMBAL-GUAIBA'
			WHEN 3 THEN 'LINHA DO CENTRO'
			WHEN 100 THEN 'FERROVIA DO ACO'
			ELSE ''
		END AS region,
		C.EmpLastName + ', ' + C.EmpFirstName AS engineer
	FROM tblOCM2005Log A WITH (NOLOCK)
	CROSS APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2003Log B WITH (NOLOCK)
			WHERE 
				B.Source = A.Source 
				AND B.ReasonForSending = 'Initialization'
				AND DATEDIFF(SECOND, A.MessageTime, B.MessageTime) BETWEEN 0 AND 300 
			ORDER BY DATEDIFF(SECOND, A.MessageTime, B.MessageTime) ASC
		) C
	CROSS APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2080Log D WITH (NOLOCK)
			WHERE 
				D.Source = C.Source 
				AND (D.LocomotiveState = 'Cut Out' OR D.LocomotiveState = 'Failed')
				AND DATEDIFF(SECOND, C.MessageTime, D.MessageTime) BETWEEN 0 AND 1200 
			ORDER BY DATEDIFF(SECOND, C.MessageTime, D.MessageTime) 
		) E
	WHERE A.MessageTime >= @StartDate AND A.MessageTime <= @EndDate
);

GO

