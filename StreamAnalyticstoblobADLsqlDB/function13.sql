USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLocoPosition]    Script Date: 11/28/2017 07:02:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLocoPosition](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT
		SUBSTRING(A.Source, 11, 4) AS locoID,
		A.MessageTime AS messageTime,
		'MRS' AS railroadSCAC,
		A.HeadEndTrackName AS headEndTrackName,
		A.HeadEndPTCSubdiv AS headEndPTCSubdiv,
		A.HeadEndMilepost AS headEndMilepost,
		HeadEndPositionLat AS headEndCurrentPositionLat,
		HeadEndPositionLon AS headEndCurrentPositionLon,
		DirectionOfTravel AS directionOfTravel,
		LocomotiveState AS locomotiveState
	FROM 
		tblOCM2080Log A
	WHERE
		A.MessageTime >= @StartDate AND A.MessageTime <= @EndDate
);

GO

