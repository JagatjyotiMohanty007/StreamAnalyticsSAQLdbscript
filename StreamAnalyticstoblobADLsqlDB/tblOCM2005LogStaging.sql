USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2005LogStaging]    Script Date: 11/28/2017 07:15:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2005LogStaging](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[ICDVersion] [nvarchar](20) NULL,
	[DateInserted] [datetime] NULL
)

GO

ALTER TABLE [dbo].[tblOCM2005LogStaging] ADD  DEFAULT (getdate()) FOR [DateInserted]
GO

