/*
(No column name)	(No column name)	(No column name)
GCPRBI02	2018-05-30 15:23:08.657	HFM_Feed

VISIT_CLINIC	REFERRAL_SOURCE_TYPE	(No column name)
Adelaide Cardiology		2
Bundoora		1
NULL	Ambulatory	1393
	Ambulatory	3
Adelaide Cardiology	Ambulatory	340
Bundoora	Ambulatory	2276
Langwarrin	Ambulatory	318
Mount	Ambulatory	4
Optiheart	Ambulatory	22
Optiheart Ringwood	Ambulatory	213
The Valley	Ambulatory	326
NULL	Hospital	328
	Hospital	2
Adelaide Cardiology	Hospital	18
Bundoora	Hospital	838
Langwarrin	Hospital	16
Optiheart Ringwood	Hospital	36
The Valley	Hospital	43
*/

select @@SERVERNAME, GETDATE(), DB_NAME()
go

use HFM_Feed
go

select  
distinct 
VISIT_CLINIC,
REFERRAL_SOURCE_TYPE,
count(R.HT_PAT_ID) 
from
	HF_Patient_Referral_Sources R
	join 
	HF_Visit_Mapping V 
	on 
		R.HT_PAT_ID = V.HT_PAT_ID 
		and 
		R.VISIT_ID = V.VISIT_ID
--where 
--REFERRAL_SOURCE_TYPE = 'Ambulatory' -- 4895
--REFERRAL_SOURCE_TYPE = 'Hospital'     -- 1281
--REFERRAL_SOURCE_TYPE = ''
group by VISIT_CLINIC,REFERRAL_SOURCE_TYPE
go
