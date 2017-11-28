USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLoggedInUsers]    Script Date: 11/28/2017 07:02:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLoggedInUsers]()
RETURNS TABLE
AS
RETURN (
	SELECT 
		A.EventSource AS Desk, 
		C.UserName AS DispatcherName, 
		C.EventTime AS LoginTime, 
		DATEDIFF(MINUTE, C.EventTime, GETUTCDATE()) AS ActivePeriod
	FROM
		(
			SELECT DISTINCT EventSource
			FROM tblSTMSDispatcherEventLog
		) A
	CROSS APPLY 
		(
			SELECT TOP 1 *
			FROM tblSTMSDispatcherEventLog B
			WHERE B.EventSource = A.EventSource
			ORDER BY EventTime DESC
		) C
	WHERE C.EventType = 'ONDUTY'
)

GO

