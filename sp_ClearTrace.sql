use [master]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'sp_ClearTrace')
  EXEC ('CREATE PROCEDURE [dbo].[sp_ClearTrace] AS PRINT ''Method stub''');
GO


ALTER PROCEDURE [dbo].[sp_ClearTrace] (
	@Directory NVARCHAR(1000) = NULL, 
	@FileName NVARCHAR(1000) = NULL,
	@Minutes INT = 5,
	@TimeStampFile bit = 1,
	@RolloverSize BIGINT = 200,
	@MinCPU INT = NULL,
	@MinReads BIGINT = NULL,
	@MinDuration BIGINT = NULL,
	@MinWrites BIGINT = NULL,
	@IncludeStatements BIT = 0 
		)
AS

----------------------------------------------------------------------------------
--
-- Trace creation script for use with ClearTrace
--
-- Copyright ScaleOut Consulting, LLC
-- 
----------------------------------------------------------------------------------


SET NOCOUNT ON 

IF @Directory IS NULL OR @FileName is NULL 
  BEGIN
	PRINT 'Usage: sp_ClearTrace
	 
	@Directory (Required), 
	@FileName (Required),

	@TraceMinutes (Optional -- Defaults to 5),
	@IncludeTimeStamp (Optional -- Defaults to 1),
	@MaxFileSize (Optional -- Defaults to 200),
	@MinCPU (Optional),
	@MinReads (Optional),
	@MinDuration (Optional),
	@MinWrites (Optional),
	@IncludeStatements (Optional -- Defaults to 0 [WARNING: HUGE TRACE!])
	'
	return 1
  END

-- Need to add this in the docs
-- @IncludeStatements (Optional -- Defaults to 0 [WARNING: HUGE TRACE!])


DECLARE @TraceFileName NVARCHAR(1000)
DECLARE @TempFileName NVARCHAR(1000)
DECLARE @TraceID INT
DECLARE @RC INT

DECLARE @TraceStopTime DATETIME
SELECT @TraceStopTime = DATEADD(mi, @Minutes, GETDATE())

IF OBJECT_ID('tempdb..#FileExistResult') IS NOT NULL
    DROP TABLE #FileExistResult	

CREATE TABLE #FileExistResult (FileExists INT, Directory INT, Parent INT)

-- Parse Directory
IF @Directory IS NULL
    BEGIN
	RAISERROR ('Invalid Directory specified', 16, 1)
	return 1
    END

-- Check that the directory exists
INSERT #FileExistResult
EXEC xp_fileexist @Directory

IF NOT EXISTS ( SELECT * FROM #FileExistResult WHERE Directory = 1)
    BEGIN
	RAISERROR ('Invalid Directory specified', 16, 1)
	return 1
    END


-- Parse FileName
IF @FileName IS NULL
    BEGIN
	RAISERROR ('Invalid FileName specified', 16, 1)
	return 1
    END


-- Build the trace file name
IF RIGHT(@Directory, 1) <> '\'
	SET @Directory = @Directory + '\'

IF RIGHT(@FileName, 4) = '.trc'
	SET @FileName = LEFT(@FileName, LEN(@FileName) - 4)

-- Add an optional datestamp to the file name
if @TimeStampFile = 1
	SET @FileName = @FileName + '_D' + CONVERT(VARCHAR, GETDATE(), 112) + '_Z' +  REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '')

SET @TraceFileName = @Directory + @FileName

-- Start the trace
exec @rc = sp_trace_create @TraceID output, 2, @TraceFileName, @RolloverSize, @TraceStopTime 
if (@rc <> 0) 
    BEGIN
	RAISERROR ('Error calling sp_trace_create', 16, 1)
	return @RC
    END

-- Set the events
declare @on bit
set @on = 1
------------------------------------------------------------------------------------------
-- Paste all sp_trace_setevent statements here
------------------------------------------------------------------------------------------
-- Text Data
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 12, 1, @on

-- Host Name
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 12, 8, @on

-- Application Name
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 12, 10, @on

-- Login Name
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 12, 11, @on

exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 15, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 12, 15, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 18, @on

