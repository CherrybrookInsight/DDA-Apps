--3.	Correct the null 6MWT if distance in other columns
--4.	Correct LVEF data  - the column currently labelled 35-40% should be <=40%, therefore it will included all <=35% patients
--5.	Create EQ3L column + health rating should be available for these.
--6.	Add column in each data sheet for RAS ( if any of ACEI, ARB or ARNI are yes, then RAS = yes)
--7.	Clarify the HF cause type data: options of ischaemic, non-ischaemic, both, pending. This data is from most recent review. There should not be too many “pending” that have had subsequent reviews. 
--8.	Double check logic on the review data regarding cause type –in the different HF datasheets (i.e HFREF recovered should not contain HFREF or HFPEF etc)
--9.	Please display data for the Quality of care parameters and key patient characteristic parameters as (n, %) or Median -IQR as listed in the initial brief. On clinic and national level data

use [HFM_Feed]
go

select @@SERVERNAME [server_name], GETDATE() [as_at_date]
go

DROP TABLE #temp
go

SELECT
  A.HT_PAT_ID,
  A.VISIT_ID,
  V.VISIT_SIGNOFF_DATE,
  V.VISIT_CLINIC,
  CASE
    WHEN TRY_PARSE(P.PAT_DOB AS datetime) IS NOT NULL THEN DATEDIFF(YEAR, CAST(P.PAT_DOB AS date), V.VISIT_SIGNOFF_DATE)
    ELSE NULL
  END AS BaselineAge
  --,CASE WHEN TRY_PARSE(P.PAT_DOB AS datetime) IS NOT NULL THEN datediff(year, CAST(P.PAT_DOB AS DATE), getdate()) ELSE NULL END as CurrentAge
  ,
  P.PAT_GENDER AS Gender,
  ASMNT_INV_ECHOCARDIOGRAPHY_LVEF LVEF,
  ASMNT_INV_LOWEST_LVEF LowestLVEF,
  ROW_NUMBER() OVER (PARTITION BY V.HT_PAT_ID ORDER BY V.VISIT_SIGNOFF_DATE ASC) AS [Baseline],
  ROW_NUMBER() OVER (PARTITION BY V.HT_PAT_ID ORDER BY V.VISIT_SIGNOFF_DATE DESC) AS Recent,
  --5.	Create EQ3L column + health rating should be available for these.
  tab.[_eq_5d_scale_1_100] AS [Health Rating],
  tab.[_eq_5d_score] AS [EQ-5D Score],
  PS.SUM_AGE_CCI [Age-CCI],
  A.ASMNT_HST_DYSPNOEA AS [NYHA Class],
  --A.ASMNT_EX_6MWT AS [6MWT],
  --3.	Correct the null 6MWT if distance in other columns
  CASE    
	When rtrim(ltrim(A.ASMNT_EX_6MWT)) = '' and isnull(A.ASMNT_EX_6MWT_DISTANCE, '') <> '' then 'Yes' 
	When isnull(A.ASMNT_EX_6MWT, '') = '' and isnull(A.ASMNT_EX_6MWT_DISTANCE, '') <> '' then 'Yes'
    ELSE A.ASMNT_EX_6MWT
  END [6MWT],
  A.ASMNT_EX_6MWT_DISTANCE AS [Distance In meters],

  --4.	Correct LVEF data  - the column currently labelled 35-40% should be <=40%, therefore it will included all <=35% patients

  --CASE
  --  WHEN ASMNT_INV_LOWEST_LVEF <= '35.0' THEN 'Yes'
  --  ELSE 'No'
  --END [LowestLVEF<=35%],
  --CASE
  --  WHEN ASMNT_INV_LOWEST_LVEF > '35.0' AND
  --    ASMNT_INV_LOWEST_LVEF <= '40.0' THEN 'Yes'
  --  ELSE 'No'
  --END [LowestLVEF35-40%],
    CASE
	    WHEN ASMNT_INV_LOWEST_LVEF <= '40.0' THEN 'Yes'
    ELSE 'No'
  END [LowestLVEF<=40%],

  CASE
    WHEN ASMNT_INV_LOWEST_LVEF > '40.0' AND
      ASMNT_INV_LOWEST_LVEF <= '49.0' THEN 'Yes'
    ELSE 'No'
  END [LowestLVEF40-49%],
  CASE
    WHEN ASMNT_INV_LOWEST_LVEF >= '50.0' THEN 'Yes'
    ELSE 'No'
  END [LowestLVEF>=50%]
  --,case when V.VISIT_SIGNOFF_DATE then PS.SUM_FAILURE_TYPE end as [Heart Failure Type] -- recent visit
  ,
  --5.	Create EQ3L column + health rating should be available for these.
  --tab.[_eq_5d_scale_1_100] AS [Health Rating],
  --tab.[_eq_5d_score] AS [EQ-5D Score],
  --tab1.[_eq_5d_scale_1_100] AS [Health Rating1],
  tab1.[_eq_5d_score] AS [EQ-5D Score1],
  CASE WHEN tab1._hoc_anxietydepression = 'I am not anxious or depressed.' THEN 1
			WHEN tab1._hoc_anxietydepression = 'I am moderately anxious or depressed.' THEN 2
			WHEN tab1._hoc_anxietydepression = 'I am extremely anxious or depressed.' THEN 3
			ELSE NULL END AS EQ3L_AnxietyDepLevel,


				CASE WHEN tab1._hoc_anxietydepression = 'I am not anxious or depressed.' THEN 1
			WHEN tab1._hoc_anxietydepression = 'I am moderately anxious or depressed.' THEN 2
			WHEN tab1._hoc_anxietydepression = 'I am extremely anxious or depressed.' THEN 3
			ELSE 0 END AS EQ3L_anxiety_score ,
			tab1._hoc_anxietydepression ,
		CASE WHEN tab1._hoc_mobility = 'I have no problems in walking about.' THEN 1
			WHEN tab1._hoc_mobility = 'I have some problems in walking about.' THEN 2
			WHEN tab1._hoc_mobility = 'I am confined to bed.' THEN 3
			ELSE 0 END AS EQ3L_mobility_score ,
			tab1._hoc_mobility,
		CASE WHEN tab1._hoc_paindiscomfort = 'I have no pain or discomfort.' THEN 1
			WHEN tab1._hoc_paindiscomfort = 'I have moderate pain or discomfort.' THEN 2
			WHEN tab1._hoc_paindiscomfort = 'I have extreme pain or discomfort.' THEN 3
			ELSE 0 END AS EQ3L_pain_score ,
			tab1._hoc_paindiscomfort ,
		CASE WHEN tab1._hoc_self_care = 'I have no problems with self-care.' THEN 1
			WHEN tab1._hoc_self_care = 'I have some problems washing or dressing myself.' THEN 2
			WHEN tab1._hoc_self_care = 'I am unable to wash or dress myself.' THEN 3
			ELSE 0 END AS EQ3L_self_care_score ,
			tab1._hoc_self_care,
		CASE WHEN tab1._hoc_usual_activities = 'I have no problems with performing my usual activities.' THEN 1
			WHEN tab1._hoc_usual_activities = 'I have some problems with performing my usual activities.' THEN 2
			WHEN tab1._hoc_usual_activities = 'I am unable to perform my usual activities.' THEN 3 
			ELSE 0 END AS EQ3L_activities_score,
			tab1._hoc_usual_activities,


			--(tab1._hoc_anxietydepression + tab1._hoc_mobility + 	tab1._hoc_paindiscomfort +	tab1._hoc_self_care + tab1._hoc_usual_activities) as EQ3LScore1,

			--[HFM_Feed].[dbo].[HF_Patient_Medical_History].[MH_EQ5D_HEALTH_STATE_TODAY]
			--tab2.[MH_EQ5D_HEALTH_STATE_TODAY] as [EQ3L Health Rating],
			tab1.[_eq_5d_scale_1_100] as [EQ3L Health Rating],
  SUM_FAILURE_TYPE,
  CASE
    WHEN PS.SUM_CAUSE_TYPE_ISCHAEMIC = 'True' THEN 'Ischaemic'
    WHEN PS.SUM_CAUSE_TYPE_NON_ISCHAEMIC = 'True' THEN 'Non-Ischaemic'
    WHEN PS.SUM_CAUSE_TYPE_PENDING = 'True' THEN 'Pending'
    WHEN PS.SUM_CAUSE_TYPE_ISCHAEMIC = 'True' AND
      PS.SUM_CAUSE_TYPE_NON_ISCHAEMIC = 'True' THEN 'Both Non-Ischaemic and Ischaemic'
  END [Cause Type],
  PH.PHARMA_BETA_BLOCKERS AS [Beta-blockers],
  PH.PHARMA_ACE_INHIBITORS AS [ACE Inhibitors],
  PH.PHARMA_ARNI AS [ARNI],
  PH.PHARMA_ARBS AS [ARB],
  PH.PHARMA_DIURETICS AS Diuretics,
  PH.PHARMA_DIURETICS_LOOP AS DIURETICS_LOOP,
  PH.PHARMA_DIURETICS_OTHER AS DIURETICS_OTHER,
  PH.PHARMA_MRA AS MRA,
  PH.[PHARMA_MT_BB] AS [Maximal Tolerated BB] -- HFREF only
  ,
  PH.[PHARMA_MT_ACEI_ARB] AS [Maximal Tolerated ACEI/ARB/ARNI] -- HFREF only
  ,
  PM.MGMT_DEV_CRT_PACEMAKER AS [CRT-P],
  PM.MGMT_DEV_CRT_D AS [CRT-D],
  PM.MGMT_DEV_ICD AS [ICD],
  PM.MGMT_NP_FLUID_RESTRICTION AS [Fluid Restriction],
  PM.MGMT_NP_DAILY_WEIGHT AS [Daily Weights],
  PM.MGMT_NP_SALT_RESTRICTION_ADVICE AS [Salt Restriction],
  PM.MGMT_NP_OBESITY_WEIGHT_MGMT AS [Obesity weight management],
  PM.MGMT_NP_EXERCISE_ADVICE AS [Exercise advice],
  PM.MGMT_NP_SMOKING_CESSATION_ADVICE AS [Smoking cessation advice],
  PM.MGMT_NP_ALCOHOL_REDUCTION_ADVICE AS [Alcohol reduction advice],
  PM.MGMT_NP_CARDIAC_REHABILITATION AS [Cardiac rehabilitation],
  PM.MGMT_NP_CARDIAC_ANTICOAG_THERAPY AS [Anticoagulation therapy education],
  H.HP_DATE_OF_ADMISSION AS DateOfAdmission,
  H.HP_HOSPITALISATION_NUMBER AS HospitalisationNumber,
  H.HP_DATE_OF_DISCHARGE AS DateOfDischarge,
  tab.[_all_cause_mortality] AS [All Cause Mortality]
