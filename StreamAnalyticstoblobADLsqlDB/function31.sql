USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetTrainsNotMoving]    Script Date: 11/28/2017 07:05:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetTrainsNotMoving]()
RETURNS @retTrains TABLE
	(
		TrainSymbol			NVARCHAR(60) NULL,
		AssocTime			DATETIMEOFFSET NULL,
		EventSource			NVARCHAR(20) NULL,
		LeadLocoId			NVARCHAR(10) NULL,
		LocoStateTime		DATETIME NULL,
		LocoState			NVARCHAR(20) NULL,
		Speed				INT NULL,
		DirOfTravel			NVARCHAR(30),
		Milepost			NUMERIC(15,6) NULL,
		TrackName			NVARCHAR(32) NULL,
		LicenseTime			DATETIMEOFFSET NULL,
		AuthSegments		NVARCHAR(4000) NULL,
		IsValidLicense		NVARCHAR(10) NULL,
		DurationStopped		INT NULL
	)
AS
BEGIN
	DECLARE 
		@TrainSymbol NVARCHAR(60),
		@AssocTime DATETIMEOFFSET,
		@EventSource NVARCHAR(20);
	
	DECLARE TrainRuns CURSOR FOR
		WITH tblTMDSTrainEventLogDD AS (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY EventTime, EventType ORDER BY EventTime, EventType) AS ROWNUM
				FROM tblTMDSTrainEventLog WITH (NOLOCK)
			) T WHERE ROWNUM = 1
		)
		SELECT A.TrainSymbol, A.EventTime, A.EventSource
		FROM tblTMDSTrainEventLogDD A WITH (NOLOCK)
		WHERE A.EventType = 'CREATED'
		-- REVIEW: eliminate LONG RUNNING trains
		AND NOT EXISTS 
			(
				SELECT 1 
				FROM tblTMDSTrainEventLogDD B WITH (NOLOCK)
				WHERE B.TrainSymbol = A.TrainSymbol
				AND B.EventType = 'DELETED'
				AND B.EventTime >= A.EventTime
			)
		ORDER BY A.EventTime;

	OPEN TrainRuns;

	FETCH NEXT FROM TrainRuns
	INTO @TrainSymbol, @AssocTime, @EventSource;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE 
			@Source NVARCHAR(64) = NULL,
			@LocoId NVARCHAR(10) = NULL,
			@InitTime DATETIME = NULL,
			@LocoStateTime DATETIME = NULL,
			@LocoState NVARCHAR(20) = NULL,
			@Speed INT = NULL,
			@DirOfTravel NVARCHAR(30) = NULL,
			@Milepost NUMERIC(15, 6) = NULL,
			@TrackName NVARCHAR(32) = NULL,
			@AuthSegments NVARCHAR(4000) = NULL,
			@RegAuthSegments NVARCHAR(4000) = NULL,
			@SplAuthSegments NVARCHAR(4000) = NULL,
			@LicenseTime DATETIMEOFFSET = NULL,
			@RegLicenseTime DATETIMEOFFSET = NULL,
			@SplLicenseTime DATETIMEOFFSET = NULL;

		SELECT TOP 1 @Source = Source, @LocoId = SUBSTRING(Source, 11, 4), @InitTime = MessageTime
		FROM tblOCM2003Log WITH (NOLOCK)
		WHERE TrainId = @TrainSymbol
		AND ReasonForSending = 'Initialization'
		AND MessageTime >= @AssocTime
		ORDER BY MessageTime DESC;

		IF @Source IS NOT NULL
		BEGIN
			SELECT TOP 1 @LocoStateTime = MessageTime, @LocoState = LocomotiveState, @Speed = Speed, @DirOfTravel = DirectionOfTravel,
			@Milepost = CAST(HeadEndMilepost AS NUMERIC(15, 6))/CAST(10000 AS NUMERIC(15,6)), @TrackName = HeadEndTrackName
			FROM tblOCM2080Log WITH (NOLOCK)
			WHERE Source = @Source
			-- REVIEW: message after init??
			AND MessageTime >= @InitTime
			-- REVIEW: non-zero message or any message?
			AND HeadEndMilepost != 0
			ORDER BY MessageTime DESC;

			-- REVIEW: direction of travel should be unknown??
			IF (@LocoState = 'Active' OR @LocoState = 'Disengaged') AND @Speed = 0
				--AND @DirOfTravel = 'Unknown'
			BEGIN
				-- REVIEW: Special License needs to be taken care
				SELECT TOP 1 @RegLicenseTime = EventTime, @RegAuthSegments = AuthSegments
				FROM tblTMDSLicenseEventLog
				WHERE TrainSymbol = @TrainSymbol
				AND EventType != 'ROLLUP'
				-- REVIEW: message after init??
				AND EventTime >= @InitTime
				ORDER BY EventTime DESC;
				/*
				SELECT TOP 1 @SplLicenseTime = EventTime, @SplAuthSegments = AuthSegments
				FROM tblTMDSSplLicenseEventLog
				WHERE TrainSymbol = @TrainSymbol
				AND EventType != 'CANCEL'
				-- REVIEW: message after init??
				AND EventTime >= @InitTime
				ORDER BY EventTime DESC;

				SELECT @AuthSegments = 
							CASE 
								WHEN @RegLicenseTime IS NOT NULL AND @SplLicenseTime IS NOT NULL AND @RegLicenseTime >= @SplLicenseTime THEN @RegAuthSegments
								WHEN @RegLicenseTime IS NOT NULL AND @SplLicenseTime IS NOT NULL AND @RegLicenseTime < @SplLicenseTime THEN @SplAuthSegments
								WHEN @RegLicenseTime IS NOT NULL AND @SplLicenseTime IS NULL THEN @RegAuthSegments
								WHEN @RegLicenseTime IS NULL AND @SplLicenseTime IS NOT NULL THEN @SplAuthSegments
								ELSE NULL
							END;*/
				SET @AuthSegments = @RegAuthSegments;
				SET @LicenseTime = @RegLicenseTime;

				IF @AuthSegments IS NULL
				BEGIN
					INSERT INTO @retTrains
						(
							TrainSymbol, 
							AssocTime,
							LeadLocoId,
							LocoStateTime,
							LocoState,
							Speed,
							DirOfTravel,
							Milepost,
							TrackName,
							LicenseTime,
							AuthSegments,
							IsValidLicense,
							DurationStopped
						)
					VALUES
						(
							@TrainSymbol, 
							@AssocTime,
							@LocoId,
							@LocoStateTime,
							@LocoState,
							@Speed,
							@DirOfTravel,
							@Milepost,
							@TrackName,
							NULL,
							@AuthSegments,
							'FALSE',
							NULL
						);
				END
				ELSE
				BEGIN
					DECLARE 
						@AuthSegment NVARCHAR(500) = NULL,
						@LicenseStartMilepost NUMERIC(15, 6) = NULL,
						@LicenseEndMilepost NUMERIC(15, 6) = NULL,
						@LicenseTrackName NVARCHAR(32) = NULL,
						@IsValidLicense NVARCHAR(10) = 'FALSE';

					DECLARE AuthSegments CURSOR FOR
						SELECT * FROM fnSplitString(@AuthSegments, ',');
					
					OPEN AuthSegments;
					
					FETCH NEXT FROM AuthSegments INTO @AuthSegment;
					
					WHILE @@FETCH_STATUS = 0 AND @IsValidLicense = 'FALSE'
					BEGIN
						SET @AuthSegment = REPLACE(@AuthSegment, '---', ',');
						SET @AuthSegment = REPLACE(@AuthSegment, '--', ',');
						SET @AuthSegment = REPLACE(@AuthSegment, '-', ',');

						SELECT 
							@LicenseStartMilepost = TRY_CAST(dbo.UFN_SEPARATES_COLUMNS(@AuthSegment, 2, ',') AS NUMERIC(11, 6)), 
							@LicenseEndMilepost = TRY_CAST(dbo.UFN_SEPARATES_COLUMNS(@AuthSegment, 3, ',') AS NUMERIC(11, 6)),
							@LicenseTrackName = dbo.UFN_SEPARATES_COLUMNS(@AuthSegment, 4, ',');

						IF ((@LicenseStartMilepost <= @Milepost AND @Milepost <= @LicenseEndMilepost)
						OR (@LicenseEndMilepost <= @Milepost AND @Milepost <= @LicenseStartMilepost))
						AND @TrackName = @LicenseTrackName
						BEGIN
							SET @IsValidLicense = 'TRUE';
						END;
								
						FETCH NEXT FROM AuthSegments INTO @AuthSegment;
					END;
					
					CLOSE AuthSegments;
					DEALLOCATE AuthSegments;

					INSERT INTO @retTrains
						(
							TrainSymbol, 
							AssocTime,
							EventSource,
							LeadLocoId,
							LocoStateTime,
							LocoState,
							Speed,
							DirOfTravel,
							Milepost,
							TrackName,
							LicenseTime,
							AuthSegments,
							IsValidLicense,
							DurationStopped
						)
					VALUES
						(
							@TrainSymbol, 
							@AssocTime,
							@EventSource,
							@LocoId,
							@LocoStateTime,
							@LocoState,
							@Speed,
							@DirOfTravel,
							@Milepost,
							@TrackName,
							@LicenseTime,
							@AuthSegments,
							@IsValidLicense,
							CASE WHEN @IsValidLicense = 'TRUE' THEN DATEDIFF(MINUTE, @LicenseTime, GETUTCDATE()) ELSE NULL END
						);
				END;
			END;
		END;

		FETCH NEXT FROM TrainRuns
		INTO @TrainSymbol, @AssocTime, @EventSource;
	END;
	
	CLOSE TrainRuns;
	DEALLOCATE TrainRuns;

	RETURN;
END;

GO

