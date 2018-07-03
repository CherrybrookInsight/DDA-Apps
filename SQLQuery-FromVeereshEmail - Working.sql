DROP TABLE #temp

SELECT    
		  a.ht_pat_id,
          CASE
                    WHEN asmnt_inv_echocardiography_lvef >= '50.0' THEN asmnt_inv_echocardiography_lvef
                    WHEN asmnt_inv_echocardiography_lvef = '' THEN
                              CASE
                                        WHEN asmnt_inv_lowest_lvef >= '50.0' THEN asmnt_inv_lowest_lvef
                              END
          END                                                                            lvef_lowestlvef,
          asmnt_inv_echocardiography_lvef                                                lvef,
          asmnt_inv_lowest_lvef                                                          lowestlvef,
          Row_number() OVER (partition BY v.ht_pat_id ORDER BY v.visit_signoff_date ASC) AS [Baseline] ,
          v.visit_signoff_date --as BaselineDate
          ,
          p.pat_dob dob ,
          CASE
                    WHEN try_parse(p.pat_dob as datetime) IS NOT NULL THEN datediff(year, cast(p.pat_dob AS date), getdate())
                    ELSE NULL
          END                      AS age ,
          p.pat_gender             AS gender ,
          mh.mh_crf_smoking_status AS smoking ,
          CASE
                    WHEN mh.mh_crf_alcohol_consumption = '2 - 4' THEN 'Normal'
                    WHEN mh.mh_crf_alcohol_consumption = '> 4' THEN 'Current/previous problematic'
                    ELSE mh_crf_alcohol_consumption
          END                                                                                                AS alcohol ,
          a.asmnt_ex_bmi                                                                                     AS bmi ,
          a.asmnt_ex_bp_lying_systolic                                                                       AS systolicbp ,
          a.asmnt_ex_bp_lying_diastolic                                                                      AS diastolicbp ,
          (cast(a.asmnt_ex_bp_lying_systolic AS float) - cast(a.asmnt_ex_bp_lying_diastolic AS float))       AS [Pulse Pressure] ,
          ((cast(a.asmnt_ex_bp_lying_systolic AS float) + cast(a.asmnt_ex_bp_lying_diastolic AS float)) / 2) AS [Mean Arterial Pressure] ,
          a.asmnt_ex_heart_rate                                                                              AS [Heart Rate] ,
          a.asmnt_hst_dyspnoea                                                                               AS [NYHA Class] ,
          a.asmnt_inv_cxr                                                                                    AS [Chest X-Ray] ,
          mh.mh_nc_obstructed_sleep_apnoea                                                                   AS [Sleep Apnea] ,
          a.asmnt_hst_orthopnoea                                                                             AS orthopnea ,
          mh.mh_crf_hypertension                                                                             AS hypertension ,
          mh.mh_crf_diabetes                                                                                 AS diabetes ,
          CASE
                    WHEN mh.mh_cv_arrhytmia_type_atrial_fibrillation_flutter = 'True' THEN 'Yes'
                    ELSE 'No'
          END                                                     AS [Atrial Fibrillation] ,
          mh.mh_nc_airway_disease                                 AS [Lung Disease] ,
          ps.sum_apply_valve_disease                              AS [Valve Disease] ,
          mh.mh_cv_pvd                                            AS [Peripheral artery disease] ,
          mh.mh_nc_anaemia                                        AS anaemia ,
          a.asmnt_inv_bloods_creatinine                           AS creatinine ,
          a.asmnt_inv_bloods_egfr_crcl                            AS egfr ,
          a.asmnt_inv_bloods_hb_gl                                AS haemoglobin ,
          a.asmnt_inv_bloods_potassium                            AS potassium ,
          a.asmnt_inv_bloods_probnp                               AS [NT-proBNP] ,
          a.asmnt_inv_bloods_bnp                                  AS bnp ,
          a.asmnt_inv_bloods_cholesterol                          AS [Total cholesterol] ,
          a.asmnt_inv_bloods_fasting_ldl                          AS [LDL cholesterol] ,
          ph.pharma_ace_inhibitors                                AS acei ,
          ph.pharma_arbs                                          AS arbs ,
          ph.pharma_arni                                          AS [Sacubitril/valsartan] ,
          ph.pharma_beta_blockers                                 AS [Beta-blockers] ,
          ph.pharma_diuretics                                     AS diuretics ,
          ph.pharma_mra                                           AS [Aldosterone Antagonists] ,
          ph.pharma_other_hf_drugs_digoxin_ivabradine_hydralazine AS otherhfdrugs ,
          CASE
                    WHEN pd.mgmt_ph_name = 'Digoxin'
                    AND       pd.mgmt_ph_type = 'hoc-other-hf-drugs-drugs' THEN 'Yes'
                    ELSE 'No'
          END                                                               digoxin ,
          ph.pharma_statin                                                  AS statins ,
          ph.pharma_nitrates                                                AS nitrates ,
          h.hp_date_of_admission                                            AS dateofadmission ,
          h.hp_hospitalisation_number                                       AS hospitalisationnumber ,
          h.hp_date_of_discharge                                            AS dateofdischarge ,
		  --Begin added columns 25/06/2018
		  d.PAT_DEATH
		  ,d.PAT_DODEATH
		  ,d.PD_DISCHARGE_DATE
		  ,
		  --End added columns 25/06/2018
          datediff(day, try_convert(date,hp_date_of_admission) , getdate()) AS diff ,
          CASE
                    WHEN (
                                        a.asmnt_hst_leg_oedema = 'Yes'
                              OR        a.asmnt_ex_oedema_nil IS NULL
                              OR        a.asmnt_ex_jvp = '> 3'
                              OR        a.asmnt_ex_chest != 'Clear'
                              OR        ph.pharma_diuretics = 'Yes'
                              OR        ph.pharma_diuretics_loop = 'Yes'
                              OR        ps.sum_volume_status = 'hypervolemic'
                              OR        rs.referral_source_chronic_stable = 'ACute Pulmonary Oedema') THEN 'Yes'
                    ELSE 'No'
          END volumeoverload