--,datediff(day, try_convert(date,HP_DATE_OF_ADMISSION) , getdate()) as Diff
--,CASE WHEN
--(A.ASMNT_HST_LEG_OEDEMA = 'Yes' or A.ASMNT_EX_OEDEMA_NIL is null or A.ASMNT_EX_JVP = '> 3' or A.ASMNT_EX_CHEST != 'Clear' or PH.PHARMA_DIURETICS = 'Yes' or PH.PHARMA_DIURETICS_LOOP = 'Yes' or 
--PS.SUM_VOLUME_STATUS = 'hypervolemic') THEN 'Yes' else 'No' END VolumeOverload


INTO #temp
FROM HF_Patient_Assesment A
JOIN HF_Visit_mapping V
  ON A.HT_PAT_ID = V.HT_PAT_ID
  AND A.VISIT_ID = V.VISIT_ID
JOIN HF_Patient_Profile P
  ON A.HT_PAT_ID = P.HT_PAT_ID
  AND A.VISIT_ID = P.VISIT_ID
JOIN HF_Patient_Medical_History MH
  ON A.HT_PAT_ID = MH.HT_PAT_ID
  AND A.VISIT_ID = MH.VISIT_ID
LEFT JOIN HF_Patient_Pharma PH
  ON A.HT_PAT_ID = PH.HT_PAT_ID
  AND A.VISIT_ID = PH.VISIT_ID
