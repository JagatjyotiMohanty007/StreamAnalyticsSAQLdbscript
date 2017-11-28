USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetTrackBlockReport]    Script Date: 11/28/2017 07:04:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------
CREATE   FUNCTION [dbo].[fnGetTrackBlockReport](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT EventSource AS Desk,AuthNumber AS AuthorityNumber, REPLACE(UserName, ',', ';') AS DispatcherName, EventTime AS CreateDate, EventType AS AuthorityType,
	IssueTo AS IssueTo, REPLACE(ComponentsList, ',', ';') AS Components, BlockNotes AS BlockNotes, TerritoryName AS TerritoryAssignment
	FROM tblSTMSTrackBlockEventLog
	WHERE EventTime >= @StartDate AND EventTime <= @EndDate
)

GO

