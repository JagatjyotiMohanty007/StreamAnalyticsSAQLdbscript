USE [MRSProdLogs]
GO

/****** Object:  Table [dbo].[tblOCM2083LogStg]    Script Date: 11/28/2017 07:18:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblOCM2083LogStg](
	[MessageTime] [datetime] NULL,
	[Source] [nvarchar](64) NULL,
	[TrainId] [nvarchar](30) NULL,
	[WarnEnfType] [nvarchar](30) NULL,
	[SoftwareVer] [nvarchar](20) NULL,
	[TrgtTargetType] [nvarchar](30) NULL,
	[TrgtTargetDesc] [nvarchar](80) NULL,
	[TrgtStartMilepost] [bigint] NULL,
	[TrgtStartTrackName] [nvarchar](32) NULL,
	[TrgtEndMilepost] [bigint] NULL,
	[TrgtEndTrackName] [nvarchar](32) NULL,
	[TrgtTargetSpeed] [int] NULL,
	[WarnTime] [datetime] NULL,
	[WarnStartMilepost] [bigint] NULL,
	[WarnStartTrackName] [nvarchar](32) NULL,
	[WarnDistance] [int] NULL,
	[WarnDirectionOfTravel] [nvarchar](50) NULL,
	[WarnTrainSpeed] [int] NULL,
	[EnfStartMilepost] [bigint] NULL,
	[EnfStartTrackName] [nvarchar](32) NULL,
	[EnfBrakingDistance] [int] NULL,
	[EnfDirectionOfTravel] [nvarchar](50) NULL,
	[EnfTrainSpeed] [int] NULL,
	[BrkStartMilepost] [bigint] NULL,
	[BrkStartTrackName] [nvarchar](32) NULL,
	[BrkBrakingDistance] [int] NULL,
	[BrkDirectionOfTravel] [nvarchar](50) NULL,
	[BrkTrainSpeed] [int] NULL,
	[CurrTime] [datetime] NULL,
	[CurrMilepost] [bigint] NULL,
	[CurrTrackName] [nvarchar](32) NULL,
	[CurrDirectionOfTravel] [nvarchar](50) NULL,
	[CurrTrainSpeed] [int] NULL,
	[WarnPTCSubdiv] [int] NULL,
	[EnfPTCSubdiv] [int] NULL,
	[BrkPTCSubdiv] [int] NULL,
	[CurrPTCSubdiv] [int] NULL,
	[WarnPosLat] [decimal](19, 16) NULL,
	[WarnPosLon] [decimal](19, 16) NULL,
	[EnfPosLat] [decimal](19, 16) NULL,
	[EnfPosLon] [decimal](19, 16) NULL,
	[BrkPosLat] [decimal](19, 16) NULL,
	[BrkPosLon] [decimal](19, 16) NULL,
	[CurrPosLat] [decimal](19, 16) NULL,
	[CurrPosLon] [decimal](19, 16) NULL
)

GO

