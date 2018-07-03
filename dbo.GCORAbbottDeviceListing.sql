CREATE PROCEDURE [dbo].[GCORAbbottDeviceListing]
	@StartDate Datetime  = '20150115',
	@EndDate DateTime = '20180122'
AS
DECLARE @Device VARCHAR(20)='St.Jude'
--From: Sonya McColl 
--Sent: Monday, 25 June 2018 11:36 AM
--To: Daniel Zhou <Daniel.Zhou@genesiscare.com>
--Cc: Phil Stevens (Jira) <jira@genesiscare.atlassian.net>; Hussain Mohammed <Hussain.Mohammed@genesiscare.com>; Stuart Behncken <Stuart.Behncken@genesiscare.com>
--Subject: RE: [JIRA] (HCAP-125) GCOR - Abbott Device Retro data

--Hi Daniel,

--I don’t have a link for the Abbott Device retro (flat file) data.  Hussain, can you please work with Daniel to produce this report?  We need it asap and has been on the drawing board for quite a few weeks now. 

--Dates – 1st October 15 to 22nd Jan 18.  Same data fields as the quarterly Biotronik and Abbott reports.

--Thanks!

--Cheers,
--Sonya

--History:
--1. Wrapped query in stored procedure

;WITH vFollowUp AS 
(
	SELECT 
		fu.Regno,
		futype.description FUType,
		fu.lostfu LostFU,	
		--fu.Comment,
		fu.dof DateOfFollowUp,
		folvitstat.vitstat VitalStatus,
		caudealkp.description DeathCause,
		fu.DeathCauseOther,
		dcc.YesNo DeathCauseComplicationOfDevice,
		dealoclkp.DeathLoc,
		fu.fusepdea DateofSeparation,
		com.yesno Complications,
		fu.ODate,
		fu.opneumothorax Pneumothorax,
		pneumolkp.description Pneumothoraxs,
		fu.ovasculartrauma VascularTrauma,
		ocardiacperforation CardiacPerforation,
		cardperlkp.description Perforation,
		COALESCE (odce, odct) Perforations,
		ocardiacvalveinjury CardiacValveInjury,
		osubclavianveinthrombosis SubclavianVeinThrombosis,
		oleaddislodgement LeadDislodgement,
		leaddislolkp.description LeadDislodgementReOp,
		fu.ohaematoma Haematoma,
		fu.omajorbleeding MajorBleeding,
		bleedsitelkp.description BleedingSite,
		fu.transfusion Transfusion,
		fu.oinfection InfectionYesNo,
		inflkp.description Infection,
		fu.oerosion Erosion,
		fu.ophrenicnervestimulation PhrenicNerveStimulation,
		pnslkp.description PhrenicNerveStimulations,
		fu.oarrhythmiarequiringintervention ArrhythmiaRequiringIntervention,
		fu.oairembolism AirEmbolism,
		fu.operipheralnerveinjury PeripheralNerveInjury,
		fu.olymphostatictrauma LymphostaticTrauma,
		fu.ostroke Stroke,
		strklkp.Description,
		fu.OOther Other,
		fu.odo OtherOutcomes,
		fu.od DateOfOccurence,
		fu.Readmitted  Readmitted1,
		readm1lkp.readmcd ReadamissionCause1,
		fu.dor1 DateOfReadmission1,
		fu.caurea2  Readmitted2,
		readm2lkp.readmcd ReadamissionCause2,
		fu.dor2 DateOfReadmission2,
		mri.YesNo MRIscan, MRIscanDt, hms.Description HomeMonStatus,
		apdrugs.YesNo APDrugs,
		antpltlkp.description AntiplateletDrugs,
		acoag.YesNo AcoagDrugs,
		antcoaglkp.description Anticoagulants,
		arrh.YesNo ArrhDrugs,
		arrdrugs.Description Antiarrhthmics
	FROM heartcare_pci.dbo.tblregistration Reg --Follow Up and Lookup tables
	LEFT JOIN HeartCare_PCI.dbo.tblFollowup_Device fu ON Reg.RegNo = fu.RegNo
	LEFT JOIN HeartCare_PCI.dbo.tlkpFuTypeOf_Device futype ON fu.FUType = futype.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpFuVitalStatus FolVitStat ON fu.VitalStatus = FolVitStat.VitStatId
	LEFT JOIN HeartCare_PCI.dbo.tlkpLocationDeath DeaLocLkp ON fu.FULocDea = DeaLocLkp.DeathLocId
	LEFT JOIN HeartCare_PCI.dbo.tlkpFuPrimaryCauseDeath_Device CauDeaLkp ON fu.DeathCause = CauDeaLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpObservation2_Device PneumoLkp ON fu.odp = PneumoLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpCardiacPerforation_Device CardPerLkp ON fu.ODC = CardPerLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpLeadDislodgement_Device LeadDisloLkp ON fu.ODL = LeadDisloLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpBleedingSite_Device BleedSiteLkp ON fu.BleedingSite = BleedSiteLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpInfection_Device InfLkp ON fu.ODI = InfLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpObservation2_Device PNSLkp ON fu.ODPNS = PNSLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpStroke_Device StrkLkp ON fu.ODS = StrkLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpFuReadmissionReason_Device Readm1Lkp ON fu.CauRea = Readm1Lkp.ReAdmCdId
	LEFT JOIN HeartCare_PCI.dbo.tlkpFuReadmissionReason_Device Readm2Lkp ON fu.CauRea2Yes = Readm2Lkp.ReAdmCdId
	LEFT JOIN HeartCare_PCI.dbo.tlkpYesNo com ON com.YesNoID=fu.Outcome
	LEFT JOIN HeartCare_PCI.dbo.tlkpYesNo apdrugs ON apdrugs.YesNoID=fu.antiplateletdrugs
	LEFT JOIN HeartCare_PCI.dbo.tlkpAntiplateletDrugs_Device AntPltLkp ON fu.AntiplateletDrugsYes = AntPltLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpYesNo acoag ON acoag.YesNoID=fu.anticoagulants
	LEFT JOIN HeartCare_PCI.dbo.tlkpAnticoagulants_Device AntCoagLkp ON fu.AnticoagulantsYes = AntCoagLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpYesNo arrh ON arrh.YesNoID=fu.AntiArrhythmics
	LEFT JOIN HeartCare_PCI.dbo.tlkpAntiArrhythmicsYes arrdrugs ON fu.AntiArrhythmicsYes = arrdrugs.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpYesNo dcc ON dcc.YesNoID=fu.DeathCauseComplicationOfDevice
	LEFT JOIN HeartCare_PCI.[dbo].[tlkpYesNo] mri ON fu.MRIscan=mri.YesNoID
	LEFT JOIN HeartCare_PCI.[dbo].[tlkpHomeMonitoringStatus] hms ON hms.Id=fu.HomeMonStatus
	WHERE Reg.Device = 1 
)
----------------------------------------------------------------------
,BaseLine AS
(
	SELECT 
		Reg.RegNo,
		Reg.ProcID,
		HlthtrckNo PatID,
		doccode,
		StL.State,
		DATEDIFF(YEAR,DOB,PDD.ProcDat) AgeAtProcedure,
		SexL.Sex Sex, --1.4 and 1.5
		PrevPCI.YesNo PrevPCI,
		PrevCABG.YesNo PrevCABG,
		PrevVal.YesNo PrevVal,
		PrevMI.YesNo PrevMI,
		AF.YesNo AF,
		HeartFailure.YesNo HeartFailure,
		hft.Description HeartFailureType, --3.1 - 3.6a
		TyPL.Description TypeOfProcedure,
		IndL.Description IntendedDevice,
		DevImplantL.Description DeviceImplanted, --4.1 - 4.3
		CAST(PDD.ProcDat AS SmallDateTime) ProcedureDate,
		CASE WHEN ProcTime=-1 THEN 'Unknown' ELSE CONVERT(VARCHAR,ProcTime) END  ProcTime,
		CASE WHEN FluoTime=-1 THEN 'Unknown' ELSE CONVERT(VARCHAR,FluoTime) END FluoTime,
		AtrLead.Description AtrialLead,
		RVLookUp.Description RightVentricular,
		LV1Lookup.Description LeftVentricular1,
		LV2Lookup.Description LeftVentricular2,
		GenSite.Description GeneratorSite,
		GenLoc.Description GeneratorLocation, -- 5.1 - 5.3 and 5.8 - 5.10
		Device.Description Device,
		deviceman.Description Manufacturer,
		CASE WHEN model IN (-2, -1) THEN ModelDev.PRODUCTNAME
		ELSE ModelDev.PRODUCTNAME+' ('+ ModelDev.ASSESSMENTBODY+')'
		END Model,
		DEV.SerNoICD SerialNo ,
		ALMan.Description AtrialLeadMan,
		CASE WHEN ALManu IN (0, -1, -2) THEN ''
		WHEN ALMOD IN (-2, -1) THEN almod.PRODUCTNAME
		ELSE almod.PRODUCTNAME+' ('+ almod.ASSESSMENTBODY+')' END alModel,
		ALSer,
		alloc.Description AlLoc,
		RVLMan.Description RVLeadMan,
		RVLType.Description RVLType,
		CASE WHEN RVLMan IN (0, -1, -2) THEN ''
		WHEN RVLMod IN (-2,-1) THEN RVLMod.PRODUCTNAME
		ELSE rvlmod.PRODUCTNAME+' ('+ rvlmod.ASSESSMENTBODY+')' END rvlModel,
		RVLSn,
		rvlloc.Description RVLLoc,
		LVLMan.Description LVLeadMan,
		CASE WHEN LVLMan IN (0, -1, -2) THEN ''
		WHEN LVLMod IN (-2, -1) THEN LVLMod.PRODUCTNAME
		ELSE LVLMod.PRODUCTNAME+' ('+ LVLMod.ASSESSMENTBODY+')' END lvlModel,
		LVLSer,
		lvllocap.Description lvllocap,
		lao.Description LVLLocLAO,
		LVL2Man LVL2Man,
		LVL2Mod,
		LVL2Ser,
		LVL2LocAP,
		LVL2LocLAO,
		Outcome.YesNo Complications,
		dod.ODate,
		dod.opneumothorax Pneumothorax,
		pneumolkp.description Pneumothoraxs,
		dod.ovasculartrauma VascularTrauma,
		vtl.Description VascularTraumas,
		dod.ocardiacperforation CardiacPerforation,
		cardperlkp.description Perforation,
		COALESCE (dod.odce,dod.odct) Perforations,
		dod.ocardiacvalveinjury CardiacValveInjury,
		dod.osubclavianveinthrombosis SubclavianVeinThrombosis,
		dod.oleaddislodgement LeadDislodgement,
		leaddislolkp.description LeadDislodgementReOp,
		dod.ohaematoma Haematoma,
		dod.omajorbleeding MajorBleeding,
		bleedsitelkp.description BleedingSite,
		dod.transfusion  Transfusion,
		dod.oinfection InfectionYesNo,
		inflkp.description Infection,
		dod.oerosion Erosion,
		dod.ophrenicnervestimulation PhrenicNerveStimulation,
		pnslkp.description PhrenicNerveStimulations,
		dod.oarrhythmiarequiringintervention ArrhythmiaRequiringIntervention,
		dod.oairembolism AirEmbolism,
		dod.operipheralnerveinjury PeripheralNerveInjury,
		dod.olymphostatictrauma LymphostaticTrauma,
		dod.ostroke Stroke,
		strklkp.Description,
		dod.ODeath ODeath,
		ODisDatDea,
		CauDeaLkp.Description OPrimCauDea,
		OPrimCauDeaOth,
		DeaLocLkp.DeathLoc OLocDea,
		dod.OOther Other,
		dod.odo OtherOutcomes,
		OD OccurenceDate,
		dod DateofDischarge,
		AntiplateletDrugs.YesNo AntiplateletDrugs,
		apdrugs.Description APDrugs,
		Anticoagulants.YesNo Anticoagulants,
		acoa.Description ACDrugs,
		DisStatus.DisStat DischargeStatus,
		DisDat -- 7.1 – 7.20 and 7.22 – 7.23
FROM 
	HeartCare_PCI.[dbo].[tblRegistration] Reg
	LEFT JOIN HeartCare_PCI.[dbo].[tlkpState] StL ON Reg.State = StL.StateId
	LEFT JOIN HeartCare_PCI.[dbo].[tblDemographics] Dem ON Reg.RegNo = Dem.RegNo
	LEFT JOIN [dbo].[tlkpSex] SexL ON Dem.Sex = SexL.SexId
	LEFT JOIN [dbo].[tblAdmission_Device] Adm ON Reg.RegNo = Adm.RegNo
	LEFT JOIN [dbo].[tblProcedureType_Device] PTD ON Reg.RegNo = PTD.RegNo
	LEFT JOIN [dbo].[tlkpHeartFailureType] hft ON ptd.HeartFailureType=hft.Id
	LEFT JOIN [dbo].[tblIndicationForDevice_Device] Ind ON Reg.RegNo = Ind.RegNo
	LEFT JOIN [dbo].[tlkpTypeOfProcedure] TyPL ON Ind.ToProc = TyPL.Id
	LEFT JOIN [dbo].[tlkpIntendedDevice_Device] IndL ON Ind.IntDev = IndL.Id
	LEFT JOIN [dbo].[tlkpIntendedDevice_Device] DevImplantL ON Ind.dev = DevImplantL.Id -- Changed from IntDev to Dev for Device Implanted
	LEFT JOIN [dbo].[tblProceduralData_Device] PDD ON Reg.RegNo = PDD.RegNo
	LEFT JOIN [dbo].[tlkpAtrialLead] AtrLead ON PDD.AL = AtrLead.Id
	LEFT JOIN [dbo].[tlkpAtrialLead] RVLookUp ON PDD.rv = RVLookUp.Id
	LEFT JOIN [dbo].[tlkpAtrialLead] LV1Lookup ON PDD.LV1 = LV1Lookup.Id
	LEFT JOIN [dbo].[tlkpAtrialLead] LV2Lookup ON PDD.LV2 = LV2Lookup.Id
	LEFT JOIN [dbo].[tlkpGeneratorSite] GenSite ON PDD.GenSit = GenSite.Id
	LEFT JOIN [dbo].[tlkpGeneratorLocation] GenLoc ON PDD.GenLoc = GenLoc.Id
	LEFT JOIN (SELECT COALESCE ([dbo].[tblDevice_Device].[ManILR], [dbo].[tblDevice_Device].[MANPM], [dbo].[tblDevice_Device].[MANICD]) DeviceMan, * FROM [dbo].[tblDevice_Device]) Dev ON Reg.RegNo = Dev.RegNo
	LEFT JOIN [dbo].[tlkpManufacturer_Device] deviceman ON dev.DeviceMan=deviceman.Id
	LEFT JOIN [dbo].[tlkpDevice_Device] Device ON Dev.Gen = Device.Id
	LEFT JOIN [dbo].[tlkpLeadModel_Device] ModelDev ON Dev.Model = ModelDev.Id
	LEFT JOIN [dbo].[tlkpLeadModel_Device] almod ON Dev.ALMod= almod.Id
	LEFT JOIN [dbo].[tlkpManufacturer_No_Device] ALMan ON Dev.ALManu = ALMan.Id
	LEFT JOIN [dbo].[tlkpLeadModel_Device] rvlmod ON Dev.RVLMod= RVLMod.Id
	LEFT JOIN [dbo].[tlkpManufacturer_No_Device] RVLMan ON Dev.RVLMan = RVLMan.Id
	LEFT JOIN [dbo].[tlkpDevice_Device] RVLType ON dev.RVLType=RVLType.Id
	LEFT JOIN [dbo].[tlkpLeadModel_Device] Lvlmod ON Dev.Lvlmod= Lvlmod.Id
	LEFT JOIN [dbo].[tlkpManufacturer_No_Device] LVLMan ON Dev.LVLMan = LVLMan.Id
	LEFT JOIN [dbo].[tlkpLeftVentricularLeadLocationLAO_Device] lao ON dev.LVLLocLAO=lao.Id
	LEFT JOIN [dbo].[tblDischargeOutcome_Device] DOD ON Reg.RegNo = DOD.RegNo
	LEFT JOIN [dbo].[tlkpDischargeStatus] DisStatus ON DOD.DisStat = DisStatus.DisStatId
	LEFT JOIN [dbo].[tlkpYesNo] prevpci ON PTD.PrevPCI=prevpci.YesNoID
	LEFT JOIN [dbo].[tlkpYesNo] prevCABG ON PTD.prevCABG=prevCABG.YesNoID
	LEFT JOIN [dbo].[tlkpYesNo] prevVAL ON PTD.prevVAL=prevVAL.YesNoID
	LEFT JOIN [dbo].[tlkpYesNo] PrevMI ON PTD.PrevMI=PrevMI.YesNoID
	LEFT JOIN [dbo].[tlkpYesNo] AF ON PTD.AF=AF.YesNoID
	LEFT JOIN [dbo].[tlkpYesNo] HeartFailure ON PTD.HeartFailure=HeartFailure.YesNoID
	LEFT JOIN [dbo].[tlkpYesNo] Outcome ON DOD.Outcome=Outcome.YesNoID
	LEFT JOIN [dbo].[tlkpAtrialLeadLocation_Device] ALLoc ON dev.alloc=alloc.id
	LEFT JOIN [dbo].[tlkpRightVentricularLeadLocation_Device] rvlloc ON dev.RVLLoc=rvlloc.Id
	LEFT JOIN [dbo].[tlkpLeftVentricularLeadLocationAP_Device] lvllocap ON dev.LVLLocAP=lvllocap.Id
	LEFT JOIN [dbo].[tlkpYesNo] AntiplateletDrugs ON DOD.AntiplateletDrugs=AntiplateletDrugs.YesNoID
	LEFT JOIN [dbo].[tlkpYesNo] Anticoagulants ON DOD.Anticoagulants=Anticoagulants.YesNoID
	LEFT JOIN [dbo].[tlkpAntiplateletDrugs_Device] apdrugs ON dod.AntiplateletDrugsYes=apdrugs.Id
	LEFT JOIN [dbo].[tlkpAnticoagulants_Device] acoa ON dod.AnticoagulantsYes=acoa.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpObservation2_Device PneumoLkp ON dod.odp = PneumoLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpCardiacPerforation_Device CardPerLkp ON dod.ODC = CardPerLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpLeadDislodgement_Device LeadDisloLkp ON dod.ODL = LeadDisloLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpBleedingSite_Device BleedSiteLkp ON dod.BleedingSite = BleedSiteLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpInfection_Device InfLkp ON dod.ODI = InfLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpObservation2_Device PNSLkp ON dod.ODPNS = PNSLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpStroke_Device StrkLkp ON dod.ODS = StrkLkp.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpObservation2_Device vtl ON dod.odv = vtl.Id
	LEFT JOIN HeartCare_PCI.dbo.tlkpLocationDeath DeaLocLkp ON dod.oLocDea = DeaLocLkp.DeathLocId
	LEFT JOIN HeartCare_PCI.dbo.tlkpFuPrimaryCauseDeath_Device CauDeaLkp ON dod.OPrimCauDea = CauDeaLkp.Id
	WHERE Reg.Device = 1 
)