LEFT JOIN HF_Patient_Hospitalisations H
  ON A.HT_PAT_ID = H.HT_PAT_ID
  AND A.VISIT_ID = H.VISIT_ID
LEFT JOIN HF_Patient_Summary PS
  ON A.HT_PAT_ID = PS.HT_PAT_ID
  AND A.VISIT_ID = PS.VISIT_ID
--left join HF_Patient_Drugs PD on A.HT_PAT_ID = PD.HT_PAT_ID and A.VISIT_ID = PD.VISIT_ID  and  PH.HT_PAT_ID = PD.HT_PAT_ID and PH.VISIT_ID = PD.VISIT_ID and PD.MGMT_PH_NAME = 'Digoxin' and PD.MGMT_PH_TYPE = 'hoc-other-hf-drugs-drugs'
LEFT JOIN HF_Patient_Management PM
  ON A.HT_PAT_ID = PM.HT_PAT_ID
  AND A.VISIT_ID = PM.VISIT_ID
LEFT JOIN [HFM_Feed].[dbo].[HFMAppDataHOC] tab
  ON A.HT_PAT_ID = tab.patient_id
  AND A.VISIT_ID = tab.uuid

  LEFT JOIN [HFM_Feed].[dbo].[HFMAppDataHOC] tab1
  ON A.HT_PAT_ID = tab1.patient_id
  AND A.VISIT_ID = tab1.uuid
 and tab1.form_type = 'HOCV1'

 --left join [HFM_Feed].[dbo].[HF_Patient_Medical_History] tab2
 --on A.HT_PAT_ID = tab2.[HT_PAT_ID]
 -- AND A.VISIT_ID = tab2.[VISIT_ID]
 -- and tab2.HT_PAT_ID = tab1.patient_id
 -- and tab2.VISIT_ID = tab1.uuid 
 -- and tab1.form_type = 'HOCV1'

--where
--(case when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF >= '50.0' then ASMNT_INV_ECHOCARDIOGRAPHY_LVEF
--   when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF = '' then case when ASMNT_INV_LOWEST_LVEF >= '50.0' then ASMNT_INV_LOWEST_LVEF end
--end) >= '50.0'



--DROP TABLE #temp
--;


SELECT
  *
FROM #temp
WHERE recent = 1
AND HT_PAT_ID = 141672
ORDER BY VISIT_SIGNOFF_DATE ASC


--Key Characteristics at National
SELECT DISTINCT
'Key Characteristics at National' DataSection,
  t1.HT_PAT_ID,
  t1.VISIT_SIGNOFF_DATE,
  t1.BaselineAge,
  t1.Gender,
  t1.[Age-CCI],
  t1.[NYHA Class],
  t1.[6MWT],
  t1.[Distance In meters],
  --5.	Create EQ3L column + health rating should be available for these.
  --tab.[_eq_5d_scale_1_100] AS [Health Rating],
  --tab.[_eq_5d_score] AS [EQ-5D Score],
  --t1.[LowestLVEF<=35%],
  --t1.[LowestLVEF35-40%],
  t1.[LowestLVEF<=40%],
  t1.[LowestLVEF40-49%],
  t1.[LowestLVEF>=50%],
  t3.SUM_FAILURE_TYPE,
  t3.[Cause Type]
FROM #temp t1
JOIN #temp t2
  ON t1.ht_pat_id = t2.ht_pat_id
  AND t1.baseline = 1
JOIN #temp t3
  ON t1.ht_pat_id = t3.ht_pat_id
  AND t3.recent = 1
--where t1.HT_PAT_ID = 141672
;


