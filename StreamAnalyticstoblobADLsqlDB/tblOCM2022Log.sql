USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2022Log]    Script Date: 11/28/2017 07:15:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2022Log](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[railroadSCAC] [nvarchar](64) NULL,
	[ptcSubdiv] [int] NULL,
	[noOfAuthorities] [int] NULL,
	[AuthPtcAuthorityRefNum] [int] NULL,
	[AuthCrcOfAuthority] [int] NULL,
	[noOfBulletins] [int] NULL,
	[bulletinsPtcBulletinRefNum] [int] NULL,
	[bulletinsCrcOfBulletin] [int] NULL,
	[trackDataVersion] [int] NULL,
	[crcOfTrackData] [int] NULL,
	[DateInserted] [datetime] NULL
)

GO

ALTER TABLE [dbo].[tblOCM2022Log] ADD  DEFAULT (getdate()) FOR [DateInserted]
GO

