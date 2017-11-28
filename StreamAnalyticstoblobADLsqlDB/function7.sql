USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLicensesExecuted]    Script Date: 11/28/2017 07:00:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLicensesExecuted](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT EventSource AS Desk, AuthNumber AS AuthorityNumber, REPLACE(UserName, ',', ';') AS DispatcherName, EventTime AS AuthTimeStamp, EventType AS AuthType, 
	LocoLead AS LocoLead, REPLACE(AuthComponents, ',', ';') AS Components, TrainSymbol AS TrainSymbol, REPLACE(AuthText,',', ';') AS PTCAuthorityText, 
	AuthDirection AS AuthorityDirection
	FROM tblTMDSLicenseEventLog
	WHERE EventTime >= @StartDate AND EventTime <= @EndDate
);

GO

