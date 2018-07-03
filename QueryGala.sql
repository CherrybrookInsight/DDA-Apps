use Adhoc
go

select 
A.HT_PAT_ID
,A.VISIT_ID
,V.VISIT_SIGNOFF_DATE
,V.VISIT_CLINIC
,CASE 
	WHEN TRY_PARSE(P.PAT_DOB AS datetime) IS NOT NULL THEN datediff(year, CAST(P.PAT_DOB AS DATE), V.VISIT_SIGNOFF_DATE) 
	ELSE NULL 
	END as BaselineAge
--,CASE WHEN TRY_PARSE(P.PAT_DOB AS datetime) IS NOT NULL THEN datediff(year, CAST(P.PAT_DOB AS DATE), getdate()) ELSE NULL END as CurrentAge
,P.PAT_GENDER as Gender
,ASMNT_INV_ECHOCARDIOGRAPHY_LVEF LVEF,ASMNT_INV_LOWEST_LVEF LowestLVEF
,ROW_NUMBER() OVER (PARTITION BY V.HT_PAT_ID ORDER BY V.VISIT_SIGNOFF_DATE asc) as [Baseline]
,ROW_NUMBER() OVER (PARTITION BY V.HT_PAT_ID ORDER BY V.VISIT_SIGNOFF_DATE desc) as Recent
,tab.[_eq_5d_scale_1_100] as [Health Rating]
,tab.[_eq_5d_score] as [EQ-5D Score]

,PS.SUM_AGE_CCI [Age-CCI]
,A.ASMNT_HST_DYSPNOEA as [NYHA Class]
,A.ASMNT_EX_6MWT as [6MWT]
,A.ASMNT_EX_6MWT_DISTANCE as [Distance In meters]
,case when ASMNT_INV_LOWEST_LVEF <= '35.0' then 'Yes' else 'No' end [LowestLVEF<=35%]
,case when ASMNT_INV_LOWEST_LVEF > '35.0' and ASMNT_INV_LOWEST_LVEF <= '40.0' then 'Yes' else 'No' end [LowestLVEF35-40%]
,case when ASMNT_INV_LOWEST_LVEF > '40.0' and ASMNT_INV_LOWEST_LVEF <= '49.0' then 'Yes' else 'No' end [LowestLVEF40-49%]
,case when ASMNT_INV_LOWEST_LVEF >= '50.0' then 'Yes' else 'No' end [LowestLVEF>=50%]
--,case when V.VISIT_SIGNOFF_DATE then PS.SUM_FAILURE_TYPE end as [Heart Failure Type] -- recent visit
,SUM_FAILURE_TYPE
,case when PS.SUM_CAUSE_TYPE_ISCHAEMIC = 'True' then 'Ischaemic' when PS.SUM_CAUSE_TYPE_NON_ISCHAEMIC = 'True' then 'Non-Ischaemic' when PS.SUM_CAUSE_TYPE_PENDING = 'True' then 'Pending'
when PS.SUM_CAUSE_TYPE_ISCHAEMIC = 'True' and PS.SUM_CAUSE_TYPE_NON_ISCHAEMIC = 'True' then 'Both Non-Ischaemic and Ischaemic' end [Cause Type]

,PH.PHARMA_BETA_BLOCKERS as [Beta-blockers]
,PH.PHARMA_ACE_INHIBITORS as [ACE Inhibitors]
,PH.PHARMA_ARNI as [ARNI]
,PH.PHARMA_ARBS as [ARB]
,PH.PHARMA_DIURETICS as Diuretics
,PH.PHARMA_DIURETICS_LOOP as DIURETICS_LOOP
,PH.PHARMA_DIURETICS_OTHER as DIURETICS_OTHER
,PH.PHARMA_MRA as MRA
,PH.[PHARMA_MT_BB] as [Maximal Tolerated BB] -- HFREF only
,PH.[PHARMA_MT_ACEI_ARB] as [Maximal Tolerated ACEI/ARB/ARNI] -- HFREF only
,PM.MGMT_DEV_CRT_PACEMAKER as [CRT-P]
,PM.MGMT_DEV_CRT_D as [CRT-D]
,PM.MGMT_DEV_ICD as [ICD]
,PM.MGMT_NP_FLUID_RESTRICTION as [Fluid Restriction]
,PM.MGMT_NP_DAILY_WEIGHT as [Daily Weights]
,PM.MGMT_NP_SALT_RESTRICTION_ADVICE as [Salt Restriction]
,PM.MGMT_NP_OBESITY_WEIGHT_MGMT as [Obesity weight management]
,PM.MGMT_NP_EXERCISE_ADVICE as [Exercise advice]
,PM.MGMT_NP_SMOKING_CESSATION_ADVICE as [Smoking cessation advice]
,PM.MGMT_NP_ALCOHOL_REDUCTION_ADVICE as [Alcohol reduction advice]
,PM.MGMT_NP_CARDIAC_REHABILITATION as [Cardiac rehabilitation]
,PM.MGMT_NP_CARDIAC_ANTICOAG_THERAPY as [Anticoagulation therapy education]
,H.HP_DATE_OF_ADMISSION as DateOfAdmission
,H.HP_HOSPITALISATION_NUMBER as HospitalisationNumber
,H.HP_DATE_OF_DISCHARGE as DateOfDischarge
,tab.[_all_cause_mortality] as [All Cause Mortality]
--,datediff(day, try_convert(date,HP_DATE_OF_ADMISSION) , getdate()) as Diff
--,CASE WHEN
--(A.ASMNT_HST_LEG_OEDEMA = 'Yes' or A.ASMNT_EX_OEDEMA_NIL is null or A.ASMNT_EX_JVP = '> 3' or A.ASMNT_EX_CHEST != 'Clear' or PH.PHARMA_DIURETICS = 'Yes' or PH.PHARMA_DIURETICS_LOOP = 'Yes' or 
--PS.SUM_VOLUME_STATUS = 'hypervolemic') THEN 'Yes' else 'No' END VolumeOverload


