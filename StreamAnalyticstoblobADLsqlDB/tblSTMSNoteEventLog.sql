USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblSTMSNoteEventLog]    Script Date: 11/28/2017 07:19:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSTMSNoteEventLog](
	[MessageTime] [datetime] NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](10) NULL,
	[Name] [nvarchar](50) NULL,
	[NoteGUID] [nvarchar](50) NULL,
	[NoteText] [nvarchar](4000) NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

