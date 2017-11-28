USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnDummy]    Script Date: 11/28/2017 06:58:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnDummy]()
RETURNS TABLE
AS
RETURN (
	SELECT [Name] FROM [dbo].[Table_1]
);

GO

