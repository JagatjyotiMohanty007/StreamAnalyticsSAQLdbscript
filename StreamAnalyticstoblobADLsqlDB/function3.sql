USE [MRSProdLogs]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetActiveSplLicenses]    Script Date: 11/28/2017 06:59:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetActiveSplLicenses]()
RETURNS @retLicenses TABLE
	(
		EventSource			NVARCHAR(20) NULL,
		AuthNumber			INT NULL,
		TrainSymbol		    NVARCHAR(60) NULL,
		BeginEndSignal		NVARCHAR(4000) NULL,
		EventTime			DATETIMEOFFSET NULL
	)
AS
BEGIN
	DECLARE 
		@TrainSymbol NVARCHAR(60),
		@AssocTime DATETIMEOFFSET;
	
	DECLARE TrainRuns CURSOR FOR
		WITH tblTMDSTrainEventLogDD AS (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY EventTime, EventType ORDER BY EventTime, EventType) AS ROWNUM
				FROM tblTMDSTrainEventLog WITH (NOLOCK)
			) T WHERE ROWNUM = 1
		)
		SELECT A.TrainSymbol, A.EventTime
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
	INTO @TrainSymbol, @AssocTime;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE 
			@Source NVARCHAR(64) = NULL,
			@InitTime DATETIME = NULL,
			@LocoStateTime DATETIME = NULL,
			@Milepost NUMERIC(15, 6) = NULL,
			@TrackName NVARCHAR(32) = NULL,
			@AuthSegments NVARCHAR(4000) = NULL,
			@LicenseTime DATETIMEOFFSET = NULL,
            @EventSource NVARCHAR(20) = NULL,
            @AuthNumber INT = NULL;
		
        SELECT TOP 1 @Source = Source, @InitTime = MessageTime
		FROM tblOCM2003Log WITH (NOLOCK)
		WHERE TrainId = @TrainSymbol
		AND ReasonForSending = 'Initialization'
		AND MessageTime >= @AssocTime
		ORDER BY MessageTime DESC;

		IF @Source IS NOT NULL
		BEGIN
			SELECT TOP 1 @LocoStateTime = MessageTime, @Milepost = CAST(HeadEndMilepost AS NUMERIC(15, 6))/CAST(10000 AS NUMERIC(15,6)), 
            @TrackName = HeadEndTrackName
			FROM tblOCM2080Log WITH (NOLOCK)
			WHERE Source = @Source
			-- REVIEW: message after init??
			AND MessageTime >= @InitTime
			-- REVIEW: non-zero message or any message?
			AND HeadEndMilepost != 0
			ORDER BY MessageTime DESC;

            -- REVIEW: Special License needs to be taken care and NOT CANCELED license
            SELECT TOP 1 @LicenseTime = EventTime, @AuthSegments = AuthSegments, @EventSource = EventSource, @AuthNumber = AuthNumber
            FROM tblTMDSLicenseEventLog WITH (NOLOCK)
            WHERE TrainSymbol = @TrainSymbol
            AND EventType != 'ROLLUP'
            -- REVIEW: message after init??
            AND EventTime >= @InitTime
            ORDER BY EventTime DESC;

            IF @LocoStateTime IS NOT NULL AND @AuthSegments IS NOT NULL
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

                IF @IsValidLicense = 'TRUE'
                BEGIN
					INSERT INTO @retLicenses
						(
                            EventSource,
                            AuthNumber,
                            TrainSymbol,
                            BeginEndSignal,
							EventTime
						)
					VALUES
						(
							@EventSource, 
							@AuthNumber,
							@TrainSymbol,
							@AuthSegments,
							@LicenseTime
						);                
                END;              
            END;            
        END;

        FETCH NEXT FROM TrainRuns
        INTO @TrainSymbol, @AssocTime;
    END;

	CLOSE TrainRuns;
	DEALLOCATE TrainRuns;

	RETURN;
END;

GO

