USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[TMCRawLogs]    Script Date: 11/28/2017 07:22:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TMCRawLogs](
	[Date_Val] [nvarchar](50) NULL,
	[Time_Val] [nvarchar](50) NULL,
	[Failure] [nvarchar](50) NULL,
	[LocoID] [nvarchar](50) NULL,
	[FailureCode] [nvarchar](50) NULL,
	[FailureType] [nvarchar](50) NULL,
	[DateTime_Val] [datetime] NULL,
	[MessageType] [nvarchar](50) NULL
)

GO