SELECT 
DISTINCT 
	bl.[RegNo],
	bl.[ProcID],
	PatID,
	--doc.Description Doctor,
	bl.[State],
	[AgeAtProcedure],
	[Sex],
	[PrevPCI],
	[PrevCABG],
	[PrevVal],
	[PrevMI],
	[AF],
	[HeartFailure],
	[HeartFailureType],
	[TypeOfProcedure],
	[IntendedDevice],
	[DeviceImplanted],
	[ProcedureDate],
	[ProcTime],
	[FluoTime],
	[AtrialLead],
	[RightVentricular],
	[LeftVentricular1],
	[LeftVentricular2],
	[GeneratorSite],
	[GeneratorLocation],
	[Device],

	[Manufacturer],
	[Model],
	[SerialNo],
	[AtrialLeadMan],
	[alModel],
	[ALSer],
	[AlLoc],
	[RVLeadMan],
	[RVLType],
	[rvlModel],
	[RVLSn],
	[RVLLoc],
	[LVLeadMan],
	[lvlModel],
	[LVLSer],
	[lvllocap],
	[LVLLocLAO],

	bl.[Complications],
	bl.[ODate],
	bl.Pneumothorax,
	bl.Pneumothoraxs,
	bl.VascularTrauma,
	bl.VascularTraumas,
	bl.CardiacPerforation,
	bl.Perforation,
	bl.Perforations,
	bl.CardiacValveInjury,
	bl.SubclavianVeinThrombosis,
	bl.LeadDislodgement,
	bl.LeadDislodgementReOp,
	bl.Haematoma,
	bl.MajorBleeding,
	bl.BleedingSite,
	bl.Transfusion,
	bl.InfectionYesNo,
	bl.Infection,
	bl.Erosion,
	bl.PhrenicNerveStimulation,
	bl.PhrenicNerveStimulations,
	bl.ArrhythmiaRequiringIntervention,
	bl.AirEmbolism,
	bl.PeripheralNerveInjury,
	bl.LymphostaticTrauma,
	bl.Stroke,
	bl.Description,
	bl.ODeath,
	bl.ODisDatDea,
	bl.OPrimCauDea,
	bl.OPrimCauDeaOth,
	bl.OLocDea,
	bl.Other,
	bl.OtherOutcomes,
	bl.OccurenceDate,
	bl.DateofDischarge,
	bl.AntiplateletDrugs,
	bl.APDrugs,
	bl.Anticoagulants,
	bl.ACDrugs,
	bl.DischargeStatus,
	bl.DisDat,
	FU1.*,
	FU2.*

