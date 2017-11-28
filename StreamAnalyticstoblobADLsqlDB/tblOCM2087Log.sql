USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2087Log]    Script Date: 11/28/2017 07:18:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2087Log](
	[UGUID] [nvarchar](50) NULL,
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[ICDVersion] [nvarchar](20) NULL,
	[VendorCode] [nvarchar](4) NULL,
	[SystemCode] [nvarchar](4) NULL,
	[LocoStateTime] [datetime] NULL,
	[LocoStateSummary] [nvarchar](20) NULL,
	[LocoState] [nvarchar](20) NULL,
	[NoOfComps] [int] NULL,
	[Component] [int] NULL,
	[NoOfFaultChngs] [int] NULL,
	[FaultState] [nvarchar](20) NULL,
	[FaultCode] [int] NULL,
	[FaultName] [nvarchar](64) NULL,
	[FaultDetectedTime] [datetime] NULL
)

GO

