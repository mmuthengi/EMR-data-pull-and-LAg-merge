USE [IncidenceTracking]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_pull_linelistpbfw]
AS
BEGIN
	SET NOCOUNT ON;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[linelistpbfw]') AND type in (N'U'))
DROP TABLE [dbo].[linelistpbfw];

SELECT
    *
INTO 
	[IncidenceTracking].[dbo].[linelistpbfw]
FROM 
	[10.230.50.64].[DATA_EXCHANGE].[dbo].[linelistpbfw]
WHERE 
	(breastfeeding = 'yes' or pregnant = 'yes')
AND 
	DateConfirmedHIVPositive >= '2025-09-01'
;
END
GO