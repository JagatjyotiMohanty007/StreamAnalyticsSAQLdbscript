USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblTMDSTrainEventLog]    Script Date: 11/28/2017 07:22:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblTMDSTrainEventLog](
	[MessageTime] [datetime] NULL,
	[CtrlPointName] [nvarchar](50) NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](10) NULL,
	[LocoLead] [nvarchar](50) NULL,
	[MaxSpeed] [int] NULL,
	[NumAxles] [int] NULL,
	[NumCarsEmpty] [int] NULL,
	[NumCarsLoad] [int] NULL,
	[NumOperAxles] [int] NULL,
	[PTCStatus] [nvarchar](30) NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[TrackName] [nvarchar](50) NULL,
	[TrainDirection] [nvarchar](20) NULL,
	[TrainLength] [int] NULL,
	[TrainSymbol] [nvarchar](10) NULL,
	[TrainTon] [int] NULL,
	[TrainUnits] [nvarchar](4000) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

