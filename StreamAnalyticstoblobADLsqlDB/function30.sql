USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetTrainRuns]    Script Date: 11/28/2017 07:05:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetTrainRuns](@StartDate DATETIME, @EndDate DATETIME)
RETURNS @retTrainRuns TABLE
	(
		TrainSymbol			NVARCHAR(60) NULL,
		LocoList			NVARCHAR(100) NULL,
		SoftwareVerList		NVARCHAR(200) NULL,
		EngineerNameList	NVARCHAR(500) NULL,
		DepLoc				NVARCHAR(50) NULL,
		DepLocMilepost		NVARCHAR(50) NULL,
		FirstInitTime		DATETIME NULL,
		FirstLicenseTime	DATETIMEOFFSET NULL,
		DepTime				DATETIME NULL,
		AssocTime			DATETIMEOFFSET NULL,
		DisassocTime		DATETIMEOFFSET NULL,
		DepDelay			INT NULL,
		ArrLoc				NVARCHAR(50) NULL,
		ArrLocMilepost		NVARCHAR(50) NULL,
		ArrTime				DATETIME NULL,
		ActiveDuration		INT NULL,
		TrainRunState		NVARCHAR(10) NULL,
		LocomotiveState		NVARCHAR(20) NULL,
		LocoStateSummary	NVARCHAR(20) NULL,
		EnfCount			INT NULL,
		InitCount			INT NULL
	)
