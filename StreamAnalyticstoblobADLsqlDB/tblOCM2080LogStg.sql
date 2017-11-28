USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2080LogStg]    Script Date: 11/28/2017 07:17:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2080LogStg](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[CurrentPTCRefNum] [bigint] NULL,
	[HeadEndMilepost] [bigint] NULL,
	[HeadEndTrackName] [nvarchar](32) NULL,
	[RearEndMilepost] [bigint] NULL,
	[RearEndTrackName] [nvarchar](32) NULL,
	[DirectionOfTravel] [nvarchar](30) NULL,
	[HeadEndPTCSubdiv] [int] NULL,
	[HeadEndPositionLat] [decimal](19, 16) NULL,
	[HeadEndPositionLon] [decimal](19, 16) NULL
)

GO

