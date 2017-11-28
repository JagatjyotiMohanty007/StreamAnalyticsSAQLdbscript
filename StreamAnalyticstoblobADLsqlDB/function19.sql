USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetSpeedRestrictionsReport]    Script Date: 11/28/2017 07:03:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fnGetSpeedRestrictionsReport](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT EventSource AS Desk, TerritoryName AS TerritoryID, REPLACE(UserName, ',', ';') AS DispatcherName, EventType AS EventType,
	EventTime AS DateTime, ReasonText AS DataString, CtrlPointName AS CtrlPointName, TrackName AS TrackName
	FROM tblTMDSSpeedRestrictionEventLog
	WHERE EventTime >= @StartDate AND EventTime <= @EndDate
)

GO

