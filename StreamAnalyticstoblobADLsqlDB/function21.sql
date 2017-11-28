USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetStoredLicenseReport]    Script Date: 11/28/2017 07:04:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetStoredLicenseReport](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT EventSource AS Desk, TerritoryName AS TerrUID, StationName AS ControlPoint, EventTime AS CreateTime, EventType AS EventType,
	Priority AS Priority, REPLACE(ComponentList, ',', ';') AS ComponentSelection, SymbolAssociation AS TrainSymbol, EntrySignal AS EntrySignal,
	ExitSignal AS ExitSignal, REPLACE(UserName, ',', ';') AS DispatcherName
	FROM dbo.tblSTMSStoredRouteEventLog
	WHERE EventTime >= @StartDate AND EventTime <= @EndDate
)

GO

