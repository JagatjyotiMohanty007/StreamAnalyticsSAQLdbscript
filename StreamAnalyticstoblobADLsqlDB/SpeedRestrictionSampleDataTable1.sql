USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[SpeedRestrictionSampleData]    Script Date: 11/28/2017 07:11:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SpeedRestrictionSampleData](
	[MessageDate] [nvarchar](50) NULL,
	[MessageTime] [nvarchar](50) NULL,
	[CtrlPointName] [nvarchar](50) NULL,
	[EventName] [nvarchar](50) NULL,
	[EventSource] [nvarchar](50) NULL,
	[EventTime] [nvarchar](50) NULL,
	[EventType] [nvarchar](50) NULL,
	[LineName] [nvarchar](50) NULL,
	[MaxSpeed] [nvarchar](50) NULL,
	[MilepostBegin] [nvarchar](50) NULL,
	[MilepostEnd] [nvarchar](50) NULL,
	[ReasonText] [nvarchar](50) NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[TrackName] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

