USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblTMCFLTLog]    Script Date: 11/28/2017 07:20:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

SET ARITHABORT ON
GO

CREATE TABLE [dbo].[tblTMCFLTLog](
	[TMCMessageTime] [datetime] NULL,
	[LocoID] [int] NULL,
	[RecordID] [int] NULL,
	[RecoredName] [varchar](3) NULL,
	[Version] [int] NULL,
	[FaultStatus] [varchar](20) NULL,
	[FaultSource] [varchar](20) NULL,
	[FaultCode] [varchar](4) NULL,
	[ReportedFault] [varchar](100) NULL,
	[Source]  AS (('mrs.l.mrs.'+CONVERT([varchar],[LocoID]))+':itc')
)

GO

SET ANSI_PADDING OFF
GO