/*
--select distinct t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,t1.BaselineAge,t1.Gender,t1.[Age-CCI],t1.[NYHA Class],t1.[6MWT],t1.[Distance In meters],
--t1.[LowestLVEF<=35%],t1.[LowestLVEF35-40%],t1.[LowestLVEF40-49%],t1.[LowestLVEF>=50%],
--t3.SUM_FAILURE_TYPE,t3.[Cause Type] 
--from 
--#temp t1
--join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
--join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1

--Key Characteristics at Clinic
SELECT DISTINCT
  t1.VISIT_CLINIC,
  t1.HT_PAT_ID,
  t1.VISIT_SIGNOFF_DATE,
  t1.BaselineAge,
  t1.Gender,
  t1.[Health Rating],
  t1.[EQ-5D Score],
  t1.[Age-CCI],
  t1.[NYHA Class],
  t1.[6MWT],
  t1.[Distance In meters],
  --t1.[LowestLVEF<=35%],
  --t1.[LowestLVEF35-40%],
  t1.[LowestLVEF<=40%],
  t1.[LowestLVEF40-49%],
  t1.[LowestLVEF>=50%],
  t3.SUM_FAILURE_TYPE,
  t3.[Cause Type]
FROM #temp t1
JOIN #temp t2
  ON t1.ht_pat_id = t2.ht_pat_id
  AND t1.baseline = 1
JOIN #temp t3
  ON t1.ht_pat_id = t3.ht_pat_id
  AND t3.recent = 1
--where t1.HT_PAT_ID = 141672
;
*/

--Key Characteristics at Clinic
SELECT DISTINCT
'KEY CHARACTERISTICS DETAILS' as 'KEY CHARACTERISTICS DETAILS'
,
  t1.VISIT_CLINIC,
  t1.HT_PAT_ID,
  t1.VISIT_SIGNOFF_DATE,
  t1.BaselineAge,
  t1.Gender,
  t1.[Health Rating],
  --ad.[_hoc_your_own_health_state_today] [health_state_today],
  --ad.[_eq_5d_scale_1_100] AS [Health Rating??],
  t1.[EQ-5D Score],
  --t1.[EQ3L_AnxietyDepLevel],
  --t1.[EQ3L_activities_score],
  --t1.[EQ3L_anxiety_score],
  --t1.[EQ3L_mobility_score],
  --t1.[EQ3L_pain_score],
  --t1.[EQ3L_self_care_score],
  --t1.EQ3LScore1,
  (  t1.[EQ3L_AnxietyDepLevel]+  t1.[EQ3L_activities_score]+ t1.[EQ3L_anxiety_score]+ t1.[EQ3L_mobility_score]+  t1.[EQ3L_pain_score]+  t1.[EQ3L_self_care_score]) as [EQ3L Score],
  t1.[EQ3L Health Rating],
  --t1.[EQ-5D Score1],
  --t1.[Health Rating1],
  t1.[Age-CCI],
  t1.[NYHA Class],
  t1.[6MWT],
  t1.[Distance In meters],
  --t1.[LowestLVEF<=35%],
  --t1.[LowestLVEF35-40%],
  t1.[LowestLVEF<=40%],
  t1.[LowestLVEF40-49%],
  t1.[LowestLVEF>=50%],
  t3.SUM_FAILURE_TYPE,
  t3.[Cause Type]
FROM #temp t1
JOIN #temp t2
  ON t1.ht_pat_id = t2.ht_pat_id
  AND t1.baseline = 1
JOIN #temp t3
  ON t1.ht_pat_id = t3.ht_pat_id
  AND t3.recent = 1
--where t1.HT_PAT_ID = 141672
--;
left join [HFM_Feed].[dbo].[HFMAppDataHOC] ad on t1.HT_PAT_ID = ad.[patient_id]
  --FROM [HFM_Feed].[dbo].[HFMAppDataHOC]
  --where [_hoc_your_own_health_state_today] is not null 



--Baseline Quality Of Care at National
SELECT DISTINCT
'BASELINE QUALITY OF CARE AT NATIONAL' [BASELINE QUALITY OF CARE AT NATIONAL],
  t1.baseline,
  t1.recent,
  t1.HT_PAT_ID,
  t1.VISIT_SIGNOFF_DATE,
  t1.[Beta-blockers],
  t1.[ACE Inhibitors],
  t1.[ARNI],
  t1.ARB,
  t1.Diuretics,
  t1.DIURETICS_LOOP,
  t1.DIURETICS_OTHER,
  t1.MRA,
  t1.[Maximal Tolerated BB],
  t1.[Maximal Tolerated ACEI/ARB/ARNI],
  t1.[CRT-P],
  t1.[CRT-D],
  t1.[ICD],
  t1.[Fluid Restriction],
  t1.[Daily Weights],
  t1.[Salt Restriction],
  t1.[Obesity weight management],
  t1.[Exercise advice],
  t1.[Smoking cessation advice],
  t1.[Alcohol reduction advice],
  t1.[Cardiac rehabilitation],
  t1.[Anticoagulation therapy education],
  t1.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
FROM #temp t1
JOIN #temp t2
  ON t1.ht_pat_id = t2.ht_pat_id
  AND t1.baseline = 1
--join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
WHERE t1.SUM_FAILURE_TYPE = 'Right HF'
AND t1.baseline = 1  --and t1.HT_PAT_ID = 165628
;
--Recent Quality Of Care at National
SELECT DISTINCT
  t3.baseline,
  t3.recent,
  t3.HT_PAT_ID,
  t3.VISIT_SIGNOFF_DATE,
  t3.[Beta-blockers],
  t3.[ACE Inhibitors],
  t3.[ARNI],
  t3.ARB,
  t3.Diuretics,
  t3.DIURETICS_LOOP,
  t3.DIURETICS_OTHER,
  t3.MRA,
  t3.[Maximal Tolerated BB],
  t3.[Maximal Tolerated ACEI/ARB/ARNI],
  t3.[CRT-P],
  t3.[CRT-D],
  t3.[ICD],
  t3.[Fluid Restriction],
  t3.[Daily Weights],
  t3.[Salt Restriction],
  t3.[Obesity weight management],
  t3.[Exercise advice],
  t3.[Smoking cessation advice],
  t3.[Alcohol reduction advice],
  t3.[Cardiac rehabilitation],
  t3.[Anticoagulation therapy education],
  t3.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
