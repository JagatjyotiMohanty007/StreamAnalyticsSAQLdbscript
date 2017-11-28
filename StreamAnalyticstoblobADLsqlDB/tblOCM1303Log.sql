USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM1303Log]    Script Date: 11/28/2017 07:14:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM1303Log](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[Sender] [nvarchar](64) NULL,
	[Message] [nvarchar](160) NULL
)

GO

