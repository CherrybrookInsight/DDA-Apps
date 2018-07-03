select 
	A.HT_PAT_ID,
	case when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF >= '50.0' then ASMNT_INV_ECHOCARDIOGRAPHY_LVEF
		 when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF = '' then case when ASMNT_INV_LOWEST_LVEF >= '50.0' then ASMNT_INV_LOWEST_LVEF end
	end LVEF_LowestLVEF,
	ASMNT_INV_ECHOCARDIOGRAPHY_LVEF LVEF,
	ASMNT_INV_LOWEST_LVEF LowestLVEF, 
	ROW_NUMBER() OVER (PARTITION BY V.HT_PAT_ID ORDER BY V.VISIT_SIGNOFF_DATE asc) as [Baseline]
	,V.VISIT_SIGNOFF_DATE --as BaselineDate
	,P.PAT_DOB DOB
	,CASE WHEN TRY_PARSE(P.PAT_DOB AS datetime) IS NOT NULL THEN datediff(year, CAST(P.PAT_DOB AS DATE), getdate()) ELSE NULL END as Age
	,P.PAT_GENDER as Gender
	,MH.MH_CRF_SMOKING_STATUS as Smoking
	,case 
	when MH.MH_CRF_ALCOHOL_CONSUMPTION = '2 - 4' then 'Normal' 
	when MH.MH_CRF_ALCOHOL_CONSUMPTION = '> 4' then 'Current/previous problematic' 
	else MH_CRF_ALCOHOL_CONSUMPTION 
	end as Alcohol
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
	,case 
	when MH.MH_CV_ARRHYTMIA_TYPE_ATRIAL_FIBRILLATION_FLUTTER = 'True' then 'Yes' 
	else 'No' 
	end as [Atrial Fibrillation]
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
	,case 
	when PD.MGMT_PH_NAME = 'Digoxin' and PD.MGMT_PH_TYPE = 'hoc-other-hf-drugs-drugs' then 'Yes' 
	else 'No' 
	end Digoxin
	,PH.PHARMA_STATIN as Statins
	,PH.PHARMA_NITRATES as Nitrates
	,H.HP_DATE_OF_ADMISSION as DateOfAdmission
	,H.HP_HOSPITALISATION_NUMBER as HospitalisationNumber
	,H.HP_DATE_OF_DISCHARGE as DateOfDischarge
	,datediff(day, try_convert(date,HP_DATE_OF_ADMISSION) , getdate()) as Diff
	,CASE 
	WHEN
	(
		A.ASMNT_HST_LEG_OEDEMA = 'Yes' 
		or 
		A.ASMNT_EX_OEDEMA_NIL is null 
		or 
		A.ASMNT_EX_JVP = '> 3' 
		or 
		A.ASMNT_EX_CHEST != 'Clear' 
		or 
		PH.PHARMA_DIURETICS = 'Yes' 
		or 
		PH.PHARMA_DIURETICS_LOOP = 'Yes' 
		or 
		PS.SUM_VOLUME_STATUS = 'hypervolemic') THEN 'Yes' 
		else 'No' 
		END VolumeOverload
	--into #temp
from
	HF_Patient_Assesment A
	join HF_Visit_mapping V on A.HT_PAT_ID = V.HT_PAT_ID and A.VISIT_ID = V.VISIT_ID
	join HF_Patient_Profile P on A.HT_PAT_ID = P.HT_PAT_ID and A.VISIT_ID = P.VISIT_ID
	join HF_Patient_Medical_History MH on A.HT_PAT_ID = MH.HT_PAT_ID and A.VISIT_ID = MH.VISIT_ID
	left join HF_Patient_Pharma PH on A.HT_PAT_ID = PH.HT_PAT_ID and A.VISIT_ID = PH.VISIT_ID
	left join HF_Patient_Hospitalisations H on A.HT_PAT_ID = H.HT_PAT_ID and A.VISIT_ID = H.VISIT_ID
	left join HF_Patient_Summary PS on A.HT_PAT_ID = PS.HT_PAT_ID and A.VISIT_ID = PS.VISIT_ID
	left join HF_Patient_Drugs PD 
		on A.HT_PAT_ID = PD.HT_PAT_ID 
		and A.VISIT_ID = PD.VISIT_ID  
		and  PH.HT_PAT_ID = PD.HT_PAT_ID 
		and PH.VISIT_ID = PD.VISIT_ID 
		and PD.MGMT_PH_NAME = 'Digoxin' 
		and PD.MGMT_PH_TYPE = 'hoc-other-hf-drugs-drugs'
	where
		(
			case 
				when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF >= '50.0'	then ASMNT_INV_ECHOCARDIOGRAPHY_LVEF
				when ASMNT_INV_ECHOCARDIOGRAPHY_LVEF = ''		then 
					case when ASMNT_INV_LOWEST_LVEF >= '50.0' then ASMNT_INV_LOWEST_LVEF 
					end
			end
		) 
			>= '50.0'

select * from #temp