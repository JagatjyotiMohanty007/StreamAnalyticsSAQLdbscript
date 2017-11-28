USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetTrackBlocks]    Script Date: 11/28/2017 07:04:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fnGetTrackBlocks]()
RETURNS TABLE
AS
RETURN (
	SELECT A.EventSource AS Desk, A.ComponentsList AS TrackBlock, A.StationName AS ControlPoint, A.EventTime AS CreationDate
	FROM tblSTMSTrackBlockEventLog A
	WHERE A.EventType = 'CREATED'
	AND NOT EXISTS
		(
			SELECT 1 
			FROM tblSTMSTrackBlockEventLog B
			WHERE B.AuthNumber = A.AuthNumber
			AND B.EventType = 'DELETED'
			AND B.EventTime > A.EventTime
		)
)

GO