FROM #temp t1
--join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
JOIN #temp t3
  ON t1.ht_pat_id = t3.ht_pat_id
  AND t3.recent = 1
WHERE t1.SUM_FAILURE_TYPE = 'Right HF'
AND t3.recent = 1
;
SELECT
  *
FROM HF_Visit_Mapping
WHERE HT_PAT_ID = 141672
ORDER BY VISIT_SIGNOFF_DATE ASC

;
--Baseline Quality Of Care at Clinic Level
SELECT DISTINCT
  t1.visit_clinic,
  t1.HT_PAT_ID,
  t1.VISIT_SIGNOFF_DATE,
  CASE
    WHEN t1.[Beta-blockers] = 'Yes' THEN 1
    ELSE 0
  END [Beta-blockers],
  CASE
    WHEN t1.[ACE Inhibitors] = 'Yes' THEN 1
    ELSE 0
  END [ACE Inhibitors],
  CASE
    WHEN t1.[ARNI] = 'Yes' THEN 1
    ELSE 0
  END [ARNI],
  CASE
    WHEN t1.ARB = 'Yes' THEN 1
    ELSE 0
  END ARB,
  CASE
    WHEN t1.Diuretics = 'Yes' THEN 1
    ELSE 0
  END Diuretics,
  CASE
    WHEN t1.DIURETICS_LOOP = 'Yes' THEN 1
    ELSE 0
  END DIURETICS_LOOP,
  CASE
    WHEN t1.DIURETICS_OTHER = 'Yes' THEN 1
    ELSE 0
  END DIURETICS_OTHER,
  CASE
    WHEN t1.MRA = 'Yes' THEN 1
    ELSE 0
  END MRA,
  CASE
    WHEN t1.[Maximal Tolerated BB] = 'Yes' THEN 1
    ELSE 0
  END [Maximal Tolerated BB],
  CASE
    WHEN t1.[Maximal Tolerated ACEI/ARB/ARNI] = 'Yes' THEN 1
    ELSE 0
  END [Maximal Tolerated ACEI/ARB/ARNI],
  CASE
    WHEN t1.[CRT-P] = 'Yes' THEN 1
    ELSE 0
  END [CRT-P],
  CASE
    WHEN t1.[CRT-D] = 'Yes' THEN 1
    ELSE 0
  END [CRT-D],
  CASE
    WHEN t1.[ICD] = 'Yes' THEN 1
    ELSE 0
  END [ICD],
  CASE
    WHEN t1.[Fluid Restriction] = 'Yes' THEN 1
    ELSE 0
  END [Fluid Restriction],
  CASE
    WHEN t1.[Daily Weights] = 'Yes' THEN 1
    ELSE 0
  END [Daily Weights],
  CASE
    WHEN t1.[Salt Restriction] = 'Yes' THEN 1
    ELSE 0
  END [Salt Restriction],
  CASE
    WHEN t1.[Obesity weight management] = 'Yes' THEN 1
    ELSE 0
  END [Obesity weight management],
  CASE
    WHEN t1.[Exercise advice] = 'Yes' THEN 1
    ELSE 0
  END [Exercise advice],
  CASE
    WHEN t1.[Smoking cessation advice] = 'Yes' THEN 1
    ELSE 0
  END [Smoking cessation advice],
  CASE
    WHEN t1.[Alcohol reduction advice] = 'Yes' THEN 1
    ELSE 0
  END [Alcohol reduction advice],
  CASE
    WHEN t1.[Cardiac rehabilitation] = 'Yes' THEN 1
    ELSE 0
  END [Cardiac rehabilitation],
  CASE
    WHEN t1.[Anticoagulation therapy education] = 'Yes' THEN 1
    ELSE 0
  END [Anticoagulation therapy education],
  t1.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
INTO #HFREF@Clinic@B
FROM #temp t1
JOIN #temp t2
  ON t1.ht_pat_id = t2.ht_pat_id
  AND t1.baseline = 1
--join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
--where t1.SUM_FAILURE_TYPE = 'HFREF'   and t1.baseline = 1 
;
DROP TABLE #HFREF@B@Clinic
;
SELECT
  visit_clinic,
  SUM(TRY_CONVERT(int, [Beta-blockers])) [Beta-blockers],
  SUM(TRY_CONVERT(int, [ACE Inhibitors])) [ACE Inhibitors],
  SUM(TRY_CONVERT(int, [ARNI])) [ARNI],
  SUM(TRY_CONVERT(int, ARB)) ARB,
  SUM(TRY_CONVERT(int, Diuretics)) Diuretics,
  SUM(TRY_CONVERT(int, DIURETICS_LOOP)) DIURETICS_LOOP,
  SUM(TRY_CONVERT(int, DIURETICS_OTHER)) DIURETICS_OTHER,
  SUM(TRY_CONVERT(int, MRA)) MRA,
  SUM(TRY_CONVERT(int, [Maximal Tolerated BB])) [Maximal Tolerated BB],
  SUM(TRY_CONVERT(int, [Maximal Tolerated ACEI/ARB/ARNI])) [Maximal Tolerated ACEI/ARB/ARNI],
  SUM(TRY_CONVERT(int, [CRT-P])) [CRT-P],
  SUM(TRY_CONVERT(int, [CRT-D])) [CRT-D],
  SUM(TRY_CONVERT(int, [ICD])) [ICD],
  SUM(TRY_CONVERT(int, [Fluid Restriction])) [Fluid Restriction],
  SUM(TRY_CONVERT(int, [Daily Weights])) [Daily Weights],
  SUM(TRY_CONVERT(int, [Salt Restriction])) [Salt Restriction],
  SUM(TRY_CONVERT(int, [Obesity weight management])) [Obesity weight management],
  SUM(TRY_CONVERT(int, [Exercise advice])) [Exercise advice],
  SUM(TRY_CONVERT(int, [Smoking cessation advice])) [Smoking cessation advice],
  SUM(TRY_CONVERT(int, [Alcohol reduction advice])) [Alcohol reduction advice],
  SUM(TRY_CONVERT(int, [Cardiac rehabilitation])) [Cardiac rehabilitation],
  SUM(TRY_CONVERT(int, [Anticoagulation therapy education])) [Anticoagulation therapy education]

