USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2080LogPosCal]    Script Date: 11/28/2017 07:16:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2080LogPosCal](
	[LastMessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[LastHeadEndPositionLat] [decimal](19, 16) NULL,
	[LastHeadEndPositionLon] [decimal](19, 16) NULL,
	[Distance] [decimal](25, 16) NULL,
	[RunDate] [date] NULL
)

GO