AS
BEGIN
	DECLARE 
		@TrainSymbol NVARCHAR(60),
		@AssocTime DATETIMEOFFSET,
		@DisassocTime DATETIMEOFFSET;

	-- check for duplicate associations
	DECLARE TrainRuns CURSOR READ_ONLY FOR
		WITH tblTMDSTrainEventLogDD AS (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY EventTime, EventType ORDER BY EventTime, EventType) AS ROWNUM
				FROM tblTMDSTrainEventLog WITH (NOLOCK)
			) T WHERE ROWNUM = 1
		)
		SELECT A.TrainSymbol, C.EventTime AS AssocTime, A.EventTime AS DisassocTime
		FROM tblTMDSTrainEventLogDD A WITH (NOLOCK)
		CROSS APPLY 
			(
				SELECT TOP 1 * 
				FROM tblTMDSTrainEventLogDD B WITH (NOLOCK)
				WHERE B.TrainSymbol = A.TrainSymbol
				AND B.EventType = 'CREATED'
				AND B.EventTime <= A.EventTime
				ORDER BY B.EventTime DESC
			) C
		WHERE A.EventType = 'DELETED'
		AND A.EventTime >= '2017-11-22 00:00:00' AND A.EventTime <= '2017-11-25 12:59:59'
		AND EXISTS 
			(
				SELECT 1 
				FROM tblOCM2003Log D
				WHERE D.TrainId = A.TrainSymbol
				AND D.ReasonForSending = 'Initialization'
				AND D.MessageTime >= C.EventTime AND D.MessageTime <= A.MessageTime
			)
		ORDER BY A.EventTime;

	OPEN TrainRuns;

	FETCH NEXT FROM TrainRuns
	INTO @TrainSymbol, @AssocTime, @DisassocTime;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE 
			@InitTime DATETIME = NULL,
			@FirstInitTime DATETIME = NULL,
			@Source NVARCHAR(64) = NULL,
			@LocoId NVARCHAR(10) = NULL,
			@EngineerName NVARCHAR(65) = NULL,
			@SoftwareVer NVARCHAR(20) = NULL,
			@DepTime DATETIME = NULL,
			@DepLocMilepost BIGINT = NULL,
			@DepLocPTCSubdiv INT = NULL,
			@DepLoc NVARCHAR(60) = NULL,
			@ArrLocMilepost BIGINT = NULL,
			@ArrLocPTCSubdiv INT = NULL,
			@ArrLoc NVARCHAR(60) = NULL,
			@ArrTime DATETIME = NULL,
			@LocomotiveState NVARCHAR(20) = NULL,
			@LocoStateSummary NVARCHAR(20) = NULL,
			@InitCount INT = 0,
			@EnfCount INT = NULL,
			@TotEnfCount INT = NULL,
			@IsFirstLoco BIT = 1,
			@LocoList NVARCHAR(100) = NULL,
			@SoftwareVerList NVARCHAR(200) = NULL,
			@EngineerNameList NVARCHAR(500) = NULL,
			@FirstLicenseTime DATETIMEOFFSET = NULL;

		DECLARE Locos CURSOR READ_ONLY FOR 
			SELECT MessageTime, Source, SUBSTRING(Source, 11, 4), EmpFirstName + ' ' + EmpLastName, SoftwareVer
			FROM tblOCM2003Log WITH (NOLOCK)
			WHERE TrainId = @TrainSymbol
			AND ReasonForSending = 'Initialization'
			AND MessageTime >= @AssocTime AND (@DisassocTime IS NULL OR MessageTime <= @DisassocTime)
			ORDER BY MessageTime;

		OPEN Locos;

		FETCH NEXT FROM Locos
		INTO @InitTime, @Source, @LocoId, @EngineerName, @SoftwareVer;

		DECLARE 
			@PrevSource NVARCHAR(64) = @Source,
			@PrevInitTime DATETIME = @InitTime,
			@PrevLocoId NVARCHAR(10) = @LocoId,
			@PrevEngineerName NVARCHAR(65) = @EngineerName,
			@PrevSoftwareVer NVARCHAR(20) = @SoftwareVer;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @InitCount = @InitCount + 1;

			IF @IsFirstLoco = 1
			BEGIN
				SET @FirstInitTime = @InitTime;

				-- REVIEW: Speed > 0
				SELECT TOP 1 @DepTime = MessageTime, @DepLocMilepost = HeadEndMilepost, @DepLocPTCSubdiv = HeadEndPTCSubdiv
				FROM tblOCM2080Log WITH (NOLOCK)
				WHERE Source = @Source
				AND MessageTime >= @InitTime
				AND MessageTime <= @DisassocTime
				AND HeadEndMilepost != 0
				AND Speed > 0
				ORDER BY MessageTime ASC;

				SELECT @DepLoc = Location
				FROM tblMilepostLocation
				WHERE Subdivision = @DepLocPTCSubdiv
				AND @DepLocMilepost BETWEEN StartMilepost AND EndMilepost;

				SET @IsFirstLoco = 0;
			END;

			IF @Source != @PrevSource
			BEGIN
				SELECT @EnfCount = COUNT(*) 
				FROM tblOCM2083Log WITH (NOLOCK)
				WHERE Source = @PrevSource
				AND MessageTime >= @PrevInitTime AND MessageTime <= @InitTime
				AND (WarnEnfType = 'Predictive Enforcement' OR WarnEnfType = 'Reactive Enforcement');

				SET @TotEnfCount = @TotEnfCount + @EnfCount;
				
				IF @LocoList IS NULL
				BEGIN
					SET @LocoList = @PrevLocoId;
					SET @SoftwareVerList = @PrevSoftwareVer;
					SET @EngineerNameList = @PrevEngineerName;
				END
				ELSE
				BEGIN
					SET @LocoList = @LocoList + '; ' + @PrevLocoId;
					SET @SoftwareVerList = @SoftwareVerList + '; ' + @PrevSoftwareVer;
					SET @EngineerNameList = @EngineerNameList + '; ' + @PrevEngineerName;
				END;

				SET @PrevSource = @Source;
				SET @PrevInitTime = @InitTime;			
				SET @PrevLocoId = @LocoId;
				SET @PrevEngineerName = @EngineerName;
				SET @PrevSoftwareVer = @SoftwareVer;
			END;
			
			FETCH NEXT FROM Locos
			INTO @InitTime, @Source, @LocoId, @EngineerName, @SoftwareVer;
		END;
		CLOSE Locos;
		DEALLOCATE Locos;

		IF @PrevInitTime IS NOT NULL
		BEGIN
			-- REVIEW: between @PrevInitTime and @DisassocTime
			SELECT @EnfCount = COUNT(*) 
			FROM tblOCM2083Log WITH (NOLOCK)
			WHERE Source = @PrevSource
			AND MessageTime >= @PrevInitTime AND (@DisassocTime IS NULL OR MessageTime <= @DisassocTime) 
			AND (WarnEnfType = 'Predictive Enforcement' OR WarnEnfType = 'Reactive Enforcement');

			SET @TotEnfCount = @TotEnfCount + @EnfCount;			

			IF @LocoList IS NULL
			BEGIN
				SET @LocoList = @PrevLocoId;
				SET @SoftwareVerList = @PrevSoftwareVer;
				SET @EngineerNameList = @PrevEngineerName;
			END
			ELSE
			BEGIN
				SET @LocoList = @LocoList + '; ' + @PrevLocoId;
				SET @SoftwareVerList = @SoftwareVerList + '; ' + @PrevSoftwareVer;
				SET @EngineerNameList = @EngineerNameList + '; ' + @PrevEngineerName;
			END;
		END;

		IF @PrevInitTime IS NOT NULL
		BEGIN
			IF @DisassocTime IS NOT NULL
			BEGIN
				-- REVIEW: Nearest non-zero 2080 message or any message?
				SELECT TOP 1 @ArrTime = MessageTime, @ArrLocMilepost = HeadEndMilepost, @ArrLocPTCSubdiv = HeadEndPTCSubdiv,
				@LocomotiveState = LocomotiveState, @LocoStateSummary = LocoStateSummary
				FROM tblOCM2080Log WITH (NOLOCK)
				WHERE Source = @PrevSource
				AND MessageTime <= @DisassocTime
				AND HeadEndMilepost != 0
				ORDER BY MessageTime DESC;

				SELECT @ArrLoc = Location
				FROM tblMilepostLocation
				WHERE Subdivision = @ArrLocPTCSubdiv
				AND @ArrLocMilepost BETWEEN StartMilepost AND EndMilepost;
			END
			ELSE
			BEGIN
				-- REVIEW: Nearest non-zero 2080 message or any message?
				SELECT TOP 1 @LocomotiveState = LocomotiveState, @LocoStateSummary = LocoStateSummary
				FROM tblOCM2080Log WITH (NOLOCK)
				WHERE Source = @PrevSource
				AND MessageTime >= @PrevInitTime
				AND HeadEndMilepost != 0
				ORDER BY MessageTime DESC;
			END;
		END;

		/*SELECT TOP 1 @FirstLicenseTime = EventTime 
		FROM tblTMDSLicenseEventLog
		WHERE TrainSymbol = @TrainSymbol
		AND EventTime >= @AssocTime AND (@DisassocTime IS NULL OR EventTime <= @DisassocTime)
		ORDER BY EventTime; */

		IF @PrevInitTime IS NOT NULL
		BEGIN
			INSERT INTO  @retTrainRuns
				(
					TrainSymbol, 
					LocoList, 
					SoftwareVerList, 
					EngineerNameList, 
					DepLoc, 
					DepLocMilepost, 
					FirstInitTime, 
					FirstLicenseTime, 
					DepTime, 
					AssocTime, 
					DisassocTime, 
					DepDelay, 
					ArrLoc, 
					ArrLocMilepost, 
					ArrTime, 
					ActiveDuration,
					TrainRunState,
					LocomotiveState,
					LocoStateSummary,
					EnfCount,
					InitCount
				)
			VALUES
				(
					@TrainSymbol, 
					@LocoList, 
					@SoftwareVerList, 
					@EngineerNameList, 
					@DepLoc, 
					CASE @DepLocPTCSubdiv 
						WHEN 2 THEN 'POMBAL-GUAIBA'
						WHEN 3 THEN 'LINHA DO CENTRO'
						WHEN 100 THEN 'FERROVIA DO ACO'
						ELSE ''
					END + ':' + CAST(@DepLocMilepost AS NVARCHAR),
					@FirstInitTime, 
					@FirstLicenseTime, 
					@DepTime, 
					@AssocTime, 
					@DisassocTime, 
					CASE WHEN @FirstInitTime IS NOT NULL AND @DepTime IS NOT NULL THEN DATEDIFF(MINUTE, @FirstInitTime, @DepTime) ELSE NULL END,
					@ArrLoc, 
					CASE @ArrLocPTCSubdiv 
						WHEN 2 THEN 'POMBAL-GUAIBA'
						WHEN 3 THEN 'LINHA DO CENTRO'
						WHEN 100 THEN 'FERROVIA DO ACO'
						ELSE ''
					END + ':' + CAST(@ArrLocMilepost AS NVARCHAR),
					@ArrTime, 
					CASE 
						WHEN @FirstInitTime IS NOT NULL AND @ArrTime IS NOT NULL THEN DATEDIFF(MINUTE, @FirstInitTime, @ArrTime) 
						WHEN @FirstInitTime IS NOT NULL AND @ArrTime IS NULL THEN DATEDIFF(MINUTE, @FirstInitTime, GETUTCDATE()) 
						ELSE NULL 
					END,
					CASE WHEN @DisassocTime IS NOT NULL THEN 'Completed' ELSE 'Active' END,
					@LocomotiveState,
					@LocoStateSummary,
					@EnfCount,
					@InitCount
			);
		END;
	
		FETCH NEXT FROM TrainRuns
		INTO @TrainSymbol, @AssocTime, @DisassocTime;

	END;

	CLOSE TrainRuns;
	DEALLOCATE TrainRuns;

	RETURN;
END;

GO