FROM #HFREF@Clinic@B
WHERE SUM_FAILURE_TYPE = 'Right HF '
GROUP BY visit_clinic

--Recent Quality Of Care at Clinic Level
SELECT DISTINCT
  t3.visit_clinic,
  t3.HT_PAT_ID,
  t3.VISIT_SIGNOFF_DATE,
  CASE
    WHEN t3.[Beta-blockers] = 'Yes' THEN 1
    ELSE 0
  END [Beta-blockers],
  CASE
    WHEN t3.[ACE Inhibitors] = 'Yes' THEN 1
    ELSE 0
  END [ACE Inhibitors],
  CASE
    WHEN t3.[ARNI] = 'Yes' THEN 1
    ELSE 0
  END [ARNI],
  CASE
    WHEN t3.ARB = 'Yes' THEN 1
    ELSE 0
  END ARB,
  CASE
    WHEN t3.Diuretics = 'Yes' THEN 1
    ELSE 0
  END Diuretics,
  CASE
    WHEN t3.DIURETICS_LOOP = 'Yes' THEN 1
    ELSE 0
  END DIURETICS_LOOP,
  CASE
    WHEN t3.DIURETICS_OTHER = 'Yes' THEN 1
    ELSE 0
  END DIURETICS_OTHER,
  CASE
    WHEN t3.MRA = 'Yes' THEN 1
    ELSE 0
  END MRA,
  CASE
    WHEN t3.[Maximal Tolerated BB] = 'Yes' THEN 1
    ELSE 0
  END [Maximal Tolerated BB],
  CASE
    WHEN t3.[Maximal Tolerated ACEI/ARB/ARNI] = 'Yes' THEN 1
    ELSE 0
  END [Maximal Tolerated ACEI/ARB/ARNI],
  CASE
    WHEN t3.[CRT-P] = 'Yes' THEN 1
    ELSE 0
  END [CRT-P],
  CASE
    WHEN t3.[CRT-D] = 'Yes' THEN 1
    ELSE 0
  END [CRT-D],
  CASE
    WHEN t3.[ICD] = 'Yes' THEN 1
    ELSE 0
  END [ICD],
  CASE
    WHEN t3.[Fluid Restriction] = 'Yes' THEN 1
    ELSE 0
  END [Fluid Restriction],
  CASE
    WHEN t3.[Daily Weights] = 'Yes' THEN 1
    ELSE 0
  END [Daily Weights],
  CASE
    WHEN t3.[Salt Restriction] = 'Yes' THEN 1
    ELSE 0
  END [Salt Restriction],
  CASE
    WHEN t3.[Obesity weight management] = 'Yes' THEN 1
    ELSE 0
  END [Obesity weight management],
  CASE
    WHEN t3.[Exercise advice] = 'Yes' THEN 1
    ELSE 0
  END [Exercise advice],
  CASE
    WHEN t3.[Smoking cessation advice] = 'Yes' THEN 1
    ELSE 0
  END [Smoking cessation advice],
  CASE
    WHEN t3.[Alcohol reduction advice] = 'Yes' THEN 1
    ELSE 0
  END [Alcohol reduction advice],
  CASE
    WHEN t3.[Cardiac rehabilitation] = 'Yes' THEN 1
    ELSE 0
  END [Cardiac rehabilitation],
  CASE
    WHEN t3.[Anticoagulation therapy education] = 'Yes' THEN 1
    ELSE 0
  END [Anticoagulation therapy education],
  t3.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
INTO #HFREF@Clinic@R
FROM #temp t1
JOIN #temp t3
  ON t1.ht_pat_id = t3.ht_pat_id
  AND t3.recent = 1
