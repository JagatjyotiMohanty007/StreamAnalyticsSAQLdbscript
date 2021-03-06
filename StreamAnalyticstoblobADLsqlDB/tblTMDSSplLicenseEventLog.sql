USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblTMDSSplLicenseEventLog]    Script Date: 11/28/2017 07:21:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblTMDSSplLicenseEventLog](
	[MessageTime] [datetime] NULL,
	[AuthComponents] [nvarchar](4000) NULL,
	[AuthDirection] [nvarchar](20) NULL,
	[AuthNumber] [int] NULL,
	[AuthSegments] [nvarchar](4000) NULL,
	[AuthText] [nvarchar](4000) NULL,
	[EventName] [nvarchar](20) NULL,
	[EventSource] [nvarchar](20) NULL,
	[EventTime] [datetimeoffset](7) NULL,
	[EventType] [nvarchar](20) NULL,
	[LocoLead] [nvarchar](20) NULL,
	[TrainSymbol] [nvarchar](10) NULL,
	[UserName] [nvarchar](50) NULL
)

GO

