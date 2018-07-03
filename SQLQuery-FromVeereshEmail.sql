use HFM_Feed
go

select @@servername [serverName], DB_NAME() [Current DB], GETDATE() [AsAtDate]
go

/*
Scope of Work
Title: A comprehensive population-based characterization of heart failure with preserved ejection fraction 
Projected Start Date: TBD
Projected End Date: TBD
Background 
Chronic heart failure (HF) is a life-threatening and debilitating clinical syndrome that results from structural or functional impairment of ventricular filling or ejection of bloodHalf of patients with heart failure (HF) have a preserved left ventricular ejection fraction (HFpEF), yet no effective treatment has been identified. However, no single dataset has provided comprehensive population-based data on HFpEF, encompassing inpatients and outpatients and detailed clinical characteristics. The purpose of this present proposal is to describe the clinical characteristics of HFpEF patients  with particular focus on hospitalization history, NYHA class, comorbid conditions, medication use and biochemistry.
Project Overview

In the Genesis Care database, characteristics of HFpEF patients will be assessed and described.

Specific objectives include:

1.	Describe clinical characteristics of identified HFpEF patients, overall and stratified by
i.	Presence of volume overload (peripheral and/or pulmonary edema)
ii.	Hospitalization history

2.	Determine proportions of the following subsets of HFpEF patients
i.	Among those with NYHA class II-IV, proportions with evidence of fluid overload

ii.	Among those with NYHA class II-IV and evidence of volume overload, proportions hospitalized for heart failure within the past 12 months.
iii.	Among those with NYHA class III-IV with evidence of volume overload and not hospitalized for heart failure within the past 12 months, proportions with NT-proBNP threshold above 250 pg/mL
iv.	Among those with NYHA class III-IV with evidence of volume overload, not hospitalized for heart failure within the past 12 months, and with NT-proBNP threshold above 250 pg/mL, proportions with sleep apnea, orthopnea, diabetes, coronary artery disease or atrial fibrillation.

Table 1. Baseline clinical characteristics of HFpEF patients n=

Characteristics
	All HFpEF	Volume overload
(Peripheral and/or pulmonary or edema)	Hospitalized within the past 12 months

		Yes	No	Yes	No
Age, years, mean (±SD)					
Female n (%)					
Index year
	Unavailable				
2000-2006	Unavailable				
2007 – 2012	Unavailable				
Duration since HF diagnosis  
How long have they been with us?				
<= 6 months n (%)					
>6 months n (%)					
Smoking					
Current n (%)
Previous					
Previous n (%)
					
Alcohol	Have defined with Veeresh				
Never n (%)
					
Normal (2SD-4SD) n (%)					
Previous problematic (>2SD) n (%)
					
Type of care	All are patients are outpateints				
Inpatient					
Outpatient physician					
Outpatient HF nurse clinic					
Clinical characteristics	Have defined with Veeresh				
Body mass index , kg/m2 ;mean (±SD)					
Systolic blood pressure, mmHg; mean (±SD)					
Diastolic blood pressure , mmHg; mean (±SD)					
Pulse pressure , mmHg; mean (±SD)					
Mean arterial pressure , mmHg; mean (±SD)					
Heart rate, b.p.m. mean (±SD)					
NYHA class
	Have defined with Veeresh				
I ;n (%)					
II ;n (%)					
III;n (%)					
IV;n (%)					
   Chest Xray; n (%)
Chest X-ray	Have defined with Veeresh				
Cardiomegaly; n (%)	Might not have many but if we do n(%)				
Pulmonary congestion; n (%)					
Comorbidities					
Sleep apnea; n (%)					
Orthopnea; n (%)					
Hypertension; n (%)					
Diabetes; n (%)					
Atrial fibrillation; n (%)					
Lung disease/ Airways Disease; n (%)					
Valve disease/Moderate Valve Disease; n (%)					
Peripheral artery disease; n (%)					
Anaemia; n (%)					
Aortic stenosis; n (%)	Might not be available but emails from Leighton and Wendy would have clarified by now				
Biochemistry					
    Creatinine , mmol/L ; mean (±SD)					
    eGFR, mL/min/1.73 m2 ; mean (±SD)					
    Haemoglobin , g/dL ; mean (±SD)					
     Potassium , mEq/L ; mean (±SD)					
    NT-proBNP , pg/mL, median [IQR]					
    BNP , pg/mL, median [IQR]					
   Total cholesterol ; mean (±SD)					
   LDL cholesterol; mean (±SD)					
Medications					
    ACEI, ARBs or Renin inhibitors ;n (%)					
    Sacubitril/valsartan ;n (%)					
    Beta-blockers ;n (%)					
    Diuretics ;n (%)					
    Aldosterone antagonists ;n (%)					
    Digoxin/ Wendy knows  ;n (%)					
    Calcium channel blockers 	Refer to email				
     Statins ;n (%)					
     Nitrates;n (%)					
*/


