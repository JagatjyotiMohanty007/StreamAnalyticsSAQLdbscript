USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM1051Log]    Script Date: 11/28/2017 07:13:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM1051Log](
	[UGUID] [nvarchar](50) NULL,
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[PTCAuthorityRefNum] [int] NULL,
	[AuthorityType] [nvarchar](50) NULL,
	[NoOfAuthSegments] [int] NULL,
	[AuthSegStartingMilepost] [bigint] NULL,
	[AuthSegEndingMilepost] [bigint] NULL,
	[AuthSegTrackName] [nvarchar](32) NULL,
	[SummaryTextLen] [int] NULL,
	[SummaryText] [nvarchar](80) NULL
)

GO

