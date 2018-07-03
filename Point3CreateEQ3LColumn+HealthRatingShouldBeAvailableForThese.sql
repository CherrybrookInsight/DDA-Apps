USE [HFM_Feed]
GO

/****** Object:  StoredProcedure [dbo].[LoadHFExtract]    Script Date: 4/06/2018 10:55:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Phil Stevens
-- Create date: 30/01/2018
-- Description:	Process for extracting HeartFailure data from the combined table of v1 and v2 data
-- =============================================
ALTER PROCEDURE [dbo].[LoadHFExtract]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

-- Truncate Output table ready for new data
TRUNCATE TABLE [HFM_Feed].dbo.HFExtract

-- Load LVEF data
IF OBJECT_ID('tempdb..#LVEF') is not null
Drop Table #LVEF;

SELECT 
		--REPLACE(REPLACE(CASE WHEN LEFT(_hoc_lvef,2) = '' THEN NULL ELSE LEFT([_hoc_lvef],2) END,'0',''),'.','') LVEF, 
		--Modified above column in order to correct the missing zero from LVEF
		CASE WHEN LEFT(_hoc_lvef,2) = '' THEN NULL ELSE LEFT([_hoc_lvef],2) END as LVEF,
		signoff_date, 
		patient_id
INTO #LVEF
FROM HFMAppDataHOC

-- Load Lowest LVEF data
IF OBJECT_ID('tempdb..#LowLVEF') is not null
Drop Table #LowLVEF;

SELECT --REPLACE(REPLACE(CASE WHEN LEFT([_hoc_lowest_lvef],2) = '' THEN NULL ELSE LEFT([_hoc_lowest_lvef],2) END,'0',''),'.','') LowestLVEF, 
		--Modified above column in order to correct the missing zero from LVEF
		CASE WHEN LEFT([_hoc_lowest_lvef],2) = '' THEN NULL ELSE LEFT([_hoc_lowest_lvef],2) END as LowestLVEF,
		signoff_date, 
		patient_id
INTO #LowLVEF
FROM HFMAppDataHOC

--Load Medications Data
IF OBJECT_ID('tempdb..#Meds') is not null
Drop Table #Meds;

select 
[patient_id],
[patient_record_uuid] as uuid,
[name],
[dose]
into #Meds
from medications
where
     (medications.[name] like '%Sacubitril/valsartan%'
   or
      medications.[name] like '%Entrest%'
   or
      medications.[name] like '%valsartan/Sacubitril%'
     )


-- Load Latest Data
IF OBJECT_ID('tempdb..#Latest') is not null
Drop Table #Latest;

select * 
into #Latest
from
    (
      select 
      uuid,
	  patient_id,
	  cast([signoff_date] as date) as SignOffDate,
	  currentD = ROW_NUMBER() OVER (PARTITION BY [patient_id] ORDER BY signoff_date desc) 
      from HFMAppDataHOC late
    ) x where currentD = 1


-- Load Digoxin Data
IF OBJECT_ID('tempdb..#Digoxin') is not null
Drop Table #Digoxin;

select 
     [patient_id],
	 [patient_record_uuid] as uuid,
	 [name],
	 [dose]
into #Digoxin
from medications
where medications.[name] like '%digoxin%'


-- Load 2016 Admissions (not a complete year so removed)
--IF OBJECT_ID('tempdb..#numAdmissions2016') is not null
--Drop Table #numAdmissions2016;

--SELECT 
--     [patient_id] as patient_id,
--	 COUNT(hospitalisations.[patient_id]) AS numAdmissions
--INTO #numAdmissions2016
--FROM hospitalisations
--where RIGHT(hospitalisations.[_date],4)  = '2016'
--group by hospitalisations.[patient_id]

IF OBJECT_ID('tempdb..#deceased') is not null
Drop Table #deceased;

SELECT patient_id, [_all_cause_mortality_s1]
INTO #deceased
FROM [dbo].[HFMAppDataHOC]
WHERE ISNULL([_all_cause_mortality_s1],'') != '' 
	AND CAST(RIGHT([_all_cause_mortality_s1],4) AS INT)  < 2017

-- Discharged Before 2017
IF OBJECT_ID('tempdb..#discharge') is not null
Drop Table #discharge;

SELECT patient_id, [_hospital_discharge_date]
INTO #discharge
FROM [dbo].[HFMAppDataHOC]
WHERE ISNULL([_hospital_discharge_date],'') != '' 
	AND CAST(RIGHT([_hospital_discharge_date],4) AS INT)  < 2017


-- Load 2017 Admissions
IF OBJECT_ID('tempdb..#numAdmissions2017') is not null
Drop Table #numAdmissions2017;

SELECT 
      [patient_id] as patient_id,
	  COUNT(hospitalisations.[patient_id]) AS numAdmissions2017
INTO #numAdmissions2017
FROM hospitalisations
where RIGHT(hospitalisations.[_date],4)  = '2017'  
group by hospitalisations.[patient_id]

-- Perform manual EQ5D scoring calculation as this was not pre-calculated as part of version 1
IF OBJECT_ID('tempdb..#EQ5D') is not null
Drop Table #EQ5D;

SELECT [uuid],
		CASE WHEN _hoc_anxietydepression = 'I am not anxious or depressed.' THEN 1
			WHEN _hoc_anxietydepression = 'I am moderately anxious or depressed.' THEN 2
			WHEN _hoc_anxietydepression = 'I am extremely anxious or depressed.' THEN 3
			ELSE 0 END AS anxiety_score ,
			_hoc_anxietydepression ,
		CASE WHEN _hoc_mobility = 'I have no problems in walking about.' THEN 1
			WHEN _hoc_mobility = 'I have some problems in walking about.' THEN 2
			WHEN _hoc_mobility = 'I am confined to bed.' THEN 3
			ELSE 0 END AS mobility_score ,
			_hoc_mobility,
		CASE WHEN _hoc_paindiscomfort = 'I have no pain or discomfort.' THEN 1
			WHEN _hoc_paindiscomfort = 'I have moderate pain or discomfort.' THEN 2
			WHEN _hoc_paindiscomfort = 'I have extreme pain or discomfort.' THEN 3
			ELSE 0 END AS pain_score ,
			_hoc_paindiscomfort ,
		CASE WHEN _hoc_self_care = 'I have no problems with self-care.' THEN 1
			WHEN _hoc_self_care = 'I have some problems washing or dressing myself.' THEN 2
			WHEN _hoc_self_care = 'I am unable to wash or dress myself.' THEN 3
			ELSE 0 END AS self_care_score ,
			_hoc_self_care,
		CASE WHEN _hoc_usual_activities = 'I have no problems with performing my usual activities.' THEN 1
			WHEN _hoc_usual_activities = 'I have some problems with performing my usual activities.' THEN 2
			WHEN _hoc_usual_activities = 'I am unable to perform my usual activities.' THEN 3 
			ELSE 0 END AS activities_score,
			_hoc_usual_activities
			
INTO #EQ5D
FROM [HFMAppDataHOC]
WHERE form_type = 'HOCV1'

--ToDo: add script to do similar caculation for EQ3L
-- Perform manual EQ5D scoring calculation as this was not pre-calculated as part of version 1
					CASE WHEN _hoc_anxietydepression = 'I am not anxious or depressed.' THEN 1
			WHEN _hoc_anxietydepression = 'I am moderately anxious or depressed.' THEN 2
			WHEN _hoc_anxietydepression = 'I am extremely anxious or depressed.' THEN 3
			ELSE 0 END AS anxiety_score ,
--I am not anxious or depressed
--I am moderately anxious or depressed
--I am extremely anxious or depressed

--else 0
--I am slightly anxious or depressed
--I am severely anxious or depressed



; WITH query AS 
       (
       select * from
       (SELECT DISTINCT  
             HFMAppDataHOC.[uuid] as uuid
             ,firstname
             ,surname
        ,baseline = ROW_NUMBER() OVER (PARTITION BY HFMAppDataHOC.[patient_id] ORDER BY HFMAppDataHOC.signoff_date aSC)
        ,cast(HFMAppDataHOC.[signoff_date] as date) as BaselineDate
           ,CASE WHEN TRY_PARSE(dob AS datetime) IS NULL THEN NULL ELSE dob END as dob
             ,HFMAppDataHOC.patient_id
           ,CASE WHEN TRY_PARSE(dob AS datetime) IS NOT NULL THEN datediff(year, CAST(dob AS DATE), getdate()) ELSE NULL END as Age
        ,sex
             ,entity
             ,HFMAppDataHOC._letter_options_doctor_name as Doctor
             ,[_hoc_bmi] as BMI
        ,[_hoc_dyspnoea] 
           , CAST(LowLVEF.LowestLVEF AS decimal) as LowestLVEF
             , CAST(LVEF.LVEF AS decimal) as LVEF 
        ,[_hoc_bnp_pgml] as BNPpgml
        ,[_hoc_nt_probnp_pgml] as NTProBNP
           , datediff(year, cast(left(signoff_date, 10) as date), getdate()) as '(Yrs) Since Diagosis'
        ,[_hoc_beta_blockers] as BetaBlockers
        ,[_hoc_beta_no_s1_not_indicated_hfpef_rhf_or_hfref_not_yet_on_aceiarb] as BBNotIndicated
             ,[_hoc_beta_no_s1_allergy] as BBAllergy
             ,[_hoc_beta_no_s1_hypotension_systolic_bp_90_mmhg] as BBHTSY90
           ,[_hoc_beta_no_s1_fluid_overload] as BBFluidOverload
           ,[_hoc_beta_no_s1_asthma] as BBAsthma
           ,[_hoc_beta_no_s1_bradycardia_hr60_bpm] as BBrady
             ,[_hoc_beta_no_s1_2nd_or_3rd_degree_av_block] as BBDAVBlock
        ,[_hoc_beta_no_s1_other] as BBOther
        ,[_hoc_diuretics] as Diuretics
        ,[_hoc_mra] as MRA
        ,[_hoc_ace_inhibitors] as ACEI
        ,[_hoc_arbs] as ARBS
		,[_hoc_arni] as ARNI
        ,[_hoc_icd] as ICD
        ,[_hoc_pacemaker] as Pacemaker
		,[_hoc_crt_pacemaker] as CRT
		,[_mgmt_dev_crt_d] as CRT_D
		,[_mh_cv_cad] as CAD
		,[_hoc_non_ischaemic_ischaemic] AS HF_Ischaemic
		,[_hoc_non_ischaemic_non_ischaemic] AS HF_Non_Ischaemic
		,[_hoc_non_ischaemic_pending] AS HF_Pending
		,CASE WHEN form_type = 'HOCV1' THEN E.anxiety_score + E.mobility_score + E.pain_score + E.self_care_score + E.activities_score ELSE NULL END AS Eq5DScore_v1
        ,CASE WHEN form_type = 'HOCV2' THEN [_eq_5d_score] ELSE NULL END as EQ5DScore_v2
        ,[_hoc_systolic] as LyingSystolic
        ,_hoc_egfr_crcl_mlmin as eGFR
        ,[_hoc_hypertension]
        ,[_hoc_diabetes]
        ,[_hoc_moderate_valve_disease_mmhg] as ValvularHD
           ,[_hoc_arrhythmia_type_atrial_fibrillationflutter] 
        ,[_hoc_exertional] 
        ,[_hoc_airway_disease_type_copd]
		--Added to include Asthma & ILD
		,[_hoc_airway_disease_type_asthma]
		,[_hoc_airway_disease_type_ild]
        ,[_hoc_cva]        
        ,_hoc_ami
             ,_hoc_revascularisation    
           ,[_hoc_revascularisation_type_pci]
        ,[_hoc_revascularisation_type_cabg]     
             ,[_hospitalisations_since_last_visit_num_hospitalisations] as hospitalisations
             ,_hoc_referral_source
			 --Added New Column for Heart Failure Type
			 , _hoc_heart_failure_type   as HeartFailureType                        

  FROM HFMAppDataHOC
    LEFT JOIN 
	(
		SELECT l.patient_id, LVEF
		FROM #LVEF l
		INNER JOIN 
			(	SELECT MIN(signoff_date) as signoff_date, patient_id
				FROM #LVEF
				WHERE LVEF IS NOT NULL
				GROUP BY patient_id
			) minLVEF ON l.patient_id = minLVEF.patient_id AND l.signoff_date = minLVEF.signoff_date
	) AS LVEF ON HFMAppDataHOC.patient_id = LVEF.patient_id
	LEFT JOIN 
	(
		SELECT l.patient_id, LowestLVEF
		FROM #LowLVEF l
		INNER JOIN 
			(	SELECT MIN(signoff_date) as signoff_date, patient_id
				FROM #LowLVEF
				WHERE LowestLVEF IS NOT NULL
				GROUP BY patient_id
			) minLVEF ON l.patient_id = minLVEF.patient_id AND l.signoff_date = minLVEF.signoff_date
	) AS LowLVEF ON HFMAppDataHOC.patient_id = LowLVEF.patient_id
	LEFT JOIN #EQ5D E
		ON [HFMAppDataHOC].[uuid] = E.uuid
) x where baseline = 1

)


INSERT INTO HFM_Feed.dbo.HFExtract
select distinct
             BaselineDate
             ,query.patient_id
             ,firstname
             ,surname
             ,dob
             ,query.age
        ,sex
             ,entity
             ,case entity
                    when 'VIC' then 'VIC'
                    when 'Optiheart' then 'VIC'
                    when 'SA' then 'SA'
             end as State
             ,DrSpeciality = 'Non-Invasive'
             ,BMI
             ,case _hoc_referral_source
                           when 'Hospital' then '1'
                           else '0'
             end as hospitalReferral
             ,0 as numAdmissions2016
             , case when d.patient_id IS NULL  THEN -- removing deceased patients from admission count
					case when dis.patient_id IS NULL THEN
						 case numAdmissions2017
								when '1' then '1'
								when '2' then '2'
								when '3' then '3'
								when '4' then '4'
								else convert(varchar(11),isnull(numAdmissions2017,0))
						 end
						 else NULL
					end
				else NULL 
				end as numAdmissions2017
             ,_hoc_dyspnoea as 'NYHA Class'
        ,case when _hoc_dyspnoea like '%NYHA Class I' then 1 else 0 end [NYHA Class I]
        ,case when _hoc_dyspnoea like '%NYHA Class II' then 1 else 0 end [NYHA Class II]
        ,case when _hoc_dyspnoea like '%NYHA Class III%' then 1 else 0 end [NYHA Class III]
        ,case when _hoc_dyspnoea like '%NYHA Class IV%' then 1 else 0 end [NYHA Class IV]
             ,CAST(LVEF AS decimal)
             ,CAST(query.LowestLVEF AS decimal)
             ,case when CAST(LVEF AS decimal) between 1 and 35 then 1 else 0 end [LVEF =<35]			 
             ,case when CAST(LVEF AS decimal) >35 then 1 else 0 end [LVEF >35]
             ,case when CAST(LVEF AS decimal) between 1 and 40 then 1 else 0 end [LVEF <=40]
			 ,case when CAST(LVEF AS decimal) >40 then 1 else 0 end [LVEF >40]
			 ,BNPpgml
             ,NTProBNP
             ,[(Yrs) Since Diagosis]
             ,#meds.name as BaselineEntresto
             ,#meds.dose as BaselineEntrestoDose
             ,#latest.SignOffDate as LatestDate
             ,M2.name as CurrentEnt
             ,M2.dose as CurrentEntDose
             ,case when BetaBlockers = 'Yes' then 1 else 0 end BetaBlockers
             ,case when BBNotIndicated = 'True' then 1 else 0 end BBNotIndcated
             ,case when (BBAllergy = 'true' or BBHTSY90 = 'true' or BBFluidOverload = 'true' or BBAsthma = 'true' or BBrady = 'true' or BBDAVBlock = 'true' or BBOther = 'true') then 1 else 0 end BetaBlockerNotTolerated
             ,case when Diuretics = 'Yes' then 1 else 0 end Diuretics
             ,case when MRA = 'Yes' then 1 else 0 end MRA
             ,case when #digoxin.name like '%Digoxin%' then 1 else 0 end Digoxin
             ,case when ACEI = 'Yes' then 1 else 0 end ACEI
             ,case when ARBS = 'Yes' then 1 else 0 end ARB
			 ,case when ARNI = 'Yes' then 1 else 0 end as ARNI
			 ,case when ACEI = 'Yes' OR ARBS = 'Yes' OR ARNI = 'Yes' THEN 1 else 0 end as [ACEI_ARB_ARNI_Combo]
             ,case when ICD = 'Yes'  then 1 else 0 end as ICD
             ,case when Pacemaker = 'Yes' then 1 else 0 end Pacemaker
			 ,case when CRT = 'Yes' then 1 else 0 end as CRT
			 ,case when CRT_D = 'Yes' then 1 else 0 end as CRT_D
			 ,case when CAD = 'Yes' then 1 else 0 end as CAD
			 ,case when HF_Ischaemic = 'True' then 1 else 0 end as HF_Ischaemic
			 ,case when HF_Non_Ischaemic = 'True' then 1 else 0 end as HF_Non_Ischaemic
			 ,case when HF_Pending = 'True' then 1 else 0 end as HF_Pending 
             ,EQ5DScore_v1
			 ,EQ5DScore_v2
             ,LyingSystolic
             ,eGFR
             ,case when [_hoc_hypertension] = 'Yes' then 1 else 0 end Hyptertension
             ,case when [_hoc_diabetes] = 'Yes' then 1 else 0 end Diabetes
             ,case when ValvularHD = 'Yes' then 1 else 0 end ValvularHD 
             ,case when [_hoc_arrhythmia_type_atrial_fibrillationflutter] = 'True' then 1 else 0 end AF
             ,case when [_hoc_exertional] = 'Yes' then 1 else 0 end [Angina(Stable)] 
             ,case when [_hoc_airway_disease_type_copd] = 'True' or [_hoc_airway_disease_type_asthma] = 'True' or [_hoc_airway_disease_type_ild] = 'True' 
			 then 1 else 0 end COPD 
             ,case when [_hoc_cva] = 'Yes' then 1 else 0 end [Prior Stroke/TIA] 
             ,case when _hoc_ami = 'Yes' then 1 else 0 end PriorMI
             ,case when _hoc_revascularisation = 'Yes' then 1 else 0 end PriorRevascularisation
             ,case when [_hoc_revascularisation_type_cabg] = 'True' then 1 else 0 end PriorCABG
             ,case when [_hoc_revascularisation_type_pci] = 'True' then 1 else 0 end PriorPCI
			 ,2 as version_source
			 ,case when ICD = 'Yes'  OR CRT = 'Yes' OR CRT_D = 'Yes' then 1 else 0 end as [ICD_CRT]
			 ,case when HeartFailureType = 'HFREF' or HeartFailureType = 'HFREF (recovered)' then 1 else 0 end as HeartFailureType
			 -- Added New Column to capture Lowest of LowestLVEF if present else Lowest of LVEF
			 ,case when CAST(LowLVEFAll.LowestLVEF as decimal) is not null THEN CAST(LowLVEFAll.LowestLVEF as decimal) 
			 WHEN (CAST(LowLVEFAll.LowestLVEF as decimal) is null) and (CAST(LVEFAll.minLVEF as decimal) is not null) THEN CAST(LVEFAll.minLVEF as decimal) 
			 WHEN (CAST(LowLVEFAll.LowestLVEF as decimal) is not null) and (CAST(LVEFAll.minLVEF as decimal) is not null) 
			 THEN (case when (CAST(LowLVEFAll.LowestLVEF as decimal)) < (CAST(LVEFAll.minLVEF as decimal)) then CAST(LowLVEFAll.LowestLVEF as decimal) else (CAST(LVEFAll.minLVEF as decimal)) end)
			 end as LowestLVEF_LVEF
			 --,case when (CAST(query.LowestLVEF_LVEF AS decimal) <= 40)  then 1 else 
				--case when (CAST(LVEF AS decimal) is NULL) and ([_hoc_heart_failure_type] = 'HFREF' or [_hoc_heart_failure_type] = 'HFREF (recovered)')
			 --then 1 else 0 end
			 --end
			  ,'' as [LVEF<=40_HFREF]
			 ,case when (query.HF_Ischaemic = 'True')  and (query.HF_Non_Ischaemic = 'True') then 1 else 0 end [Ischaemic_Non-Ischaemic]

       from query 

       left join #digoxin on query.uuid = #digoxin.uuid
       left join #meds on query.uuid = #meds.uuid
       left join #Latest on query.patient_id = #Latest.patient_id 
       left join #meds as M2 on #latest.uuid = M2.uuid 
       --left join #numAdmissions2016 on query.patient_id = #numAdmissions2016.patient_id
       left join #numAdmissions2017 on query.patient_id = #numAdmissions2017.patient_id
	   left join #deceased d on query.patient_id = d.patient_id
	   --Added discharge temp table
	   left join #discharge dis on query.patient_id = dis.patient_id
		-- To retrieve Lowest of LowestLVEF for all assesements done for a patient
	   LEFT JOIN 
		(
			SELECT l.patient_id,min(l.LowestLVEF) as LowestLVEF
			FROM #LowLVEF l
			INNER JOIN 
				(	SELECT MIN(LowestLVEF) as LowestLVEF, patient_id
					FROM #LowLVEF
					WHERE LowestLVEF IS NOT NULL
					GROUP BY patient_id
				) minLVEF ON l.patient_id = minLVEF.patient_id AND l.LowestLVEF = minLVEF.LowestLVEF
				GROUP BY L.patient_id
		) AS LowLVEFAll ON query.patient_id = LowLVEFAll.patient_id
		-- To retrieve Lowest of LVEF for all assesements done for a patient
		LEFT JOIN 
		(
			SELECT lv.patient_id, MIN(lv.LVEF) as minLVEF
			FROM #LVEF lv
			INNER JOIN 
				(	SELECT MIN(LVEF) as LVEF, patient_id
					FROM #LVEF
					WHERE LVEF IS NOT NULL
					GROUP BY patient_id
				) minLVEFAll ON lv.patient_id = minLVEFAll.patient_id AND lv.LVEF = minLVEFAll.LVEF
				GROUP BY lv.patient_id
		) AS LVEFAll ON query.patient_id = LVEFAll.patient_id

             
       WHERE 

       dob <> 'none'

order by query.baselineDate

-- Set the LVEF to LowestLVEF if the result is still NULL
UPDATE HFM_Feed.dbo.HFExtract
SET LVEF = CAST(LowestLVEF AS Decimal)
WHERE (LVEF IS NULL OR LVEF = 0) AND ISNULL(LowestLVEF, 0) != 0

-- Finally reset all the LVEF band data based on the new values
UPDATE HFM_Feed.dbo.HFExtract
SET [LVEF =<35] = case when CAST(LVEF AS DECIMAL) between 1.00 and 35.00 then 1 else 0 end, 		 
    [LVEF >35] = case when CAST(LVEF AS DECIMAL) >35.00 then 1.00 else 0 end ,
	--Replacing LVEF with logic of new column LowestLVEF_LVEF
    [LVEF <=40] = case when CAST(LOWESTLVEF_LVEF AS DECIMAL) between 1.00 and 40.00 then 1 else 0 end ,
	--Replacing LVEF with logic of new column LowestLVEF_LVEF
    [LVEF >40] = case when CAST(LOWESTLVEF_LVEF AS DECIMAL) >40.00 then 1 else 0 end,
	[LVEF<=40_HFREF] = (
		case when (CAST(LowestLVEF_LVEF AS decimal) <= 40.00 )
			  then 1 
			  when CAST(LowestLVEF_LVEF AS decimal) is NULL then
				(case when HeartFailureType = 1
					then 1 
					else 0 
				end)
				else 0
			 end
	)
END


GO


