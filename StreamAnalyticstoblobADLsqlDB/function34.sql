USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetUserNotesReport]    Script Date: 11/28/2017 07:06:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fnGetUserNotesReport](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT EventSource AS Desk, Name AS Title, NoteText AS NoteText, TerritoryName AS TerritoryAssignmentID, 
	EventTime AS CreateTime, REPLACE(UserName, ',', ';') AS DispatcherName, EventType AS EventType
	FROM tblSTMSNoteEventLog
	WHERE EventTime >= @StartDate AND EventTime <= @EndDate
)

GO