;
SELECT
  visit_clinic,
  SUM(TRY_CONVERT(int, [Beta-blockers])) [Beta-blockers],
  SUM(TRY_CONVERT(int, [ACE Inhibitors])) [ACE Inhibitors],
  SUM(TRY_CONVERT(int, [ARNI])) [ARNI],
  SUM(TRY_CONVERT(int, ARB)) ARB,
  SUM(TRY_CONVERT(int, Diuretics)) Diuretics,
  SUM(TRY_CONVERT(int, DIURETICS_LOOP)) DIURETICS_LOOP,
  SUM(TRY_CONVERT(int, DIURETICS_OTHER)) DIURETICS_OTHER,
  SUM(TRY_CONVERT(int, MRA)) MRA,
  SUM(TRY_CONVERT(int, [Maximal Tolerated BB])) [Maximal Tolerated BB],
  SUM(TRY_CONVERT(int, [Maximal Tolerated ACEI/ARB/ARNI])) [Maximal Tolerated ACEI/ARB/ARNI],
  SUM(TRY_CONVERT(int, [CRT-P])) [CRT-P],
  SUM(TRY_CONVERT(int, [CRT-D])) [CRT-D],
  SUM(TRY_CONVERT(int, [ICD])) [ICD],
  SUM(TRY_CONVERT(int, [Fluid Restriction])) [Fluid Restriction],
  SUM(TRY_CONVERT(int, [Daily Weights])) [Daily Weights],
  SUM(TRY_CONVERT(int, [Salt Restriction])) [Salt Restriction],
  SUM(TRY_CONVERT(int, [Obesity weight management])) [Obesity weight management],
  SUM(TRY_CONVERT(int, [Exercise advice])) [Exercise advice],
  SUM(TRY_CONVERT(int, [Smoking cessation advice])) [Smoking cessation advice],
  SUM(TRY_CONVERT(int, [Alcohol reduction advice])) [Alcohol reduction advice],
  SUM(TRY_CONVERT(int, [Cardiac rehabilitation])) [Cardiac rehabilitation],
  SUM(TRY_CONVERT(int, [Anticoagulation therapy education])) [Anticoagulation therapy education]

FROM #HFREF@Clinic@R
WHERE SUM_FAILURE_TYPE = 'Right HF'
GROUP BY visit_clinic

--Clinical Outcomes 1.a
SELECT
  c.visit_signoff_date,
  h.HP_DATE_OF_ADMISSION,
  TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103),
  CASE
    WHEN
      (TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103)) <= (DATEADD(DAY, 30, CAST(c.visit_signoff_date AS date))) THEN 'Yes'
  END [30 Days],
  CASE
    WHEN
      ((TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103))) > (DATEADD(DAY, 30, CAST(c.visit_signoff_date AS date))) AND
      ((TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103)) <= (DATEADD(DAY, 180, CAST(c.visit_signoff_date AS date)))) THEN 'Yes'
  END [6 months],
  CASE
    WHEN
      ((TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103)) > (DATEADD(DAY, 180, CAST(c.visit_signoff_date AS date))) AND
      (TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103)) <= (DATEADD(DAY, 365, CAST(c.visit_signoff_date AS date)))) THEN 'Yes'
  END [1 Year],
  DATEADD(DAY, 365, CAST(c.visit_signoff_date AS date))
FROM HF_Patient_Hospitalisations h
LEFT JOIN #temp c
  ON h.HT_PAT_ID = c.HT_PAT_ID --and h.VISIT_ID = c.visit_id
WHERE c.baseline = 1
AND h.HT_PAT_ID = 135759
;
--Clinical Outcomes 1.b
SELECT
  c.HT_PAT_ID,
  COUNT(TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103))
FROM HF_Patient_Hospitalisations h
LEFT JOIN #temp c
  ON h.HT_PAT_ID = c.HT_PAT_ID --and h.VISIT_ID = c.visit_id
WHERE c.baseline = 1
--and h.HT_PAT_ID = 135759
AND (TRY_CONVERT(date, h.HP_DATE_OF_ADMISSION, 103)) <= (DATEADD(DAY, 365, CAST(c.visit_signoff_date AS date)))
GROUP BY c.HT_PAT_ID
;
--Clinical Outcomes - 1.c
SELECT
  *
FROM HF_Patient_Hospitalisations
;
-- 1.d - ((136/958)/3) * 100% = 4.73%
;
-- 2. All-cause mortality  -- No at baseline
SELECT
  *
FROM #temp
WHERE [all cause mortality] = 'Yes'
AND baseline = 1
;