select 
A.HT_PAT_ID,
case when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF >= '50.0' then ASMNT_INV_ECHOCARDIOGRAPHY_LVEF
	 when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF = '' then case when ASMNT_INV_LOWEST_LVEF >= '50.0' then ASMNT_INV_LOWEST_LVEF end
end LVEF_LowestLVEF,
ASMNT_INV_ECHOCARDIOGRAPHY_LVEF LVEF,ASMNT_INV_LOWEST_LVEF LowestLVEF, 
ROW_NUMBER() OVER (PARTITION BY V.HT_PAT_ID ORDER BY V.VISIT_SIGNOFF_DATE asc) as [Baseline]
,V.VISIT_SIGNOFF_DATE --as BaselineDate
,P.PAT_DOB DOB
,CASE WHEN TRY_PARSE(P.PAT_DOB AS datetime) IS NOT NULL THEN datediff(year, CAST(P.PAT_DOB AS DATE), getdate()) ELSE NULL END as Age
,P.PAT_GENDER as Gender
,MH.MH_CRF_SMOKING_STATUS as Smoking
,case when MH.MH_CRF_ALCOHOL_CONSUMPTION = '2 - 4' then 'Normal' when MH.MH_CRF_ALCOHOL_CONSUMPTION = '> 4' then 'Current/previous problematic' else MH_CRF_ALCOHOL_CONSUMPTION end as Alcohol
,A.ASMNT_EX_BMI as BMI
,A.ASMNT_EX_BP_LYING_SYSTOLIC as SystolicBP
,A.ASMNT_EX_BP_LYING_DIASTOLIC as DiastolicBP
,(CAST(A.ASMNT_EX_BP_LYING_SYSTOLIC as float) - CAST(A.ASMNT_EX_BP_LYING_DIASTOLIC as float)) as [Pulse Pressure]
,((CAST(A.ASMNT_EX_BP_LYING_SYSTOLIC as float) + CAST(A.ASMNT_EX_BP_LYING_DIASTOLIC as float)) / 2) as [Mean Arterial Pressure]
,A.ASMNT_EX_HEART_RATE as [Heart Rate]
,A.ASMNT_HST_DYSPNOEA as [NYHA Class]
,A.ASMNT_INV_CXR as [Chest X-Ray]
,MH.MH_NC_OBSTRUCTED_SLEEP_APNOEA as [Sleep Apnea]
,A.ASMNT_HST_ORTHOPNOEA as Orthopnea
,MH.MH_CRF_HYPERTENSION as Hypertension
,MH.MH_CRF_DIABETES as Diabetes
,case when MH.MH_CV_ARRHYTMIA_TYPE_ATRIAL_FIBRILLATION_FLUTTER = 'True' then 'Yes' else 'No' end as [Atrial Fibrillation]
,MH.MH_NC_AIRWAY_DISEASE as [Lung Disease]
,PS.SUM_APPLY_VALVE_DISEASE as [Valve Disease]
,MH.MH_CV_PVD as [Peripheral artery disease]
,MH.MH_NC_ANAEMIA as Anaemia