INTO      #temp
FROM      hf_patient_assesment a
JOIN      hf_visit_mapping v
ON        a.ht_pat_id = v.ht_pat_id
AND       a.visit_id = v.visit_id
JOIN      hf_patient_profile p
ON        a.ht_pat_id = p.ht_pat_id
AND       a.visit_id = p.visit_id
JOIN      hf_patient_medical_history mh
ON        a.ht_pat_id = mh.ht_pat_id
AND       a.visit_id = mh.visit_id
left join [dbo].[HF_Patient_Discharges] d on a.HT_PAT_ID = d.HT_PAT_ID and a.VISIT_ID = d.VISIT_ID
LEFT JOIN hf_patient_pharma ph
ON        a.ht_pat_id = ph.ht_pat_id
AND       a.visit_id = ph.visit_id
LEFT JOIN hf_patient_hospitalisations h
ON        a.ht_pat_id = h.ht_pat_id
AND       a.visit_id = h.visit_id
LEFT JOIN hf_patient_summary ps
ON        a.ht_pat_id = ps.ht_pat_id
AND       a.visit_id = ps.visit_id
LEFT JOIN hf_patient_drugs pd
ON        a.ht_pat_id = pd.ht_pat_id
AND       a.visit_id = pd.visit_id
AND       ph.ht_pat_id = pd.ht_pat_id
AND       ph.visit_id = pd.visit_id
AND       pd.mgmt_ph_name = 'Digoxin'
AND       pd.mgmt_ph_type = 'hoc-other-hf-drugs-drugs'
LEFT JOIN hf_patient_referral_sources rs
ON        a.ht_pat_id = rs.ht_pat_id
AND       a.visit_id = rs.visit_id
WHERE     (
             CASE
				 WHEN asmnt_inv_echocardiography_lvef >= '50.0' THEN asmnt_inv_echocardiography_lvef
				 WHEN asmnt_inv_echocardiography_lvef = '' THEN CASE WHEN asmnt_inv_lowest_lvef >= '50.0' THEN asmnt_inv_lowest_lvef END
             END
			) >= '50.0'
--and datediff(day, try_convert(date,HP_DATE_OF_ADMISSION) , getdate()) <= 365
--and  A.HT_PAT_ID = 142561
--drop table #temp

SELECT *
FROM   #temp
WHERE  (
              diff <= 365
       OR     diff IS NULL)
AND    baseline = 1

SELECT *
into [AdHoc_Data].[dbo].[HFCLinicData_Baseline507Aanalysis26062018]
FROM   #temp
WHERE  (
              diff <= 365
       OR     diff IS NULL)
AND    baseline = 1