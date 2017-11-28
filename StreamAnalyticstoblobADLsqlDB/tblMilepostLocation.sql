USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblMilepostLocation]    Script Date: 11/28/2017 07:12:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblMilepostLocation](
	[Subdivision] [int] NULL,
	[StartMilepost] [bigint] NULL,
	[EndMilepost] [bigint] NULL,
	[Location] [nvarchar](60) NULL
)

GO

