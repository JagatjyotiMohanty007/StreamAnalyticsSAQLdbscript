USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLocoFaults]    Script Date: 11/28/2017 07:01:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLocoFaults](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT
		A.MessageTime AS MessageTime,
		SUBSTRING(A.Source, 11, 4) AS LocoID,
		C.TrainId AS TrainID,           
		C.SoftwareVer AS OnboardID,
		'1900-01-01 00:00:00' AS AssociationDatetime,
		'N/A' AS DepartureTime,
		A.FaultState AS FaultStatus,
		A.Component AS FaultSource,
		A.FaultCode AS FaultCode,
		A.FaultName AS FaultDescription,
		E.HeadEndPositionLat AS Latitude,
		E.HeadEndPositionLon AS Longitude,
		'Active' AS TrainRunState
	FROM 
		tblOCM2087Log A WITH (NOLOCK)
	OUTER APPLY
		(
			SELECT TOP 1 * 
			FROM tblOCM2003Log B WITH (NOLOCK)
			WHERE 
				B.Source = A.Source 
				AND DATEDIFF(SECOND, B.MessageTime, A.MessageTime) >= 0
			ORDER BY DATEDIFF(SECOND, B.MessageTime, A.MessageTime) ASC
		) C
	OUTER APPLY 
		(
			SELECT TOP 1 * 
			FROM tblOCM2080Log D WITH (NOLOCK)
			WHERE D.Source = A.Source
			ORDER BY ABS(DATEDIFF(SECOND, D.MessageTime, A.MessageTime)) ASC
		) E
	WHERE
		A.MessageTime >= @StartDate AND A.MessageTime <= @EndDate
		AND A.FaultState IS NOT NULL --check for fault record
);

GO

