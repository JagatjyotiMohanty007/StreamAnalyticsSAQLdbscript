USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblSTMSStoredRouteEventLog]    Script Date: 11/28/2017 07:19:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblSTMSStoredRouteEventLog](
	[MessageTime] [datetime] NULL,
	[ComponentList] [nvarchar](4000) NULL,
	[EntrySignal] [nvarchar](50) NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](10) NULL,
	[ExitSignal] [nvarchar](50) NULL,
	[Priority] [int] NULL,
	[RouteGUID] [nvarchar](50) NULL,
	[StationName] [nvarchar](50) NULL,
	[SymbolAssociation] [nvarchar](10) NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