into #temp
from
HF_Patient_Assesment A
join HF_Visit_mapping V on A.HT_PAT_ID = V.HT_PAT_ID and A.VISIT_ID = V.VISIT_ID
join HF_Patient_Profile P on A.HT_PAT_ID = P.HT_PAT_ID and A.VISIT_ID = P.VISIT_ID
join HF_Patient_Medical_History MH on A.HT_PAT_ID = MH.HT_PAT_ID and A.VISIT_ID = MH.VISIT_ID
left join HF_Patient_Pharma PH on A.HT_PAT_ID = PH.HT_PAT_ID and A.VISIT_ID = PH.VISIT_ID
left join HF_Patient_Hospitalisations H on A.HT_PAT_ID = H.HT_PAT_ID and A.VISIT_ID = H.VISIT_ID
left join HF_Patient_Summary PS on A.HT_PAT_ID = PS.HT_PAT_ID and A.VISIT_ID = PS.VISIT_ID
--left join HF_Patient_Drugs PD on A.HT_PAT_ID = PD.HT_PAT_ID and A.VISIT_ID = PD.VISIT_ID  and  PH.HT_PAT_ID = PD.HT_PAT_ID and PH.VISIT_ID = PD.VISIT_ID and PD.MGMT_PH_NAME = 'Digoxin' and PD.MGMT_PH_TYPE = 'hoc-other-hf-drugs-drugs'
left join HF_Patient_Management PM on A.HT_PAT_ID = PM.HT_PAT_ID and A.VISIT_ID = PM.VISIT_ID
left join [HFM_Feed].[dbo].[HFMAppDataHOC] tab on A.HT_PAT_ID = tab.patient_id and A.VISIT_ID = tab.uuid

--where
--(case when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF >= '50.0' then ASMNT_INV_ECHOCARDIOGRAPHY_LVEF
--	 when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF = '' then case when ASMNT_INV_LOWEST_LVEF >= '50.0' then ASMNT_INV_LOWEST_LVEF end
--end) >= '50.0'



drop table #temp
;


select * from #temp where recent = 1 and  
HT_PAT_ID = 141672 order by VISIT_SIGNOFF_DATE asc 


