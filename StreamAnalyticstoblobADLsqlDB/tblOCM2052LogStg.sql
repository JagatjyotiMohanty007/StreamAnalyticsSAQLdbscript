USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2052LogStg]    Script Date: 11/28/2017 07:16:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2052LogStg](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[PTCAuthorityRefNum] [int] NULL,
	[AckIndication] [nvarchar](50) NULL
)

GO

