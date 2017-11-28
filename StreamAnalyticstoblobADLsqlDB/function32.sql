USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetTrainsNotMovingReport]    Script Date: 11/28/2017 07:06:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetTrainsNotMovingReport](@StartDate DATETIME, @EndDate DATETIME)
RETURNS @retTrains TABLE
	(
		TrainSymbol			NVARCHAR(60) NULL,
		AssocTime			DATETIMEOFFSET NULL,
		TerritoryName		NVARCHAR(50) NULL,
		LeadLocoId			NVARCHAR(10) NULL,
		StopBeginTime		DATETIME NULL,
        StopEndTime         DATETIME NULL,
		LocoState			NVARCHAR(20) NULL,
		DirOfTravel			NVARCHAR(30),
		Milepost			NUMERIC(15,6) NULL,
		TrackName			NVARCHAR(32) NULL,
		LicenseTime			DATETIMEOFFSET NULL,
		AuthSegments		NVARCHAR(4000) NULL,
		IsValidLicense		NVARCHAR(10) NULL,
		DurationStopped		INT NULL,
		DispatcherName		NVARCHAR(50) NULL
	)
AS
BEGIN
	DECLARE 
		@TrainSymbol NVARCHAR(60),
		@AssocTime DATETIMEOFFSET,
		@DisassocTime DATETIMEOFFSET,
		@TerritoryName NVARCHAR(50),
		@DispatcherName NVARCHAR(50);
	
	DECLARE 
		@Source NVARCHAR(64) = NULL,
		@InitTime DATETIME = NULL;

	DECLARE TrainRuns CURSOR READ_ONLY FOR
		WITH tblTMDSTrainEventLogDD AS (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY EventTime, EventType ORDER BY EventTime, EventType) AS ROWNUM
				FROM tblTMDSTrainEventLog WITH (NOLOCK)
			) T WHERE ROWNUM = 1
		)
		-- REVIEW: eliminate LONG RUNNING trains
		SELECT A.TrainSymbol, A.EventTime, C.EventTime, A.TerritoryName, REPLACE(A.UserName, ',', ';'), E.MessageTime, E.Source
		FROM tblTMDSTrainEventLogDD A WITH (NOLOCK)
		OUTER APPLY 
			(
				SELECT TOP 1 * 
				FROM tblTMDSTrainEventLogDD B WITH (NOLOCK)
				WHERE B.TrainSymbol = A.TrainSymbol
				AND B.EventType = 'DELETED'
				AND B.EventTime >= A.EventTime
				ORDER BY B.EventTime ASC
			) C
		CROSS APPLY 
			(
				SELECT D.MessageTime, D.Source
				FROM tblOCM2003Log D WITH (NOLOCK)
				WHERE D.TrainId = A.TrainSymbol
				AND D.ReasonForSending = 'Initialization'
				AND D.MessageTime >= A.EventTime AND (C.EventTime IS NULL OR D.MessageTime <= C.EventTime)
				UNION ALL
				SELECT CASE WHEN C.EventTime IS NOT NULL THEN C.EventTime ELSE GETUTCDATE() END, NULL
			) E
		WHERE A.EventType = 'CREATED'
		AND A.EventTime >= @StartDate AND A.EventTime <= @EndDate
		AND EXISTS
			(
				SELECT 1
				FROM tblOCM2003Log F WITH (NOLOCK)
				WHERE F.TrainId = A.TrainSymbol
				AND F.ReasonForSending = 'Initialization'
				AND F.MessageTime >= A.EventTime AND (C.EventTime IS NULL OR F.MessageTime <= C.EventTime)
			)
		ORDER BY A.TrainSymbol, E.MessageTime, E.Source;

	OPEN TrainRuns;

	FETCH NEXT FROM TrainRuns
	INTO @TrainSymbol, @AssocTime, @DisassocTime, @TerritoryName, @DispatcherName, @InitTime, @Source;

    DECLARE
		@PrevTrainSymbol NVARCHAR(60) = @TrainSymbol,
		@PrevSource NVARCHAR(64) = @Source,
		@PrevInitTime DATETIME = @InitTime;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		/*DECLARE Locos CURSOR READ_ONLY FOR 
			SELECT MessageTime, Source
			FROM tblOCM2003Log WITH (NOLOCK)
			WHERE TrainId = @TrainSymbol
			AND ReasonForSending = 'Initialization'
			AND MessageTime >= @AssocTime AND (@DisassocTime IS NULL OR MessageTime <= @DisassocTime)
            UNION ALL --to process last loco 
            SELECT CASE WHEN @DisassocTime IS NOT NULL THEN @DisassocTime ELSE GETUTCDATE() END, NULL
			ORDER BY MessageTime;

		OPEN Locos;

		FETCH NEXT FROM Locos
		INTO @InitTime, @Source;*/

		/*WHILE @@FETCH_STATUS = 0
		BEGIN*/
			IF @Source IS NULL OR (@PrevSource IS NOT NULL AND @Source IS NOT NULL AND @Source != @PrevSource)
			BEGIN
				DECLARE 
					@StopBeginTime DATETIME = NULL,
					@StopEndTime DATETIME = NULL,
					@LocoState NVARCHAR(20) = NULL,
					@DirOfTravel NVARCHAR(30) = NULL,
					@Milepost NUMERIC(15, 6) = NULL,
					@TrackName NVARCHAR(32) = NULL,
					@StopDuration INT = NULL,
					@AuthSegments NVARCHAR(4000) = NULL,
					@RegAuthSegments NVARCHAR(4000) = NULL,
					@SplAuthSegments NVARCHAR(4000) = NULL,
					@LicenseTime DATETIMEOFFSET = NULL,
					@RegLicenseTime DATETIMEOFFSET = NULL,
					@SplLicenseTime DATETIMEOFFSET = NULL;
				
				DECLARE LocoStops CURSOR READ_ONLY FOR
					SELECT A.MessageTime, C.MessageTime, A.LocomotiveState, A.DirectionOfTravel, 
					CAST(A.HeadEndMilepost AS NUMERIC(15, 6))/CAST(10000 AS NUMERIC(15,6)), A.HeadEndTrackName,
					CASE WHEN C.MessageTime IS NOT NULL THEN DATEDIFF(MINUTE, A.MessageTime, C.MessageTime) ELSE DATEDIFF(MINUTE, A.MessageTime, GETUTCDATE()) END
					FROM tblOCM2080Log A WITH (NOLOCK)
					OUTER APPLY 
						(
							SELECT TOP 1 * 
							FROM tblOCM2080Log B WITH (NOLOCK)
							WHERE B.Source = A.Source 
							AND B.MessageTime > A.MessageTime 
							AND B.Speed > 0 
							ORDER BY B.MessageTime ASC
						) C
					WHERE A.Source = @PrevSource
					AND A.MessageTime >= @PrevInitTime AND A.MessageTime <= @InitTime
					AND (A.LocomotiveState = 'Active' OR A.LocomotiveState = 'Disengaged')
					AND A.Speed = 0
					AND (
							SELECT TOP 1 D.Speed 
							FROM tblOCM2080Log D WITH (NOLOCK)
							WHERE D.Source = A.Source 
							AND D.MessageTime < A.MessageTime 
							ORDER BY D.MessageTime DESC
						) > 0
					ORDER BY A.MessageTime;
					
				OPEN LocoStops;
				
                FETCH NEXT FROM LocoStops INTO @StopBeginTime, @StopEndTime, @LocoState, @DirOfTravel, 
				@Milepost, @TrackName, @StopDuration;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- REVIEW: Special License needs to be taken care
					SELECT TOP 1 @RegLicenseTime = EventTime, @RegAuthSegments = AuthSegments
					FROM tblTMDSLicenseEventLog WITH (NOLOCK)
					WHERE TrainSymbol = @PrevTrainSymbol
					AND EventType != 'ROLLUP'
					-- REVIEW: message after init??
					--AND EventTime >= @InitTime
                    AND EventTime <= @StopBeginTime
					ORDER BY EventTime DESC;
					/*
					SELECT TOP 1 @SplLicenseTime = EventTime, @SplAuthSegments = AuthSegments
					FROM tblTMDSSplLicenseEventLog
					WHERE TrainSymbol = @TrainSymbol
					AND EventType != 'CANCEL'
					-- REVIEW: message after init??
					--AND EventTime >= @InitTime
                    AND EventTime <= @StopBeginTime
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
								StopBeginTime,
                                StopEndTime,
								LocoState,
								DirOfTravel,
								Milepost,
								TrackName,
								LicenseTime,
								AuthSegments,
								IsValidLicense,
								DurationStopped,
								DispatcherName
							)
						VALUES
							(
								@TrainSymbol, 
								@AssocTime,
								--GETDATE(),
								SUBSTRING(@PrevSource, 11, 4),
								@StopBeginTime,
                                @StopEndTime,
								@LocoState,
								@DirOfTravel,
								@Milepost,
								@TrackName,
								NULL,
								@AuthSegments,
								'FALSE',
								@StopDuration,
								@DispatcherName
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
								TerritoryName,
								LeadLocoId,
								StopBeginTime,
                                StopEndTime,
								LocoState,
								DirOfTravel,
								Milepost,
								TrackName,
								LicenseTime,
								AuthSegments,
								IsValidLicense,
								DurationStopped,
								DispatcherName
							)
						VALUES
							(
								@TrainSymbol, 
								@AssocTime,
								--GETDATE(),
								@TerritoryName,
								SUBSTRING(@PrevSource, 11, 4),
								@StopBeginTime,
                                @StopEndTime,
								@LocoState,
								@DirOfTravel,
								@Milepost,
								@TrackName,
								@LicenseTime,
								@AuthSegments,
								@IsValidLicense,
								@StopDuration,
								@DispatcherName
							);
					END;

					FETCH NEXT FROM LocoStops INTO @StopBeginTime, @StopEndTime, @LocoState, @DirOfTravel, 
					@Milepost, @TrackName, @StopDuration;
				END;
				CLOSE LocoStops;
				DEALLOCATE LocoStops;

			END;

			SET @PrevTrainSymbol = @TrainSymbol;
			SET @PrevSource = @Source;
			SET @PrevInitTime = @InitTime;

			/*FETCH NEXT FROM Locos
			INTO @InitTime, @Source;
		END;
		CLOSE Locos;
		DEALLOCATE Locos;*/

		FETCH NEXT FROM TrainRuns
		INTO @TrainSymbol, @AssocTime, @DisassocTime, @TerritoryName, @DispatcherName, @InitTime, @Source;
	END;
	
	CLOSE TrainRuns;
	DEALLOCATE TrainRuns;

	RETURN;
END;

GO