--Key Characteristics at National
select distinct t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,t1.BaselineAge,t1.Gender,t1.[Age-CCI],t1.[NYHA Class],t1.[6MWT],t1.[Distance In meters],
t1.[LowestLVEF<=35%],t1.[LowestLVEF35-40%],t1.[LowestLVEF40-49%],t1.[LowestLVEF>=50%],
t3.SUM_FAILURE_TYPE,t3.[Cause Type] from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
--where t1.HT_PAT_ID = 141672
;
--Key Characteristics at Clinic
select distinct t1.VISIT_CLINIC,t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,t1.BaselineAge,t1.Gender,t1.[Health Rating],t1.[EQ-5D Score],t1.[Age-CCI],t1.[NYHA Class],t1.[6MWT],t1.[Distance In meters],
t1.[LowestLVEF<=35%],t1.[LowestLVEF35-40%],t1.[LowestLVEF40-49%],t1.[LowestLVEF>=50%],
t3.SUM_FAILURE_TYPE,t3.[Cause Type] from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
--where t1.HT_PAT_ID = 141672
;
--Baseline Quality Of Care at National
select distinct t1.baseline,t1.recent,t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,t1.[Beta-blockers],t1.[ACE Inhibitors],t1.[ARNI],t1.ARB,t1.Diuretics,t1.DIURETICS_LOOP,t1.DIURETICS_OTHER,t1.MRA,
t1.[Maximal Tolerated BB],t1.[Maximal Tolerated ACEI/ARB/ARNI],t1.[CRT-P],t1.[CRT-D],t1.[ICD],t1.[Fluid Restriction],t1.[Daily Weights],t1.[Salt Restriction],
t1.[Obesity weight management],t1.[Exercise advice],t1.[Smoking cessation advice],t1.[Alcohol reduction advice],t1.[Cardiac rehabilitation],t1.[Anticoagulation therapy education],
t1.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
--join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
where t1.SUM_FAILURE_TYPE = 'Right HF'   and t1.baseline = 1  --and t1.HT_PAT_ID = 165628
;
--Recent Quality Of Care at National
select distinct t3.baseline,t3.recent,t3.HT_PAT_ID,t3.VISIT_SIGNOFF_DATE,t3.[Beta-blockers],t3.[ACE Inhibitors],t3.[ARNI],t3.ARB,t3.Diuretics,t3.DIURETICS_LOOP,t3.DIURETICS_OTHER,t3.MRA,
t3.[Maximal Tolerated BB],t3.[Maximal Tolerated ACEI/ARB/ARNI],t3.[CRT-P],t3.[CRT-D],t3.[ICD],t3.[Fluid Restriction],t3.[Daily Weights],t3.[Salt Restriction],
t3.[Obesity weight management],t3.[Exercise advice],t3.[Smoking cessation advice],t3.[Alcohol reduction advice],t3.[Cardiac rehabilitation],t3.[Anticoagulation therapy education],
t3.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
from #temp t1
--join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
where t1.SUM_FAILURE_TYPE = 'Right HF'   and t3.recent = 1 
;
select * from HF_Visit_Mapping where HT_PAT_ID = 141672 order by VISIT_SIGNOFF_DATE asc

;
--Baseline Quality Of Care at Clinic Level
select distinct t1.visit_clinic,t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,case when t1.[Beta-blockers] = 'Yes' then 1 else 0 end [Beta-blockers],case when t1.[ACE Inhibitors] = 'Yes' then 1 else 0 end [ACE Inhibitors],
case when t1.[ARNI] = 'Yes' then 1 else 0 end [ARNI],case when t1.ARB = 'Yes' then 1 else 0 end ARB,case when t1.Diuretics = 'Yes' then 1 else 0 end Diuretics,case when t1.DIURETICS_LOOP = 'Yes' then 1 else 0 end DIURETICS_LOOP,
case when t1.DIURETICS_OTHER = 'Yes' then 1 else 0 end DIURETICS_OTHER,case when t1.MRA = 'Yes' then 1 else 0 end MRA,case when t1.[Maximal Tolerated BB] = 'Yes' then 1 else 0 end [Maximal Tolerated BB],
case when t1.[Maximal Tolerated ACEI/ARB/ARNI] = 'Yes' then 1 else 0 end [Maximal Tolerated ACEI/ARB/ARNI],case when t1.[CRT-P] = 'Yes' then 1 else 0 end [CRT-P],case when t1.[CRT-D] = 'Yes' then 1 else 0 end [CRT-D],
case when t1.[ICD] = 'Yes' then 1 else 0 end [ICD],case when t1.[Fluid Restriction] = 'Yes' then 1 else 0 end [Fluid Restriction],case when t1.[Daily Weights] = 'Yes' then 1 else 0 end [Daily Weights],
case when t1.[Salt Restriction] = 'Yes' then 1 else 0 end [Salt Restriction],case when t1.[Obesity weight management] = 'Yes' then 1 else 0 end [Obesity weight management],case when t1.[Exercise advice] = 'Yes' then 1 else 0 end [Exercise advice],
case when t1.[Smoking cessation advice] = 'Yes' then 1 else 0 end [Smoking cessation advice],case when t1.[Alcohol reduction advice] = 'Yes' then 1 else 0 end [Alcohol reduction advice],
case when t1.[Cardiac rehabilitation] = 'Yes' then 1 else 0 end [Cardiac rehabilitation],case when t1.[Anticoagulation therapy education] = 'Yes' then 1 else 0 end [Anticoagulation therapy education]
,t1.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
into #HFREF@Clinic@B
from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
--join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
--where t1.SUM_FAILURE_TYPE = 'HFREF'   and t1.baseline = 1 
;
drop table #HFREF@B@Clinic
;
select visit_clinic, SUM(TRY_CONVERT(int,[Beta-blockers])) [Beta-blockers],SUM(TRY_CONVERT(int,[ACE Inhibitors])) [ACE Inhibitors], 
SUM(TRY_CONVERT(int,[ARNI])) [ARNI],SUM(TRY_CONVERT(int,ARB)) ARB,SUM(TRY_CONVERT(int,Diuretics)) Diuretics,SUM(TRY_CONVERT(int,DIURETICS_LOOP)) DIURETICS_LOOP,
SUM(TRY_CONVERT(int,DIURETICS_OTHER)) DIURETICS_OTHER,SUM(TRY_CONVERT(int,MRA)) MRA,SUM(TRY_CONVERT(int,[Maximal Tolerated BB])) [Maximal Tolerated BB],SUM(TRY_CONVERT(int,[Maximal Tolerated ACEI/ARB/ARNI])) [Maximal Tolerated ACEI/ARB/ARNI],
SUM(TRY_CONVERT(int,[CRT-P])) [CRT-P],SUM(TRY_CONVERT(int,[CRT-D])) [CRT-D],SUM(TRY_CONVERT(int,[ICD])) [ICD],SUM(TRY_CONVERT(int,[Fluid Restriction])) [Fluid Restriction],
SUM(TRY_CONVERT(int,[Daily Weights])) [Daily Weights],SUM(TRY_CONVERT(int,[Salt Restriction])) [Salt Restriction],SUM(TRY_CONVERT(int,[Obesity weight management])) [Obesity weight management],
SUM(TRY_CONVERT(int,[Exercise advice])) [Exercise advice],SUM(TRY_CONVERT(int,[Smoking cessation advice])) [Smoking cessation advice],SUM(TRY_CONVERT(int,[Alcohol reduction advice])) [Alcohol reduction advice],
SUM(TRY_CONVERT(int,[Cardiac rehabilitation])) [Cardiac rehabilitation],SUM(TRY_CONVERT(int,[Anticoagulation therapy education])) [Anticoagulation therapy education]

