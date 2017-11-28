USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2003Log]    Script Date: 11/28/2017 07:14:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2003Log](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[TrainId] [nvarchar](30) NULL,
	[EmpFirstName] [nvarchar](30) NULL,
	[EmpMiddleName] [nvarchar](1) NULL,
	[EmpLastName] [nvarchar](32) NULL,
	[SoftwareVer] [nvarchar](20) NULL,
	[ReasonForSending] [nvarchar](30) NULL
)

GO

