USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetTrainSymbolCreateUpdates]    Script Date: 11/28/2017 07:06:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetTrainSymbolCreateUpdates](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT EventTime AS DateTime, EventSource AS Desk, TrainSymbol AS TrainSymbol, EventType AS Type, LocoLead AS EngineID, REPLACE(UserName, ',', ';') AS DispatcherName,
    '' AS TerritoryAssignmentID, TrainDirection AS Direction, TrainUnits AS Units, NumCarsLoad AS OLoads, NumCarsEmpty AS OEmts, TrainTon AS OTons, 
    TrainLength AS OLength, MaxSpeed AS MaxSpd, NumOperAxles AS TonsPerOperativeBrake, PTCStatus AS PTCStatus
    FROM tblTMDSTrainEventLog
    WHERE EventTime >= @StartDate AND EventTime <= @EndDate
    AND (EventType = 'CREATED' OR EventType = 'UPDATED')
);

GO