from  #HFREF@Clinic@B
where SUM_FAILURE_TYPE = 'Right HF '
group by visit_clinic

--Recent Quality Of Care at Clinic Level
select distinct t3.visit_clinic,t3.HT_PAT_ID,t3.VISIT_SIGNOFF_DATE,case when t3.[Beta-blockers] = 'Yes' then 1 else 0 end [Beta-blockers],case when t3.[ACE Inhibitors] = 'Yes' then 1 else 0 end [ACE Inhibitors],
case when t3.[ARNI] = 'Yes' then 1 else 0 end [ARNI],case when t3.ARB = 'Yes' then 1 else 0 end ARB,case when t3.Diuretics = 'Yes' then 1 else 0 end Diuretics,case when t3.DIURETICS_LOOP = 'Yes' then 1 else 0 end DIURETICS_LOOP,
case when t3.DIURETICS_OTHER = 'Yes' then 1 else 0 end DIURETICS_OTHER,case when t3.MRA = 'Yes' then 1 else 0 end MRA,case when t3.[Maximal Tolerated BB] = 'Yes' then 1 else 0 end [Maximal Tolerated BB],
case when t3.[Maximal Tolerated ACEI/ARB/ARNI] = 'Yes' then 1 else 0 end [Maximal Tolerated ACEI/ARB/ARNI],case when t3.[CRT-P] = 'Yes' then 1 else 0 end [CRT-P],case when t3.[CRT-D] = 'Yes' then 1 else 0 end [CRT-D],
case when t3.[ICD] = 'Yes' then 1 else 0 end [ICD],case when t3.[Fluid Restriction] = 'Yes' then 1 else 0 end [Fluid Restriction],case when t3.[Daily Weights] = 'Yes' then 1 else 0 end [Daily Weights],
case when t3.[Salt Restriction] = 'Yes' then 1 else 0 end [Salt Restriction],case when t3.[Obesity weight management] = 'Yes' then 1 else 0 end [Obesity weight management],case when t3.[Exercise advice] = 'Yes' then 1 else 0 end [Exercise advice],
case when t3.[Smoking cessation advice] = 'Yes' then 1 else 0 end [Smoking cessation advice],case when t3.[Alcohol reduction advice] = 'Yes' then 1 else 0 end [Alcohol reduction advice],
case when t3.[Cardiac rehabilitation] = 'Yes' then 1 else 0 end [Cardiac rehabilitation],case when t3.[Anticoagulation therapy education] = 'Yes' then 1 else 0 end [Anticoagulation therapy education]
,t3.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
into #HFREF@Clinic@R
from #temp t1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
;
select visit_clinic, SUM(TRY_CONVERT(int,[Beta-blockers])) [Beta-blockers],SUM(TRY_CONVERT(int,[ACE Inhibitors])) [ACE Inhibitors], 
SUM(TRY_CONVERT(int,[ARNI])) [ARNI],SUM(TRY_CONVERT(int,ARB)) ARB,SUM(TRY_CONVERT(int,Diuretics)) Diuretics,SUM(TRY_CONVERT(int,DIURETICS_LOOP)) DIURETICS_LOOP,
SUM(TRY_CONVERT(int,DIURETICS_OTHER)) DIURETICS_OTHER,SUM(TRY_CONVERT(int,MRA)) MRA,SUM(TRY_CONVERT(int,[Maximal Tolerated BB])) [Maximal Tolerated BB],SUM(TRY_CONVERT(int,[Maximal Tolerated ACEI/ARB/ARNI])) [Maximal Tolerated ACEI/ARB/ARNI],
SUM(TRY_CONVERT(int,[CRT-P])) [CRT-P],SUM(TRY_CONVERT(int,[CRT-D])) [CRT-D],SUM(TRY_CONVERT(int,[ICD])) [ICD],SUM(TRY_CONVERT(int,[Fluid Restriction])) [Fluid Restriction],
SUM(TRY_CONVERT(int,[Daily Weights])) [Daily Weights],SUM(TRY_CONVERT(int,[Salt Restriction])) [Salt Restriction],SUM(TRY_CONVERT(int,[Obesity weight management])) [Obesity weight management],
SUM(TRY_CONVERT(int,[Exercise advice])) [Exercise advice],SUM(TRY_CONVERT(int,[Smoking cessation advice])) [Smoking cessation advice],SUM(TRY_CONVERT(int,[Alcohol reduction advice])) [Alcohol reduction advice],
SUM(TRY_CONVERT(int,[Cardiac rehabilitation])) [Cardiac rehabilitation],SUM(TRY_CONVERT(int,[Anticoagulation therapy education])) [Anticoagulation therapy education]