FROM 
	BaseLine bl
	LEFT JOIN vFollowUP fu1 ON bl.Regno=fu1.Regno AND fu1.FUType='30 Day'
	LEFT JOIN vFollowUP fu2 ON bl.Regno=fu2.Regno AND fu2.FUType='1-Year'
	LEFT JOIN [dbo].[tlkpDoctorCode_Device] doc ON doc.Id=bl.DocCode
WHERE 
	ProcedureDate BETWEEN @StartDate AND @EndDate
	AND 
	(Manufacturer=@Device)

UNION ALL  ------------------------------------

SELECT 
	DISTINCT 
	bl.[RegNo],
	bl.[ProcID],
	PatID,
	--doc.Description Doctor,
	bl.[State],
	[AgeAtProcedure],
	[Sex],
	[PrevPCI],
	[PrevCABG],
	[PrevVal],
	[PrevMI],
	[AF],
	[HeartFailure],
	[HeartFailureType],
	[TypeOfProcedure],
	[IntendedDevice],
	[DeviceImplanted],
	[ProcedureDate],
	[ProcTime],
	[FluoTime],
	[AtrialLead],
	[RightVentricular],
	[LeftVentricular1],
	[LeftVentricular2],
	[GeneratorSite],
	[GeneratorLocation],
	[Device],
	
	'comp' [Manufacturer],
	'' [Model],
	'' [SerialNo],
	'comp' [AtrialLeadMan],
	'' [alModel],
	'' [ALSer],
	[AlLoc],
	'comp' [RVLeadMan],
	[RVLType],
	'' [rvlModel],
	'' [RVLSn],
	[RVLLoc],
	'comp' [LVLeadMan],
	'' [lvlModel],
	'' [LVLSer],
	[lvllocap],
	[LVLLocLAO],

	bl.[Complications],
	bl.[ODate],
	bl.Pneumothorax,
	bl.Pneumothoraxs,
	bl.VascularTrauma,
	bl.VascularTraumas,
	bl.CardiacPerforation,
	bl.Perforation,
	bl.Perforations,
	bl.CardiacValveInjury,
	bl.SubclavianVeinThrombosis,
	bl.LeadDislodgement,
	bl.LeadDislodgementReOp,
	bl.Haematoma,
	bl.MajorBleeding,
	bl.BleedingSite,
	bl.Transfusion,
	bl.InfectionYesNo,
	bl.Infection,
	bl.Erosion,
	bl.PhrenicNerveStimulation,
	bl.PhrenicNerveStimulations,
	bl.ArrhythmiaRequiringIntervention,
	bl.AirEmbolism,
	bl.PeripheralNerveInjury,
	bl.LymphostaticTrauma,
	bl.Stroke,
	bl.Description,
	bl.ODeath,
	bl.ODisDatDea,
	bl.OPrimCauDea,
	bl.OPrimCauDeaOth,
	bl.OLocDea,
	bl.Other,
	bl.OtherOutcomes,
	bl.OccurenceDate,
	bl.DateofDischarge,
	bl.AntiplateletDrugs,
	bl.APDrugs,
	bl.Anticoagulants,
	bl.ACDrugs,
	bl.DischargeStatus,
	bl.DisDat,
	FU1.*,
	FU2.*
FROM 
	baseline bl
	LEFT JOIN vFollowUP fu1 
		ON bl.Regno=fu1.Regno AND fu1.FUType='30 Day'
	LEFT JOIN vFollowUP fu2 
		ON bl.Regno=fu2.Regno AND fu2.FUType='1-Year'
	LEFT JOIN [dbo].[tlkpDoctorCode_Device] doc 
		ON doc.Id=bl.DocCode

	WHERE ProcedureDate BETWEEN @StartDate AND @EndDate
	AND (Manufacturer<>@Device)
	--ORDER BY bl.state, proceduredate

RETURN 0
