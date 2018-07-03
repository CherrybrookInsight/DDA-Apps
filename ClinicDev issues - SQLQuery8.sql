select @@SERVERNAME, GETDATE() [AsAtDate]
go

--1.b. Referral Source

--Total Patients(National)
select 
REFERRAL_SOURCE_TYPE,
count(*) 
from 
HF_Patient_Referral_Sources
--where 
--REFERRAL_SOURCE_TYPE = 'Ambulatory' -- 4895
--REFERRAL_SOURCE_TYPE = 'Hospital'     -- 1281
group by REFERRAL_SOURCE_TYPE
go

--Distinct Patients(National)
select  
distinct 
HT_PAT_ID,
REFERRAL_SOURCE_TYPE,
count(*) 
from HF_Patient_Referral_Sources
where 
--REFERRAL_SOURCE_TYPE = 'Ambulatory' -- 4895
REFERRAL_SOURCE_TYPE = 'Hospital'     -- 1281
--REFERRAL_SOURCE_TYPE = ''
group by 
HT_PAT_ID,
REFERRAL_SOURCE_TYPE
go

--Clinci Level
select  
distinct 
VISIT_CLINIC,
REFERRAL_SOURCE_TYPE,
count(R.HT_PAT_ID) 
from 
HF_Patient_Referral_Sources R 
join 
HF_Visit_Mapping V 
on R.HT_PAT_ID = V.HT_PAT_ID and R.VISIT_ID = V.VISIT_ID

--where 
--REFERRAL_SOURCE_TYPE = 'Ambulatory' -- 4895
--REFERRAL_SOURCE_TYPE = 'Hospital'     -- 1281
--REFERRAL_SOURCE_TYPE = ''
group by 
VISIT_CLINIC,
REFERRAL_SOURCE_TYPE
go


--Distinct Patients(National)
--1.c.Referral Type

select  distinct HT_PAT_ID,REFERRAL_SOURCE_SUB_TYPE,count(*) from
HF_Patient_Referral_Sources
where 
--REFERRAL_SOURCE_SUB_TYPE = 'Chronic' -- 3075
--REFERRAL_SOURCE_SUB_TYPE = 'De Novo'   -- 1263
REFERRAL_SOURCE_SUB_TYPE is null
--and HT_PAT_ID = 288499
group by HT_PAT_ID,REFERRAL_SOURCE_SUB_TYPE
