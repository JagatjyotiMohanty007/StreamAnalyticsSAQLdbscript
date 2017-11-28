USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblSTMSTrackBlockEventLog]    Script Date: 11/28/2017 07:20:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSTMSTrackBlockEventLog](
	[MessageTime] [datetime] NULL,
	[AuthNumber] [int] NULL,
	[BlockNotes] [nvarchar](500) NULL,
	[ComponentsList] [nvarchar](4000) NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](10) NULL,
	[IssueTo] [nvarchar](50) NULL,
	[StationName] [nvarchar](50) NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