,A.ASMNT_INV_BLOODS_CREATININE as Creatinine
,A.ASMNT_INV_BLOODS_EGFR_CRCL as eGFR
,A.ASMNT_INV_BLOODS_HB_GL as Haemoglobin
,A.ASMNT_INV_BLOODS_POTASSIUM as Potassium
,A.ASMNT_INV_BLOODS_PROBNP as [NT-proBNP]
,A.ASMNT_INV_BLOODS_BNP as BNP
,A.ASMNT_INV_BLOODS_CHOLESTEROL as [Total cholesterol]
,A.ASMNT_INV_BLOODS_FASTING_LDL as [LDL cholesterol]
,PH.PHARMA_ACE_INHIBITORS as ACEI
,PH.PHARMA_ARBS as ARBs
,PH.PHARMA_ARNI as [Sacubitril/valsartan]
,PH.PHARMA_BETA_BLOCKERS as [Beta-blockers]
,PH.PHARMA_DIURETICS as Diuretics
,PH.PHARMA_MRA as [Aldosterone Antagonists]
,PH.PHARMA_OTHER_HF_DRUGS_DIGOXIN_IVABRADINE_HYDRALAZINE as OtherHFDrugs
,case when PD.MGMT_PH_NAME = 'Digoxin' and PD.MGMT_PH_TYPE = 'hoc-other-hf-drugs-drugs' then 'Yes' else 'No' end Digoxin
,PH.PHARMA_STATIN as Statins
,PH.PHARMA_NITRATES as Nitrates
,H.HP_DATE_OF_ADMISSION as DateOfAdmission
,H.HP_HOSPITALISATION_NUMBER as HospitalisationNumber
,H.HP_DATE_OF_DISCHARGE as DateOfDischarge
,datediff(day, try_convert(date,HP_DATE_OF_ADMISSION) , getdate()) as Diff
,CASE WHEN
(A.ASMNT_HST_LEG_OEDEMA = 'Yes' or A.ASMNT_EX_OEDEMA_NIL is null or A.ASMNT_EX_JVP = '> 3' or A.ASMNT_EX_CHEST != 'Clear' or PH.PHARMA_DIURETICS = 'Yes' or PH.PHARMA_DIURETICS_LOOP = 'Yes' or PS.SUM_VOLUME_STATUS = 'hypervolemic') THEN 'Yes' else 'No' END VolumeOverload

--into #temp
into [AdHoc_Data].[dbo].[HFDataAmgenAnalysis21062018]

from  HF_Patient_Assesment A
join HF_Visit_mapping V on A.HT_PAT_ID = V.HT_PAT_ID and A.VISIT_ID = V.VISIT_ID
join HF_Patient_Profile P on A.HT_PAT_ID = P.HT_PAT_ID and A.VISIT_ID = P.VISIT_ID
join HF_Patient_Medical_History MH on A.HT_PAT_ID = MH.HT_PAT_ID and A.VISIT_ID = MH.VISIT_ID
left join HF_Patient_Pharma PH on A.HT_PAT_ID = PH.HT_PAT_ID and A.VISIT_ID = PH.VISIT_ID
left join HF_Patient_Hospitalisations H on A.HT_PAT_ID = H.HT_PAT_ID and A.VISIT_ID = H.VISIT_ID
left join HF_Patient_Summary PS on A.HT_PAT_ID = PS.HT_PAT_ID and A.VISIT_ID = PS.VISIT_ID
left join HF_Patient_Drugs PD on A.HT_PAT_ID = PD.HT_PAT_ID and A.VISIT_ID = PD.VISIT_ID  and  PH.HT_PAT_ID = PD.HT_PAT_ID and PH.VISIT_ID = PD.VISIT_ID and PD.MGMT_PH_NAME = 'Digoxin' and PD.MGMT_PH_TYPE = 'hoc-other-hf-drugs-drugs'
where
(case when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF >= '50.0' then ASMNT_INV_ECHOCARDIOGRAPHY_LVEF
	 when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF = '' then case when ASMNT_INV_LOWEST_LVEF >= '50.0' then ASMNT_INV_LOWEST_LVEF end
end) >= '50.0'
go

select *, GETDATE() [As At Date], @@SERVERNAME [Source Server], DB_NAME() [Source DB] 
into [AdHoc_Data].[dbo].[HFDataAmgenAnalysis210620182]
from [AdHoc_Data].[dbo].[HFDataAmgenAnalysis21062018]
go
