--select * from  dbo.tblDischargeOutcome_Device
--select * from  dbo.tblIndicationForDevice_Device
--select * from  dbo.tblProceduralData_Device
select * from  dbo.tlkpAnticoagulants_Device
select * from  dbo.tlkpAntiplateletDrugs_Device
select * from  dbo.tlkpAtrialLead
select * from  dbo.tlkpObservation2_Device
select * from  dbo.tlkpBleedingSite_Device
select * from  dbo.tlkpCardiacPerforation_Device
select * from  dbo.tlkpFuPrimaryCauseDeath_Device 
select * from  dbo.tlkpInfection_Device
select * from  dbo.tlkpLeadDislodgement_Device
select * from  dbo.tlkpLocationDeath
select * from  dbo.tlkpObservation2_Device
select * from  dbo.tlkpStroke_Device


Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x0000000000009C18
-1          Not available                                      0x0000000000009C19
1           Warfarin                                           0x0000000000009C1A
2           Dabigatran                                         0x0000000000009C1B
3           Rivaroxaban                                        0x0000000000009C1C
4           Apixaban                                           0x0000000000009C1D

(6 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x0000000000009BAC
-1          Not available                                      0x0000000000009BAD
1           Aspirin                                            0x0000000000009BAE
2           Clopidogrel                                        0x0000000000009BAF
3           Ticagrelor                                         0x0000000000009BB0
4           Prasugrel                                          0x0000000000009BB1
5           Aspirin + Clopidogrel                              0x0000000000009BB2
6           Aspirin + Ticagrelor                               0x0000000000009BB3
7           Aspirin + Prasugrel                                0x0000000000009BB4

(9 rows affected)

Id          Description                                        rank        AuditTimestamp
----------- -------------------------------------------------- ----------- ------------------
-2          Pending                                            8           0x0000000000009243
-1          Unknown                                            9           0x0000000000009244
0           Nil                                                1           0x0000000000009245
1           Cephalic                                           2           0x0000000000009246
2           Subclavian                                         3           0x0000000000009247
3           Axillary                                           4           0x0000000000009248
4           Femoral/Iiiac                                      5           0x0000000000009249
5           Other                                              7           0x000000000000924A
6           Subcutaneous                                       6           0x000000000000924B

(9 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x00000000000091F1
-1          Unknown                                            0x00000000000091F2
1           Observation                                        0x00000000000091F3
2           Intervention                                       0x00000000000091F4

(4 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x000000000000F019
-1          Unknown                                            0x000000000000F01A
1           Retroperitoneal                                    0x000000000000F01B
2           Percutaneous entry site                            0x000000000000F01C
3           Other                                              0x000000000000F01D

(5 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x000000000006812A
-1          Unknown                                            0x000000000006812B
1           Effusion                                           0x000000000006812C
2           Tamponade                                          0x000000000006812D

(4 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x00000000000764B4
-1          Unknown                                            0x00000000000764B5
1           Cardiac                                            0x00000000000764B6
2           Renal                                              0x00000000000764B7
3           Infection                                          0x00000000000764B8
4           Neurological                                       0x00000000000764B9
5           Vascular                                           0x00000000000764BA
6           Pulmonary                                          0x00000000000764BB
7           Other                                              0x00000000000764BC

(9 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x0000000000006365
-1          Unknown                                            0x0000000000006366
1           Antibiotics only                                   0x0000000000006367
2           Reoperation                                        0x0000000000006368
3           Removal of Device                                  0x0000000000006369

(5 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x00000000000091C5
-1          Unknown                                            0x00000000000091C6
1           Atrial Lead                                        0x00000000000091C7
2           Right Ventricular                                  0x00000000000091C8
3           Left Ventricular 1                                 0x00000000000091C9
4           Left Ventricular 2                                 0x00000000000091CA

(6 rows affected)

DeathLocId  DeathLoc        AuditTimestamp
----------- --------------- ------------------
-2          Pending         0x0000000000009B46
-1          Unknown         0x0000000000009B47
1           In Lab          0x0000000000009B48
2           Out of Lab      0x0000000000009B49

(4 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x00000000000091F1
-1          Unknown                                            0x00000000000091F2
1           Observation                                        0x00000000000091F3
2           Intervention                                       0x00000000000091F4

(4 rows affected)

Id          Description                                        AuditTimestamp
----------- -------------------------------------------------- ------------------
-2          Pending                                            0x0000000000009B85
-1          Unknown                                            0x0000000000009B86
1           Haemorrhagic                                       0x0000000000009B87
2           Ischaemic                                          0x0000000000009B88

(4 rows affected)

