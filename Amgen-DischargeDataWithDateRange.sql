SELECT 
[HT_PAT_ID]
,[VISIT_ID]
,[PD_DISCHARGE_DATE]
--,case when isnull([PD_DISCHARGE_DATE], '') = '' then [PD_DISCHARGE_DATE] else CONVERT(datetime, [PD_DISCHARGE_DATE], 104) end
,[PD_REASON_DEATH]
,[PD_REASON_ATTENDANCE]
,[PD_REASON_WISHES]
,[PD_REASON_LOST_FOLLOW_UP]
,[PD_REASON_DETAILS]
,[PAT_DEATH]
,[PAT_DODEATH]
,@@SERVERNAME [ServerName]
,DB_NAME() [CurrentDB]
,GETDATE() [AsAtDate]  
--into [AdHoc_Data].[dbo].[HFDataAmgenAnalysisDischarges]
FROM [HFM_Feed].[dbo].[HF_Patient_Discharges] d
where isnull(d.PD_DISCHARGE_DATE, '') <> ''
go

 --select d.PAT_DODEATH, d.PD_DISCHARGE_DATE, d.PD_DISCHARGE_DATE1,  * from #tempDischarge d where d.PAT_DODEATH is not null
 --go
 --select d.PAT_DODEATH, d.PD_DISCHARGE_DATE, d.PD_DISCHARGE_DATE1,  * from #tempDischarge d where d.PAT_DODEATH is not null
 --go
  
--  where
--   --[PAT_DODEATH] > '01/06/2016' 
--   ----85
--   --or   
--   --[PD_DISCHARGE_DATE] > '01/06/2016'--226
--   ----228
--   --   [PAT_DODEATH] > '01/06/2016' 
--   --85

----   SELECT   
----   GETDATE() AS UnconvertedDateTime,  
----   CAST(GETDATE() AS nvarchar(30)) AS UsingCast,  
----   CONVERT(nvarchar(30), GETDATE(), 126) AS UsingConvertTo_ISO8601  ;  
----GO 

--   convert(datetime, [PD_DISCHARGE_DATE], 104)  > '01/06/2016'  
   
----select CONVERT(datetime, '01/06/2016', 104)   

--   order by  [PD_DISCHARGE_DATE]
--   --and '01/06/2018'
--   --HT_PAT_ID	VISIT_ID	PD_DISCHARGE_DATE	PD_REASON_DEATH	PD_REASON_ATTENDANCE	PD_REASON_WISHES	PD_REASON_LOST_FOLLOW_UP	PD_REASON_DETAILS	PAT_DEATH	PAT_DODEATH
----301903	732eaf72-f6a6-45e4-88c2-499d05815f68	01/06/2017	NULL	NULL	NULL	NULL	Nil HF.	No	

--  --1june2016
--  --not deseased not discharge