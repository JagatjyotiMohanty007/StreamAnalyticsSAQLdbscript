USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetSplLicensesExecuted]    Script Date: 11/28/2017 07:03:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetSplLicensesExecuted](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT EventSource AS Desk, AuthNumber AS AuthorityNumber, REPLACE(UserName, ',', ';') AS DispatcherName, EventTime AS AuthTimeStamp, EventType AS AuthType, 
	LocoLead AS LocoLead, REPLACE(AuthComponents, ',', ';') AS Components, TrainSymbol AS TrainSymbol, REPLACE(AuthText,',', ';') AS PTCAuthorityText, 
	AuthDirection AS AuthorityDirection
	FROM tblTMDSSplLicenseEventLog
	WHERE EventTime >= @StartDate AND EventTime <= @EndDate
);

GO

