USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblTMDSSpeedRestrictionEventLog]    Script Date: 11/28/2017 07:21:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblTMDSSpeedRestrictionEventLog](
	[MessageTime] [datetime] NULL,
	[CtrlPointName] [nvarchar](50) NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](20) NULL,
	[LineName] [nvarchar](30) NULL,
	[MaxSpeed] [int] NULL,
	[MilepostBegin] [nvarchar](30) NULL,
	[MilepostEnd] [nvarchar](30) NULL,
	[ReasonText] [nvarchar](4000) NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[TrackName] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

