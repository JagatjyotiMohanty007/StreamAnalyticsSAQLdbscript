USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLocoRunDistance]    Script Date: 11/28/2017 07:02:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLocoRunDistance](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (
	SELECT 
		'TRAIN' AS trainid,
		SUBSTRING(A.Source, 11, 4) AS locoid,
		A.RunDate AS rundate,
		A.Distance AS distance,
		'Active' AS ptcstate,
		'MRS' AS railroad,
		'POMBAL-GUAIBA' AS region,
		'DOE, JOHN' AS engineer
	FROM
		tblOCM2080LogPosCal A
	WHERE
		A.RunDate >= @StartDate AND A.RunDate <= @EndDate
);

GO

