USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2301Log]    Script Date: 11/28/2017 07:18:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2301Log](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[Recipient] [nvarchar](64) NULL,
	[Message] [nvarchar](160) NULL
)

GO

