USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2005Log]    Script Date: 11/28/2017 07:14:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2005Log](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[ICDVersion] [nvarchar](20) NULL,
	[DateInserted] [datetime] NULL
)

GO

ALTER TABLE [dbo].[tblOCM2005Log] ADD  DEFAULT (getdate()) FOR [DateInserted]
GO

