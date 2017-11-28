USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLoginLogoffReport]    Script Date: 11/28/2017 07:02:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLoginLogoffReport](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT UserName AS DispatcherName, EventType AS Event, EventTime AS EventTime,
	TerritoryList AS TerritoryID, EventSource AS WorkstationID
	FROM tblSTMSDispatcherEventLog
	WHERE EventTime >= @StartDate AND EventTime <= @EndDate
)

GO

