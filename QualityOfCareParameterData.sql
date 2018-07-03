



/*
Key Characteristics	"select distinct t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,t1.BaselineAge,t1.Gender,t1.[Age-CCI],t1.[NYHA Class],t1.[6MWT],t1.[Distance In meters],
t1.[LowestLVEF<=35%],t1.[LowestLVEF35-40%],t1.[LowestLVEF40-49%],t1.[LowestLVEF>=50%],
t3.SUM_FAILURE_TYPE,t3.[Cause Type] from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1"			
	National		Clinic level	
Quality Of Care	"  --Baseline Quality Of Care
select distinct t1.baseline,t1.recent,t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,t1.[Beta-blockers],t1.[ACE Inhibitors],t1.[ARNI],t1.ARB,t1.Diuretics,t1.DIURETICS_LOOP,t1.DIURETICS_OTHER,t1.MRA,
t1.[Maximal Tolerated BB],t1.[Maximal Tolerated ACEI/ARB/ARNI],t1.[CRT-P],t1.[CRT-D],t1.[ICD],t1.[Fluid Restriction],t1.[Daily Weights],t1.[Salt Restriction],
t1.[Obesity weight management],t1.[Exercise advice],t1.[Smoking cessation advice],t1.[Alcohol reduction advice],t1.[Cardiac rehabilitation],t1.[Anticoagulation therapy education],
t1.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
--join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
where t1.SUM_FAILURE_TYPE = 'HFREF'   and t1.baseline = 1 "	" --Recent Quality Of Care
select distinct t3.baseline,t3.recent,t3.HT_PAT_ID,t3.VISIT_SIGNOFF_DATE,t3.[Beta-blockers],t3.[ACE Inhibitors],t3.[ARNI],t3.ARB,t3.Diuretics,t3.DIURETICS_LOOP,t3.DIURETICS_OTHER,t3.MRA,
t3.[Maximal Tolerated BB],t3.[Maximal Tolerated ACEI/ARB/ARNI],t3.[CRT-P],t3.[CRT-D],t3.[ICD],t3.[Fluid Restriction],t3.[Daily Weights],t3.[Salt Restriction],
t3.[Obesity weight management],t3.[Exercise advice],t3.[Smoking cessation advice],t3.[Alcohol reduction advice],t3.[Cardiac rehabilitation],t3.[Anticoagulation therapy education],
t3.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
from #temp t1
--join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
where t1.SUM_FAILURE_TYPE = 'HFREF'   and t3.recent = 1 "	" --Baseline Quality Of Care at Clinic Level
select distinct t1.visit_clinic,t1.HT_PAT_ID,t1.VISIT_SIGNOFF_DATE,t1.[Beta-blockers],t1.[ACE Inhibitors],t1.[ARNI],t1.ARB,t1.Diuretics,t1.DIURETICS_LOOP,t1.DIURETICS_OTHER,t1.MRA,
t1.[Maximal Tolerated BB],t1.[Maximal Tolerated ACEI/ARB/ARNI],t1.[CRT-P],t1.[CRT-D],t1.[ICD],t1.[Fluid Restriction],t1.[Daily Weights],t1.[Salt Restriction],
t1.[Obesity weight management],t1.[Exercise advice],t1.[Smoking cessation advice],t1.[Alcohol reduction advice],t1.[Cardiac rehabilitation],t1.[Anticoagulation therapy education],
t1.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
--join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
where t1.SUM_FAILURE_TYPE = 'HFREF'   and t1.baseline = 1 "	" --Recent Quality Of Care at Clinic Level
select distinct t3.visit_clinic as Clinic,t3.baseline,t3.recent,t3.HT_PAT_ID,t3.VISIT_SIGNOFF_DATE,t3.[Beta-blockers],t3.[ACE Inhibitors],t3.[ARNI],t3.ARB,t3.Diuretics,t3.DIURETICS_LOOP,t3.DIURETICS_OTHER,t3.MRA,
t3.[Maximal Tolerated BB],t3.[Maximal Tolerated ACEI/ARB/ARNI],t3.[CRT-P],t3.[CRT-D],t3.[ICD],t3.[Fluid Restriction],t3.[Daily Weights],t3.[Salt Restriction],
t3.[Obesity weight management],t3.[Exercise advice],t3.[Smoking cessation advice],t3.[Alcohol reduction advice],t3.[Cardiac rehabilitation],t3.[Anticoagulation therapy education],
t3.SUM_FAILURE_TYPE
--,t3.SUM_FAILURE_TYPE 
from #temp t1
--join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
where t1.SUM_FAILURE_TYPE = 'HFREF'   and t3.recent = 1 
and t1.HT_PAT_ID = 133071 "


*/