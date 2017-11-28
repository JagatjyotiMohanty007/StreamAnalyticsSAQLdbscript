USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetRunningTrains]    Script Date: 11/28/2017 07:03:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetRunningTrains]()
RETURNS TABLE
AS
RETURN (
	WITH tblTMDSTrainEventLogDD AS (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY EventTime, EventType ORDER BY EventTime, EventType) AS ROWNUM
			FROM tblTMDSTrainEventLog WITH (NOLOCK)
		) T WHERE ROWNUM = 1
	)
	SELECT A.EventSource, A.TrainSymbol, A.CtrlPointName, A.TrackName--, A.EventTime, A.TerritoryName
	FROM tblTMDSTrainEventLogDD A WITH (NOLOCK)
	WHERE A.EventType = 'CREATED'
	-- REVIEW: eliminate LONG RUNNING trains
	AND NOT EXISTS 
		(
			SELECT 1 
			FROM tblTMDSTrainEventLogDD WITH (NOLOCK)
			WHERE TrainSymbol = A.TrainSymbol
			AND EventType = 'DELETED'
			AND EventTime >= A.EventTime
		)
	AND EXISTS 
		(
			SELECT 1
			FROM tblOCM2003Log WITH (NOLOCK)
			WHERE TrainId = A.TrainSymbol
			AND ReasonForSending = 'Initialization'
			AND MessageTime >= A.EventTime
		)
);

GO

