USE [IncidenceTracking]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_emr_pmtct_lag]
AS
BEGIN
	SET NOCOUNT ON;


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[emr_pmtct_lag]') AND type in (N'U'))
DROP TABLE [dbo].[emr_pmtct_lag];

CREATE TABLE [dbo].[emr_pmtct_lag](
	[Id] [int] NOT NULL Identity(1,1),
	[CCCHash] [nvarchar](100) NULL,
	[SiteCode] [int] NULL,
	[sex] [nvarchar](240) NULL,
	[DOB] [date] NULL,
	[maritalstatus] [nvarchar](400) NULL,
	[FacilityName] [varchar](250) NULL,
	[StartARTDate] [date] NULL,
	[DateConfirmedHIVPositive] [date] NULL,
	[Breastfeeding] [bit] NOT NULL,
	[Pregnant] [bit] NOT NULL,
	[ARTOutcomeDescription] [varchar](17) NULL,
	[county] [nvarchar](255) NULL,
	[sub_county] [nvarchar](255) NULL,
	[vl_lab_name] [nvarchar](255) NULL,
	[molecular_lab_name] [nvarchar](255) NULL,
	[vl_date_collected] [date] NULL,
	[vl_date_received] [date] NULL,
	[vl_date_tested] [date] NULL,
	[vl_result] [nvarchar](255) NULL,
	[date_lag_tested] [date] NULL,
	[is_vl_sample_received] [int] NULL,
	[has_vl_results] [int] NULL,
	[is_tested_lag] [int] NULL,
) ON [PRIMARY]
;

WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY facility_mfl_code, hashed_ccc
            ORDER BY vl_date_collected ASC
        ) AS rn
    FROM dbo.lag
)

Insert into [dbo].[emr_pmtct_lag](
	[CCCHash],
	[SiteCode],
	[sex],
	[DOB],
	[maritalstatus],
	[FacilityName],
	[StartARTDate],
	[DateConfirmedHIVPositive],
	[Breastfeeding],
	[Pregnant],
	[ARTOutcomeDescription],
	[county],
	[sub_county],
	[vl_lab_name],
	[molecular_lab_name],
	[vl_date_collected],
	[vl_date_received],
	[vl_date_tested],
	[vl_result],
	[date_lag_tested]
)

select 
	e.CCCHash,
	e.sitecode,
	e.Sex,
	e.DOB,
	e.maritalstatus,
	e.facilityname,
	e.startartdate,
	e.DateConfirmedHIVPositive,
	CASE e.Breastfeeding WHEN 'yes' THEN 1 ELSE 0 END AS Breastfeeding,
	CASE e.Pregnant WHEN 'yes' THEN 1 ELSE 0 END AS Pregnant,
	e.ARTOutcomeDescription,
	l.county,
	l.sub_county,
	l.vl_lab_name,
	l.molecular_lab_name,
	l.vl_date_collected,
	l.vl_date_received,
	l.vl_date_tested,
	l.vl_result,
	l.date_lag_tested

from 
[linelistpbfw] e
left join 
ranked l 
on e.ccchash = l.hashed_ccc
and e.sitecode = l.facility_mfl_code
and l.rn = 1
Where ARTOutcomeDescription <> 'TRANSFERRED OUT'
;


update [dbo].[emr_pmtct_lag]
set [is_vl_sample_received] = 1
where [vl_date_received] IS NOT NULL
;

update [dbo].[emr_pmtct_lag]
set [has_vl_results] = 1
where [vl_result] IS NOT NULL
;

update [dbo].[emr_pmtct_lag]
set [is_tested_lag] = 1
where [date_lag_tested] IS NOT NULL
;
END
GO


