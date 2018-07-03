select 
distinct t1.HT_PAT_ID,
t1.VISIT_SIGNOFF_DATE,
t1.BaselineAge,
t1.Gender,
t1.[Age-CCI],
t1.[NYHA Class],
t1.[6MWT],
t1.[Distance In meters],
t1.[LowestLVEF<=35%],
t1.[LowestLVEF35-40%],
t1.[LowestLVEF40-49%],
t1.[LowestLVEF>=50%],
t3.SUM_FAILURE_TYPE,
t3.[Cause Type] 
from #temp t1
join #temp t2 on t1.ht_pat_id=t2.ht_pat_id and t1.baseline=1
join #temp t3 on t1.ht_pat_id = t3.ht_pat_id and t3.recent = 1