from  #HFREF@Clinic@R
where SUM_FAILURE_TYPE = 'Right HF'
group by visit_clinic

--Clinical Outcomes 1.a
select c.visit_signoff_date,h.HP_DATE_OF_ADMISSION,try_convert(date,h.HP_DATE_OF_ADMISSION,103),
case when 
(try_convert(date,h.HP_DATE_OF_ADMISSION,103)) <= (dateadd(day,30,cast(c.visit_signoff_date as date)) )
then 'Yes' end [30 Days]
,case when 
( (try_convert(date,h.HP_DATE_OF_ADMISSION,103))) > (dateadd(day,30,cast(c.visit_signoff_date as date)) ) and ((try_convert(date,h.HP_DATE_OF_ADMISSION,103)) <= (dateadd(day,180,cast(c.visit_signoff_date as date)) ))
then 'Yes' end [6 months]
,case when 
((try_convert(date,h.HP_DATE_OF_ADMISSION,103)) > (dateadd(day,180,cast(c.visit_signoff_date as date)) ) and(try_convert(date,h.HP_DATE_OF_ADMISSION,103)) <= (dateadd(day,365,cast(c.visit_signoff_date as date)) ))
then 'Yes' end [1 Year]
,dateadd(day,365,cast(c.visit_signoff_date as date))
from 
HF_Patient_Hospitalisations h 
left join
#temp c on h.HT_PAT_ID = c.HT_PAT_ID --and h.VISIT_ID = c.visit_id
where c.baseline =1
and h.HT_PAT_ID = 135759
;
--Clinical Outcomes 1.b
select c.HT_PAT_ID,
count(try_convert(date,h.HP_DATE_OF_ADMISSION,103))
from 
HF_Patient_Hospitalisations h 
left join
#temp c on h.HT_PAT_ID = c.HT_PAT_ID --and h.VISIT_ID = c.visit_id
where c.baseline =1
--and h.HT_PAT_ID = 135759
and (try_convert(date,h.HP_DATE_OF_ADMISSION,103)) <= (dateadd(day,365,cast(c.visit_signoff_date as date)) )
group by c.HT_PAT_ID
;
--Clinical Outcomes - 1.c
select * from HF_Patient_Hospitalisations
;
-- 1.d - ((136/958)/3) * 100% = 4.73%
;
-- 2. All-cause mortality  -- No at baseline
select * from #temp 
where 
 [all cause mortality] = 'Yes'
 and baseline = 1
;
