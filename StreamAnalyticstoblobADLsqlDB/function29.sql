USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetTrainRunDashboardData]    Script Date: 11/28/2017 07:05:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


----------------------------------------------
----------------------------------------------
CREATE FUNCTION [dbo].[fnGetTrainRunDashboardData](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT
		TrainSymbol AS trainId, 
		LocoList AS locomotiveId, 
		SoftwareVerList AS onboardSoftwareVersion, 
		DepLoc AS departureLocation, 
		DepLocMilepost AS departureLocationMP, 
		FirstInitTime AS initializationDateTime, 
		FirstLicenseTime AS firstLicenseDateTime, 
		DepTime AS departureDateTime, 
		AssocTime AS associationDateTime, 
		DisassocTime AS disassociationDateTime, 
		DepDelay AS delay, 
		ArrLoc AS arrivalLocation, 
		ArrTime AS arrivalDateTime, 
		ActiveDuration AS activeTime, 
		TrainRunState AS trainRunState,
		LocomotiveState AS locoState,
		LocoStateSummary AS locostatesummery, --typo intentional
		EnfCount AS enforcementcount,
		InitCount AS InitializationCount,
		EngineerNameList AS listofempidentifier
	FROM dbo.fnGetTrainRuns(@StartDate, @EndDate)
);

GO

