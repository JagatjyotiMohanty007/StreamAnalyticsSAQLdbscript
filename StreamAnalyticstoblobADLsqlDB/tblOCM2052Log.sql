USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2052Log]    Script Date: 11/28/2017 07:15:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2052Log](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[PTCAuthorityRefNum] [int] NULL,
	[AckIndication] [nvarchar](50) NULL
)

GO

