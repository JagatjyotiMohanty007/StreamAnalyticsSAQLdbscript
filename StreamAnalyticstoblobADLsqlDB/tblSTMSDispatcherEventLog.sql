USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblSTMSDispatcherEventLog]    Script Date: 11/28/2017 07:19:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSTMSDispatcherEventLog](
	[MessageTime] [datetime] NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](10) NULL,
	[TerritoryList] [nvarchar](4000) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

