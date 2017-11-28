USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2080Log]    Script Date: 11/28/2017 07:16:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2080Log](
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
	[HeadEndPositionLon] [decimal](19, 16) NULL,
	[LocomotiveState] [nvarchar](20) NULL,
	[Speed] [int] NULL,
	[ReasonForReport] [nvarchar](60) NULL,
	[LocoStateSummary] [nvarchar](20) NULL
)

GO

