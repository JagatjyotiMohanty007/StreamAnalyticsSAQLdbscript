USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetActiveSpeedRestrictions]    Script Date: 11/28/2017 06:58:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: <11/10/2017>
-- Description:	<Fetch Active Speed Restrictions>
-- =============================================
CREATE FUNCTION [dbo].[fnGetActiveSpeedRestrictions]()
RETURNS 
@retActiveSpeedRestrictions TABLE 
(
	-- Add the column definitions for the TABLE variable here
	Desk NVARCHAR(20) NULL,
	InitialMilepost NVARCHAR(30) NULL,
    FinalMilePost NVARCHAR(30) NULL,
	Speed int NULL,
	TrackBlock NVARCHAR(50) NULL,
    ControlPoint NVARCHAR(60) NULL,
    Creation_Date_Time DATETIMEOFFSET NULL
)
AS
BEGIN
	
	DECLARE
		@EventSource NVARCHAR(20),
		@MilepostBegin NVARCHAR(30),
		@MilepostEnd NVARCHAR(30),
		@MaxSpeed int,
		@TrackName NVARCHAR(50),
		@CtrlPointName NVARCHAR(60),
		@EventType NVARCHAR(20),
		@EventTime DATETIMEOFFSET;

		DECLARE db_cursor CURSOR FOR  
		SELECT DISTINCT [EventTime],
						[CtrlPointName], 
						[EventSource],
						[MilepostBegin],
						[MilepostEnd],
						[TrackName],
						[MaxSpeed],
						[EventType]
		FROM [dbo].[tblTMDSSpeedRestrictionEventLog] WITH (NOLOCK)  

		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @EventTime, @CtrlPointName, @EventSource,  @MilepostBegin, @MilepostEnd, @TrackName, @MaxSpeed, @EventType;

		WHILE @@FETCH_STATUS = 0   
		BEGIN   
	
			IF @EventType = 'CREATE'
				BEGIN
					INSERT INTO  @retActiveSpeedRestrictions
					(
						Desk,
						InitialMilepost,
						FinalMilePost,
						Speed,
						TrackBlock,
						ControlPoint,
						Creation_Date_Time
					)
					VALUES
					(
						@EventSource,
						@MilepostBegin,
						@MilepostEnd,
						@MaxSpeed,
						@TrackName,
						@CtrlPointName,
						@EventTime		
					);
				END
			ELSE IF @EventType = 'UPDATE'
				BEGIN
					UPDATE  @retActiveSpeedRestrictions
						SET Speed = @MaxSpeed
					WHERE 
						InitialMilepost = @MilepostBegin AND
						FinalMilePost = @MilepostEnd AND		
						TrackBlock = @TrackName								
				END

			ELSE IF @EventType = 'CANCEL'
				BEGIN
					DELETE FROM @retActiveSpeedRestrictions
					WHERE
						InitialMilepost = @MilepostBegin AND
						FinalMilePost = @MilepostEnd AND		
						TrackBlock = @TrackName		
				END
		
			FETCH NEXT FROM db_cursor INTO @EventTime, @CtrlPointName, @EventSource,  @MilepostBegin, @MilepostEnd, @TrackName, @MaxSpeed,  @EventType;  
		END   
	
	RETURN 
END

GO

