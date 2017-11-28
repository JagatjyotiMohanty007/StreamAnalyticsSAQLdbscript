USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetStoredLicenses]    Script Date: 11/28/2017 07:04:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- *******************************************************************************************
CREATE   FUNCTION [dbo].[fnGetStoredLicenses]()
RETURNS TABLE
AS
RETURN (
	SELECT A.EventSource AS Desk, A.RouteGUID AS LicenseID, A.SymbolAssociation AS TrainSymbol, A.EventTime AS CreationDate
	FROM tblSTMSStoredRouteEventLog A
	WHERE A.EventType = 'CREATED'
	AND NOT EXISTS
		(
			SELECT 1 
			FROM tblSTMSStoredRouteEventLog B
			WHERE B.RouteGUID = A.RouteGUID
			AND B.EventType = 'DELETED'
			AND B.EventTime > A.EventTime
		)
)

GO

