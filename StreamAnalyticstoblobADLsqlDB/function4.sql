USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetCrewDispatcherMessages]    Script Date: 11/28/2017 06:59:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetCrewDispatcherMessages](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT 
		C.TrainId AS TrainId,
		SUBSTRING(A.Source, 11, 4) AS LocoId,
		A.MessageTime AS Time,
		'Office' AS Sender,
		A.Message AS Message
	FROM tblOCM1303Log A WITH (NOLOCK)
	OUTER APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2003Log B WITH (NOLOCK)
			WHERE 
				B.Source = A.Source 
				AND DATEDIFF(SECOND, B.MessageTime, A.MessageTime) >= 0
			ORDER BY DATEDIFF(SECOND, B.MessageTime, A.MessageTime) ASC
		) C
	WHERE A.MessageTime >= @StartDate AND A.MessageTime <= @EndDate

	UNION ALL

	SELECT 
		C.TrainId AS TrainId,
		SUBSTRING(A.Source, 11, 4) AS LocoId,
		A.MessageTime AS Time,
		'Crew' AS Sender,
		A.Message AS Message
	FROM tblOCM2301Log A WITH (NOLOCK)
	OUTER APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2003Log B WITH (NOLOCK)
			WHERE 
				B.Source = A.Source 
				AND DATEDIFF(SECOND, B.MessageTime, A.MessageTime) >= 0
			ORDER BY DATEDIFF(SECOND, B.MessageTime, A.MessageTime) ASC
		) C
	WHERE A.MessageTime >= @StartDate AND A.MessageTime <= @EndDate
);

GO