/*
Hi Daniel, Veeresh, 

Thanks for the meeting today and great work thus far. 

The key points for clarification are (may not be inclusive):

1.	Establishing no. of patients, which is distinct from the no. of clinic visits
2.	Classification of site. If null look for later classification of site – most of these predate the later app update and are most likely Bundoora or less likely Langwarrin. If there is no later entry with a site and pre 2017 – put down as Bundoora. 
3.	Correct the null 6MWT if distance in other columns
4.	Correct LVEF data  - the column currently labelled 35-40% should be <=40%, therefore it will included all <=35% patients
5.	Create EQ3L column + health rating should be available for these.
6.	Add column in each data sheet for RAS ( if any of ACEI, ARB or ARNI are yes, then RAS = yes)
7.	Clarify the HF cause type data: options of ischaemic, non-ischaemic, both, pending. This data is from most recent review. There should not be too many “pending” that have had subsequent reviews. 
8.	Double check logic on the review data regarding cause type –in the different HF datasheets (i.e HFREF recovered should not contain HFREF or HFPEF etc)
9.	Please display data for the Quality of care parameters and key patient characteristic parameters as (n, %) or Median -IQR as listed in the initial brief. On clinic and national level data

Thanks, I appreciate your hard work on this important data.
Dr Leighton Kearney
Cardiologist and Clinical Services Director – Heart Failure
Genesis Care

From: Veeresh Mallisetti 
Sent: Tuesday, 29 May 2018 2:45 PM
To: Leighton Kearney
Cc: Wendy Addison-Davey; Daniel Zhou
Subject: RE: Discussion on Heart Failure Data for Heart Foundation Gala

Hi Leighton,

Good Day. 

I will schedule a meeting tomorrow at 10.30.  Daniel, our new Data Analyst  will also join this meeting who would be working on this data extracts.

Thanks,
Veeresh Mallisetti
Business Intelligence Analyst
GenesisCare
Innovating Healthcare. Transforming Lives.

From: Leighton Kearney 
Sent: Monday, 28 May 2018 10:19 PM
To: Veeresh Mallisetti <veeresh.mallisetti@genesiscare.com.au>
Cc: Wendy Addison-Davey <Wendy.Addison-Davey@genesiscare.com.au>
Subject: RE: Discussion on Heart Failure Data for Heart Foundation Gala

Hi Veeresh and Wendy

Can we catch up at some stage on Wednesday to discuss please. I am free from 830-11.25 or from 3.30 to 5.00

Thanks, 

Leighton

Dr Leighton Kearney
Cardiologist and Clinical Services Director – Heart Failure
Genesis Care

From: Veeresh Mallisetti 
Sent: Wednesday, 23 May 2018 4:30 PM
To: Leighton Kearney
Cc: Wendy Addison-Davey
Subject: RE: Discussion on Heart Failure Data for Heart Foundation Gala

Hi Leighton,

Good Afternoon.

I have prepared the data  for all sections present in the document except Clinical outcomes. I am yet to start working on Clinical Outcomes.

Till now, I have consolidated all sheets into one spreadsheet with relevant names.

Kindly take note of sheet names. 

For e.g., sheet 'QC-HFREF-National(B)' stands for Quality of Care for HFREF at national level for Baseline visits
                            'QC-HFREF-Nat(R)' stands for Quality of Care for HFREF at national level for Recent visits.


Kindly let me know if we need to schedule a meeting to discuss on the same.

Thanks,
Veeresh Mallisetti
Business Intelligence Analyst
GenesisCare
Innovating Healthcare. Transforming Lives.

-----Original Message-----
From: Leighton Kearney 
Sent: Wednesday, 16 May 2018 10:12 PM
To: Veeresh Mallisetti <veeresh.mallisetti@genesiscare.com.au>
Subject: RE: Discussion on Heart Failure Data for Heart Foundation Gala

Hi Veeresh,

Thanks for the discussion today. I look forward to seeing the initial data.

Leighton

________________________________________
From: Veeresh Mallisetti
Sent: Wednesday, 16 May 2018 9:10 AM
To: Leighton Kearney
Subject: RE: Discussion on Heart Failure Data for Heart Foundation Gala

HI Leighton,

No worries. I have rescheduled the meeting from 12PM to 1 PM.


Thanks,
Veeresh Mallisetti
Business Intelligence Analyst
GenesisCare
Innovating Healthcare. Transforming Lives.

-----Original Message-----
From: Leighton Kearney
Sent: Tuesday, 15 May 2018 7:05 PM
To: Veeresh Mallisetti <veeresh.mallisetti@genesiscare.com.au>
Subject: Re: Discussion on Heart Failure Data for Heart Foundation Gala

Sorry can’t do proposed time. I can do anytime between 12-6pm tomorrow (Wednesday 16th) or after 7.30 pm tomorrow

Leighton

Sent from my iPhone

> On 15 May 2018, at 9:57 am, Veeresh Mallisetti <Veeresh.Mallisetti@genesiscare.com.au> wrote:
>
> Hi Leighton & Wendy,
>
> Good Morning.
>
>
> I am planning to schedule a meeting to discuss on the requirements for Heart Failure data extract for Gala ball.
>
> Kindly do let me know if this timing suits your calendar else please feel free to suggest a new timing.
>
> Thank You.
>
> Best Regards,
> Veeresh Mallisetti
> Business Intelligence Analyst
> GenesisCare
> Innovating Healthcare. Transforming Lives.
>
>
>
> To join the meeting on a computer or mobile phone:
> https://bluejeans.com/151946478?src=calendarLink
>
> Veeresh  Kumar Mallisetti has invited you to a video meeting.
> -----------------------------------
> Connecting directly from a room system?
>
> 1) Dial: 199.48.152.152 or bjn.vc
> 2) Enter Meeting ID: 151946478
>
> Joining from a TIPT video handset?
>
> 1) Dial 03 9260 9999 then enter the Meeting ID: 151946478 Just want to 
> dial in on your phone?
>
> 1) Dial one of the following numbers:
> +61.8.7070.8060 (Adelaide, AU)
> +61.7.3123.4461 (Brisbane, AU)
> +61.3.8400.4256 (Melbourne, AU)
> +61.8.6365.4437 (Perth, AU)
> +61.2.8103.4256 (Sydney, AU)
> +852.5808.4756 (HK)
> +39.05.104.20256 (IT)
> +34.911.235.256 (ES)
> +44.203.608.5256 (GB)
> +1.888.240.2560 (US Toll Free)
> +86.400.120.2896 (China (National))
> 86.10.8783.3402 (China (Mandarin))
>
> https://bluejeans.com/numbers
> 2) Enter Meeting ID: 151946478
> 3) Press #
>
> -----------------------------------
> Want to test your video connection?
> https://bluejeans.com/111
>
>
> <meeting.ics>



*/


--Hi Daniel,

--As discussed, Please find attached data requests from Dr.Leighton. We will have a meeting tomorrow and introduce you to Dr.Leighton to take it forward from here.
--Please do let me know in case of any queries.

--Thanks,
--Veeresh Mallisetti
--Business Intelligence Analyst
--GenesisCare
--Innovating Healthcare. Transforming Lives.