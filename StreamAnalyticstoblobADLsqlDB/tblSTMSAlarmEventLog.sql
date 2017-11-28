USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblSTMSAlarmEventLog]    Script Date: 11/28/2017 07:18:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSTMSAlarmEventLog](
	[MessageTime] [datetime] NULL,
	[IsAlertAck] [nvarchar](10) NULL,
	[AlertData] [nvarchar](4000) NULL,
	[AlertGUID] [nvarchar](50) NULL,
	[IsCritical] [nvarchar](10) NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](20) NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[TypeOfAlert] [nvarchar](30) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