-- statement level events
IF @IncludeStatements = 1 
  BEGIN 
	exec sp_trace_setevent @TraceID, 45, 16, @on
	exec sp_trace_setevent @TraceID, 45, 1, @on
	exec sp_trace_setevent @TraceID, 45, 9, @on
	exec sp_trace_setevent @TraceID, 45, 17, @on
	exec sp_trace_setevent @TraceID, 45, 10, @on
	exec sp_trace_setevent @TraceID, 45, 18, @on
	exec sp_trace_setevent @TraceID, 45, 11, @on
	exec sp_trace_setevent @TraceID, 45, 12, @on
	exec sp_trace_setevent @TraceID, 45, 13, @on
	exec sp_trace_setevent @TraceID, 45, 6, @on
	exec sp_trace_setevent @TraceID, 45, 14, @on
	exec sp_trace_setevent @TraceID, 45, 15, @on


	exec sp_trace_setevent @TraceID, 41, 15, @on
	exec sp_trace_setevent @TraceID, 41, 16, @on
	exec sp_trace_setevent @TraceID, 41, 1, @on
	exec sp_trace_setevent @TraceID, 41, 9, @on
	exec sp_trace_setevent @TraceID, 41, 17, @on
	exec sp_trace_setevent @TraceID, 41, 10, @on
	exec sp_trace_setevent @TraceID, 41, 18, @on
	exec sp_trace_setevent @TraceID, 41, 11, @on
	exec sp_trace_setevent @TraceID, 41, 12, @on
	exec sp_trace_setevent @TraceID, 41, 13, @on
	exec sp_trace_setevent @TraceID, 41, 6, @on
	exec sp_trace_setevent @TraceID, 41, 14, @on
  END 
------------------------------------------------------------------------------------------
-- End sp_trace_setevent statements
------------------------------------------------------------------------------------------

-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler'

-- exclude the connectioin pooling reset command
exec sp_trace_setfilter @TraceID, 1, 0, 7, N'exec sp_reset_connection'

-- Duration Filter
IF @MinDuration IS NOT NULL
  BEGIN
	exec @RC = sp_trace_setfilter @TraceID, 13, 0, 4, @MinDuration
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Duration', 16, 1)
		return @RC
	    END
  END


-- Reads Filter
IF @MinReads IS NOT NULL
	exec @RC = sp_trace_setfilter @TraceID, 16, 0, 4, @MinReads
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Reads', 16, 1)
		return @RC
	    END

-- CPU Filter
IF @MinCPU IS NOT NULL
	exec @RC = sp_trace_setfilter @TraceID, 18, 0, 4, @MinCPU
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Reads', 16, 1)
		return @RC
	    END


-- Writes Filter
IF @MinWrites IS NOT NULL
	exec @RC = sp_trace_setfilter @TraceID, 17, 0, 4, @MinWrites
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Writes', 16, 1)
		return @RC
	    END


-- Set the trace status to start
exec @RC = sp_trace_setstatus @TraceID, 1
if (@rc <> 0) 
    BEGIN
	RAISERROR ('Trace failed to start', 16, 1)
	return @RC
    END

-- display trace id for future references
Print 'TraceID: ' + CAST(@TraceID AS VARCHAR)
PRINT 'Tracing to: ' + @TempFileName
Print 'Run for ' + CAST(@Minutes AS VARCHAR) + ' minute(s) until ' + CONVERT(VARCHAR, @TraceStopTime)

IF @MinDuration IS NOT NULL
	PRINT 'Duration Filter: ' + CAST(@MinDuration AS VARCHAR) + 'ms'

IF @MinCPU IS NOT NULL
	PRINT 'CPU Filter: ' + CAST(@MinCPU AS VARCHAR) + 'ms'

IF @MinReads IS NOT NULL
	PRINT 'Reads Filter: ' + CAST(@MinReads AS VARCHAR) + ' 8KB Reads'

IF @MinWrites IS NOT NULL
	PRINT 'Writes Filter: ' + CAST(@MinWrites AS VARCHAR) + ' 8KB Writes'




DROP TABLE #FileExistResult


GO


