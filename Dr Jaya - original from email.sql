
SELECT  
b.RegNo, ProcID,
 HlthTrckNo ,State
,DocCode, DoctorName
,DateOfProcedure
, AF
,DATEDIFF(YEAR,DateOfBirth,DateOfProcedure) AgeAtProcedure
, Sex
,Hypertension
,PrevMI
,Diabetes
,CABG
,PVD
,CerebrovascularDisease CD
,OD_Aspirin
,IIbIIaBlockadeNo
,OD_Clopidogrel
,OD_Brand
,OD_Prasugrel
,OD_Cangrelor,
OD_Ticagrelor,
OD_Warfarin,
OD_Statin,
OD_StatinTypeUnknown,
OD_StatinTypeAtorvastatin,
OD_StatinTypeSimvastatin,
OD_StatinTypePravastatin,
OD_StatinTypeFluvastatin,
OD_StatinTypeRosuvastatin,
OD_StatinDose,
OD_StatinDoseUnknown

FROM    vw_PCIRegistry_Baseline B
LEFT JOIN vw_PCIRegistry_PCIProcLesion p1 on b.regno=p1.regno and p1.LesionNum =1
LEFT JOIN vw_PCIRegistry_PCIProcLesion p2 on b.regno=p2.regno and p2.LesionNum =2
LEFT JOIN vw_PCIRegistry_PCIProcLesion p3 on b.regno=p3.regno and p3.LesionNum =3
LEFT JOIN vw_PCIRegistry_PCIProcLesion p4 on b.regno=p4.regno and p4.LesionNum =4
LEFT JOIN vw_PCIRegistry_PCIProcLesion p5 on b.regno=p5.regno and p5.LesionNum =5
LEFT JOIN vw_PCIRegistry_PCIProcLesion p6 on b.regno=p6.regno and p6.LesionNum =6

WHERE DateOfProcedure BETWEEN '20130101' AND '20171231'