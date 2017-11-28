USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblSyncErrorLog]    Script Date: 11/28/2017 07:20:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblSyncErrorLog](
	[TrainID] [varchar](20) NULL,
	[LocomotiveID] [int] NULL,
	[Occurance_Date_Time] [datetime] NULL,
	[DepartureTime] [datetime] NULL,
	[TrainRunState] [varchar](20) NULL,
	[Latitude] [decimal](19, 16) NULL,
	[Longitude] [decimal](19, 16) NULL,
	[DataStartTime] [datetime] NULL,
	[DataEndTime] [datetime] NULL,
	[DateInserted] [datetime] NULL
)

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tblSyncErrorLog] ADD  DEFAULT (getdate()) FOR [DateInserted]
GO

