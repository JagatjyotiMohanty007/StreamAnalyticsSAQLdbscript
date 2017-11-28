USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetLocoFaultReport]    Script Date: 11/28/2017 07:01:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetLocoFaultReport](@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN (

	SELECT 
	A.UGUID AS [Uniqueid]
	,C.TrainId AS TrainId
	,A.LocoID AS LocoID
	,A.[LocoStateSummary]
	,A.[LocoState] AS [LocoState]
	,A.[NoOfComps] AS [NoOfComps]
	,A.[Component] AS [Component]
	,A.faultCount AS faultCount
	,A.[faultState] AS [faultState]
	,A.[faultCode] AS [faultCode]
	,A.[faultNameText] AS [faultNameText]
	,A.faultTime AS faultTime
	FROM (
	SELECT 
	A.UGUID
	,A.MessageTime
	,A.Source
	,SUBSTRING( A.[Source], 11,4) AS LocoID
	,[LocoStateSummary] AS [LocoStateSummary]
	,[LocoState] AS [LocoState]
	,[NoOfComps] AS [NoOfComps]
	,[Component] AS Component
	,[NoOfFaultChngs] AS faultCount
	,ISNULL([FaultState],'' )AS [faultState]
	,ISNULL(CAST ([FaultCode] AS VARCHAR(20)) ,'' )  AS [faultCode]
	,ISNULL([FaultName],' ' )AS [faultNameText]
	,ISNULL(CONVERT(VARCHAR(30),[FaultDetectedTime],121),'') as faultTime
	FROM [dbo].[tblOCM2087Log] AS A WITH (NOLOCK)
	WHERE MessageTime >= @StartDate AND MessageTime <= @EndDate
	AND [NoOfFaultChngs] > 0
	) AS A 
    OUTER APPLY
	(
		SELECT TOP 1 * 
		FROM tblOCM2003Log B WITH (NOLOCK)
		WHERE 
			B.Source = A.Source 
			AND DATEDIFF(SECOND, B.MessageTime, A.MessageTime) >= 0
		ORDER BY DATEDIFF(SECOND, B.MessageTime, A.MessageTime) ASC
	) C 
)
GO

