USE [HFM_Feed] 
GO /****** Object:  View [dbo].[HF_Patient_Medical_History]    Script Date: 5/06/2018 10:43:51 AM ******/
SET
   ANSI_NULLS 
   ON 
   GO 
   SET
      QUOTED_IDENTIFIER 
      ON 
      GO CREATE VIEW [dbo].[HF_Patient_Medical_History] AS 
      SELECT
         patient_id as HT_PAT_ID,
         uuid as VISIT_ID,
         _stop_bang_date_completed as MH_SB_COMPLETED_DATE,
         _hoc_neck_circumference as MH_SB_NECK_CIRCUMFERENCE,
         _hoc_snoring as MH_SB_SNORING,
         _hoc_tired as MH_SB_TIRED,
         _hoc_observed_apnoea as MH_SB_OBSERVED_APNOEA,
         _hoc_high_blood_pressure as MH_SB_HIGH_BLOOD_PRESSURE,
         _hoc_risk_of_osa as MH_SB_OSA_RISK,
         _hoc_morisky_scale_date_completed as MH_MK_COMPLETED_DATE,
         _hoc_do_you_ever_forget_to_take_your_medication as MH_MK_FORGET_MEDICATION,
         _hoc_are_you_careless_at_times_about_taking_your_medication as MH_MK_CARELESS_MEDICATION,
         _hoc_when_you_feel_better_do_you_sometimes_stop_taking_your_medicine as MH_MK_STOP_MEDICINE_BETTER,
         _hoc_sometimes_if_you_feel_worse_when_you_take_the_medicine_do_you_stop_taking_it as MH_MK_STOP_MEDICINE_WORSE,
         _morisky_adherence as MH_MK_SCORE,
         _eq_5d_s_date_collected as MH_EQ5D_DATE_COLLECTED,
         _eq_5d_s_mobility as MH_EQ5D_MOBILITY,
         _eq_5d_s_self_care as MH_EQ5D_SELFCARE,
         _eq_5d_s_usual_activities as MH_EQ5D_USUAL_ACTIVITIES,
         _eq_5d_s_pain_discomfort as MH_EQ5D_PAIN_DISCOMFORT,
         _eq_5d_s_anxiety_depression as MH_EQ5D_ANXIETY_DEPRESSION,
         _eq_5d_scale_1_100 as MH_EQ5D_HEALTH_STATE_TODAY,
         _eq_5d_score as MH_EQ5D_SCORE,
         _hoc_social_history_date as MH_SOCIAL_DATE,
         _hoc_lives_alone as MH_SOCIAL_LIVES_ALONE,
         _hoc_lives_alone_s1 as MH_SOCIAL_LIVES_ALONE_SPECIFY,
         _hoc_services_in_place as MH_SOCIAL_SERVICES_IN_PLACE,
         _hoc_services_in_place_s1 as MH_SOCIAL_SERVICES_IN_PLACE_SPECIFY,
         _hoc_family_support as MH_SOCIAL_FAMILY_SUPPORT,
         _hoc_family_support_s1 as MH_SOCIAL_FAMILY_SUPPORT_SPECIFY,
         _hoc_independent_adls as MH_SOCIAL_INDEPENDENT_ADLS,
         _hoc_independent_adls_s1 as MH_SOCIAL_INDEPENDENT_ADLS_SPECIFY,
         _hoc_hypertension as MH_CRF_HYPERTENSION,
         _hoc_dyslipidemia as MH_CRF_DYSLIPIDEMIA,
         _hoc_smoking_status as MH_CRF_SMOKING_STATUS,
         _hoc_alcohol_consumption as MH_CRF_ALCOHOL_CONSUMPTION,
         _hoc_chemotherapy as MH_CRF_CHEMOTHERAPY,
         _hoc_diabetes as MH_CRF_DIABETES,
         _diabetes_s1 as MH_CRF_DIABETES_ORGAN_DAMAGE,
         _hoc_diabetes_type as MH_CRF_DIABETES_TYPE,
         _diabetes_type_management_diet as MH_CRF_DIABETES_DIET,
         _diabetes_type_management_oral as MH_CRF_DIABETES_ORAL,
         _diabetes_type_management_insulin as MH_CRF_DIABETES_INSULIN,
         _hoc_family_history_ihd as MH_CRF_FAMILY_HISTORY_IHD,
         _hoc_family_history_cardiomyopathy as MH_CRF_FAMILY_HISTORY_CARDIOMYOPATHY,
         _MH_CV_CAD as MH_CV_CAD,
         _hoc_ami as MH_CV_MYOCARDIAL_INFARCTION,
         _congestive_heart_failure as MH_CV_CONGESTIVE_HEART_FAILURE,
         _hoc_cva as MH_CV_CEREBROVASCULAR_DISEASE,
         _hemiplegia as MH_CV_HEMIPLEGIA,
         _hoc_pvd as MH_CV_PVD,
         _hoc_arrhythmia as MH_CV_ARRHYTMIA,
         _hoc_arrhythmia_type_atrial_fibrillationflutter as MH_CV_ARRHYTMIA_TYPE_ATRIAL_FIBRILLATION_FLUTTER,
         _hoc_arrhythmia_type_ventricular_tachycardia as MH_CV_ARRHYTMIA_TYPE_VENT_TACHYCARDIA,
         _hoc_arrhythmia_type_ventricular_fibrillation as MH_CV_ARRHYTMIA_TYPE_VENT_FIBRILLATION,
         _hoc_revascularisation as MH_CV_REVASCULARISATION,
         _hoc_revascularisation_type_cabg as MH_CV_REVASCULARISATION_CABG,
         _hoc_revascularisation_type_pci as MH_CV_REVASCULARISATION_PCI,
         _hoc_other_cardiac_surgery as MH_CV_OTHER_SURGERY,
         _cardiac_surgery_type_congenital as MH_CV_OTHER_SURGERY_CONGENITAL,
         _cardiac_surgery_type_valve as MH_CV_OTHER_SURGERY_VALVE,
         _cardiac_surgery_type_aortic as MH_CV_OTHER_SURGERY_AORTIC,
         _hoc_chronic_renal_failure as MH_NC_CHRONIC_RENAL_FAILURE,
         _hoc_chronic_renal_failure_s1 as MH_NC_DIALYSIS,
         _hoc_airway_disease as MH_NC_AIRWAY_DISEASE,
         _hoc_airway_disease_type as MH_NC_AIRWAY_DISEASE_TYPE,
         _hoc_obstructive_sleep_apnoea as MH_NC_OBSTRUCTED_SLEEP_APNOEA,
         _chronic_liver_disease as MH_NC_CHRONIC_LIVER_DISEASE,
         _gastro_intestinal_liver_s2 as MH_NC_CHRONIC_LIVER_DISEASE_INTENSITY,
         _peptic_ulcer_disease as MH_NC_PEPTIC_ULCER,
         _hoc_anaemia as MH_NC_ANAEMIA,
         _connective_tissue_disease as MH_NC_CONNECTIVE_TISSUE_DISEASE,
         _non_metastatic_solid_tumour as MH_NC_NON_METASTATIC_SOLID_TUMOUR,
         _metastatic_solid_tumour as MH_NC_METASTATIC_SOLID_TUMOUR,
         _lymphoma as MH_NC_LYMPHOMA,
         _leukemia as MH_NC_LEUKEMIA,
         _aids as MH_NC_AIDS,
         _hoc_dementia as MH_NC_DEMENTIA,
         _non_cardiac_depression as MH_NC_DEPRESSION,
         _past_medical_history_add as MH_NC_PAST_MEDICAL_HISTORY 
      FROM
         HFMAppDataHOC 
      WHERE
         (
            _stop_bang_date_completed IS NOT NULL 
            AND _stop_bang_date_completed <> '' 
            AND _stop_bang_date_completed <> 'No' 
            AND _stop_bang_date_completed <> '0'
         )
         OR 
         (
            _hoc_neck_circumference IS NOT NULL 
            AND _hoc_neck_circumference <> '' 
            AND _hoc_neck_circumference <> 'No' 
            AND _hoc_neck_circumference <> '0'
         )
         OR 
         (
            _hoc_snoring IS NOT NULL 
            AND _hoc_snoring <> '' 
            AND _hoc_snoring <> 'No' 
            AND _hoc_snoring <> '0'
         )
         OR 
         (
            _hoc_tired IS NOT NULL 
            AND _hoc_tired <> '' 
            AND _hoc_tired <> 'No' 
            AND _hoc_tired <> '0'
         )
         OR 
         (
            _hoc_observed_apnoea IS NOT NULL 
            AND _hoc_observed_apnoea <> '' 
            AND _hoc_observed_apnoea <> 'No' 
            AND _hoc_observed_apnoea <> '0'
         )
         OR 
         (
            _hoc_high_blood_pressure IS NOT NULL 
            AND _hoc_high_blood_pressure <> '' 
            AND _hoc_high_blood_pressure <> 'No' 
            AND _hoc_high_blood_pressure <> '0'
         )
         OR 
         (
            _hoc_risk_of_osa IS NOT NULL 
            AND _hoc_risk_of_osa <> '' 
            AND _hoc_risk_of_osa <> 'No' 
            AND _hoc_risk_of_osa <> '0'
         )
         OR 
         (
            _hoc_morisky_scale_date_completed IS NOT NULL 
            AND _hoc_morisky_scale_date_completed <> '' 
            AND _hoc_morisky_scale_date_completed <> 'No' 
            AND _hoc_morisky_scale_date_completed <> '0'
         )
         OR 
         (
            _hoc_do_you_ever_forget_to_take_your_medication IS NOT NULL 
            AND _hoc_do_you_ever_forget_to_take_your_medication <> '' 
            AND _hoc_do_you_ever_forget_to_take_your_medication <> 'No' 
            AND _hoc_do_you_ever_forget_to_take_your_medication <> '0'
         )
         OR 
         (
            _hoc_are_you_careless_at_times_about_taking_your_medication IS NOT NULL 
            AND _hoc_are_you_careless_at_times_about_taking_your_medication <> '' 
            AND _hoc_are_you_careless_at_times_about_taking_your_medication <> 'No' 
            AND _hoc_are_you_careless_at_times_about_taking_your_medication <> '0'
         )
         OR 
         (
            _hoc_when_you_feel_better_do_you_sometimes_stop_taking_your_medicine IS NOT NULL 
            AND _hoc_when_you_feel_better_do_you_sometimes_stop_taking_your_medicine <> '' 
            AND _hoc_when_you_feel_better_do_you_sometimes_stop_taking_your_medicine <> 'No' 
            AND _hoc_when_you_feel_better_do_you_sometimes_stop_taking_your_medicine <> '0'
         )
         OR 
         (
            _hoc_sometimes_if_you_feel_worse_when_you_take_the_medicine_do_you_stop_taking_it IS NOT NULL 
            AND _hoc_sometimes_if_you_feel_worse_when_you_take_the_medicine_do_you_stop_taking_it <> '' 
            AND _hoc_sometimes_if_you_feel_worse_when_you_take_the_medicine_do_you_stop_taking_it <> 'No' 
            AND _hoc_sometimes_if_you_feel_worse_when_you_take_the_medicine_do_you_stop_taking_it <> '0'
         )
         OR 
         (
            _morisky_adherence IS NOT NULL 
            AND _morisky_adherence <> '' 
            AND _morisky_adherence <> 'No' 
            AND _morisky_adherence <> '0'
         )
         OR 
         (
            _eq_5d_s_date_collected IS NOT NULL 
            AND _eq_5d_s_date_collected <> '' 
            AND _eq_5d_s_date_collected <> 'No' 
            AND _eq_5d_s_date_collected <> '0'
         )
         OR 
         (
            _eq_5d_s_mobility IS NOT NULL 
            AND _eq_5d_s_mobility <> '' 
            AND _eq_5d_s_mobility <> 'No' 
            AND _eq_5d_s_mobility <> '0'
         )
         OR 
         (
            _eq_5d_s_self_care IS NOT NULL 
            AND _eq_5d_s_self_care <> '' 
            AND _eq_5d_s_self_care <> 'No' 
            AND _eq_5d_s_self_care <> '0'
         )
         OR 
         (
            _eq_5d_s_usual_activities IS NOT NULL 
            AND _eq_5d_s_usual_activities <> '' 
            AND _eq_5d_s_usual_activities <> 'No' 
            AND _eq_5d_s_usual_activities <> '0'
         )
         OR 
         (
            _eq_5d_s_pain_discomfort IS NOT NULL 
            AND _eq_5d_s_pain_discomfort <> '' 
            AND _eq_5d_s_pain_discomfort <> 'No' 
            AND _eq_5d_s_pain_discomfort <> '0'
         )
         OR 
         (
            _eq_5d_s_anxiety_depression IS NOT NULL 
            AND _eq_5d_s_anxiety_depression <> '' 
            AND _eq_5d_s_anxiety_depression <> 'No' 
            AND _eq_5d_s_anxiety_depression <> '0'
         )
         OR 
         (
            _eq_5d_scale_1_100 IS NOT NULL 
            AND _eq_5d_scale_1_100 <> '' 
            AND _eq_5d_scale_1_100 <> 'No' 
            AND _eq_5d_scale_1_100 <> '0'
         )
         OR 
         (
            _eq_5d_score IS NOT NULL 
            AND _eq_5d_score <> '' 
            AND _eq_5d_score <> 'No' 
            AND _eq_5d_score <> '0'
         )
         OR 
         (
            _hoc_social_history_date IS NOT NULL 
            AND _hoc_social_history_date <> '' 
            AND _hoc_social_history_date <> 'No' 
            AND _hoc_social_history_date <> '0'
         )
         OR 
         (
            _hoc_lives_alone IS NOT NULL 
            AND _hoc_lives_alone <> '' 
            AND _hoc_lives_alone <> 'No' 
            AND _hoc_lives_alone <> '0'
         )
         OR 
         (
            _hoc_lives_alone_s1 IS NOT NULL 
            AND _hoc_lives_alone_s1 <> '' 
            AND _hoc_lives_alone_s1 <> 'No' 
            AND _hoc_lives_alone_s1 <> '0'
         )
         OR 
         (
            _hoc_services_in_place IS NOT NULL 
            AND _hoc_services_in_place <> '' 
            AND _hoc_services_in_place <> 'No' 
            AND _hoc_services_in_place <> '0'
         )
         OR 
         (
            _hoc_services_in_place_s1 IS NOT NULL 
            AND _hoc_services_in_place_s1 <> '' 
            AND _hoc_services_in_place_s1 <> 'No' 
            AND _hoc_services_in_place_s1 <> '0'
         )
         OR 
         (
            _hoc_family_support IS NOT NULL 
            AND _hoc_family_support <> '' 
            AND _hoc_family_support <> 'No' 
            AND _hoc_family_support <> '0'
         )
         OR 
         (
            _hoc_family_support_s1 IS NOT NULL 
            AND _hoc_family_support_s1 <> '' 
            AND _hoc_family_support_s1 <> 'No' 
            AND _hoc_family_support_s1 <> '0'
         )
         OR 
         (
            _hoc_independent_adls IS NOT NULL 
            AND _hoc_independent_adls <> '' 
            AND _hoc_independent_adls <> 'No' 
            AND _hoc_independent_adls <> '0'
         )
         OR 
         (
            _hoc_independent_adls_s1 IS NOT NULL 
            AND _hoc_independent_adls_s1 <> '' 
            AND _hoc_independent_adls_s1 <> 'No' 
            AND _hoc_independent_adls_s1 <> '0'
         )
         OR 
         (
            _hoc_hypertension IS NOT NULL 
            AND _hoc_hypertension <> '' 
            AND _hoc_hypertension <> 'No' 
            AND _hoc_hypertension <> '0'
         )
         OR 
         (
            _hoc_dyslipidemia IS NOT NULL 
            AND _hoc_dyslipidemia <> '' 
            AND _hoc_dyslipidemia <> 'No' 
            AND _hoc_dyslipidemia <> '0'
         )
         OR 
         (
            _hoc_smoking_status IS NOT NULL 
            AND _hoc_smoking_status <> '' 
            AND _hoc_smoking_status <> 'No' 
            AND _hoc_smoking_status <> '0'
         )
         OR 
         (
            _hoc_alcohol_consumption IS NOT NULL 
            AND _hoc_alcohol_consumption <> '' 
            AND _hoc_alcohol_consumption <> 'No' 
            AND _hoc_alcohol_consumption <> '0'
         )
         OR 
         (
            _hoc_chemotherapy IS NOT NULL 
            AND _hoc_chemotherapy <> '' 
            AND _hoc_chemotherapy <> 'No' 
            AND _hoc_chemotherapy <> '0'
         )
         OR 
         (
            _hoc_diabetes IS NOT NULL 
            AND _hoc_diabetes <> '' 
            AND _hoc_diabetes <> 'No' 
            AND _hoc_diabetes <> '0'
         )
         OR 
         (
            _diabetes_s1 IS NOT NULL 
            AND _diabetes_s1 <> '' 
            AND _diabetes_s1 <> 'No' 
            AND _diabetes_s1 <> '0'
         )
         OR 
         (
            _hoc_diabetes_type IS NOT NULL 
            AND _hoc_diabetes_type <> '' 
            AND _hoc_diabetes_type <> 'No' 
            AND _hoc_diabetes_type <> '0'
         )
         OR 
         (
            _diabetes_type_management_diet IS NOT NULL 
            AND _diabetes_type_management_diet <> '' 
            AND _diabetes_type_management_diet <> 'No' 
            AND _diabetes_type_management_diet <> '0'
         )
         OR 
         (
            _diabetes_type_management_oral IS NOT NULL 
            AND _diabetes_type_management_oral <> '' 
            AND _diabetes_type_management_oral <> 'No' 
            AND _diabetes_type_management_oral <> '0'
         )
         OR 
         (
            _diabetes_type_management_insulin IS NOT NULL 
            AND _diabetes_type_management_insulin <> '' 
            AND _diabetes_type_management_insulin <> 'No' 
            AND _diabetes_type_management_insulin <> '0'
         )
         OR 
         (
            _hoc_family_history_ihd IS NOT NULL 
            AND _hoc_family_history_ihd <> '' 
            AND _hoc_family_history_ihd <> 'No' 
            AND _hoc_family_history_ihd <> '0'
         )
         OR 
         (
            _hoc_family_history_cardiomyopathy IS NOT NULL 
            AND _hoc_family_history_cardiomyopathy <> '' 
            AND _hoc_family_history_cardiomyopathy <> 'No' 
            AND _hoc_family_history_cardiomyopathy <> '0'
         )
         OR 
         (
            _MH_CV_CAD IS NOT NULL 
            AND _MH_CV_CAD <> '' 
            AND _MH_CV_CAD <> 'No' 
            AND _MH_CV_CAD <> '0'
         )
         OR 
         (
            _hoc_ami IS NOT NULL 
            AND _hoc_ami <> '' 
            AND _hoc_ami <> 'No' 
            AND _hoc_ami <> '0'
         )
         OR 
         (
            _congestive_heart_failure IS NOT NULL 
            AND _congestive_heart_failure <> '' 
            AND _congestive_heart_failure <> 'No' 
            AND _congestive_heart_failure <> '0'
         )
         OR 
         (
            _hoc_cva IS NOT NULL 
            AND _hoc_cva <> '' 
            AND _hoc_cva <> 'No' 
            AND _hoc_cva <> '0'
         )
         OR 
         (
            _hemiplegia IS NOT NULL 
            AND _hemiplegia <> '' 
            AND _hemiplegia <> 'No' 
            AND _hemiplegia <> '0'
         )
         OR 
         (
            _hoc_pvd IS NOT NULL 
            AND _hoc_pvd <> '' 
            AND _hoc_pvd <> 'No' 
            AND _hoc_pvd <> '0'
         )
         OR 
         (
            _hoc_arrhythmia IS NOT NULL 
            AND _hoc_arrhythmia <> '' 
            AND _hoc_arrhythmia <> 'No' 
            AND _hoc_arrhythmia <> '0'
         )
         OR 
         (
            _hoc_arrhythmia_type_atrial_fibrillationflutter IS NOT NULL 
            AND _hoc_arrhythmia_type_atrial_fibrillationflutter <> '' 
            AND _hoc_arrhythmia_type_atrial_fibrillationflutter <> 'No' 
            AND _hoc_arrhythmia_type_atrial_fibrillationflutter <> '0'
         )
         OR 
         (
            _hoc_arrhythmia_type_ventricular_tachycardia IS NOT NULL 
            AND _hoc_arrhythmia_type_ventricular_tachycardia <> '' 
            AND _hoc_arrhythmia_type_ventricular_tachycardia <> 'No' 
            AND _hoc_arrhythmia_type_ventricular_tachycardia <> '0'
         )
         OR 
         (
            _hoc_arrhythmia_type_ventricular_fibrillation IS NOT NULL 
            AND _hoc_arrhythmia_type_ventricular_fibrillation <> '' 
            AND _hoc_arrhythmia_type_ventricular_fibrillation <> 'No' 
            AND _hoc_arrhythmia_type_ventricular_fibrillation <> '0'
         )
         OR 
         (
            _hoc_revascularisation IS NOT NULL 
            AND _hoc_revascularisation <> '' 
            AND _hoc_revascularisation <> 'No' 
            AND _hoc_revascularisation <> '0'
         )
         OR 
         (
            _hoc_revascularisation_type_cabg IS NOT NULL 
            AND _hoc_revascularisation_type_cabg <> '' 
            AND _hoc_revascularisation_type_cabg <> 'No' 
            AND _hoc_revascularisation_type_cabg <> '0'
         )
         OR 
         (
            _hoc_revascularisation_type_pci IS NOT NULL 
            AND _hoc_revascularisation_type_pci <> '' 
            AND _hoc_revascularisation_type_pci <> 'No' 
            AND _hoc_revascularisation_type_pci <> '0'
         )
         OR 
         (
            _hoc_other_cardiac_surgery IS NOT NULL 
            AND _hoc_other_cardiac_surgery <> '' 
            AND _hoc_other_cardiac_surgery <> 'No' 
            AND _hoc_other_cardiac_surgery <> '0'
         )
         OR 
         (
            _cardiac_surgery_type_congenital IS NOT NULL 
            AND _cardiac_surgery_type_congenital <> '' 
            AND _cardiac_surgery_type_congenital <> 'No' 
            AND _cardiac_surgery_type_congenital <> '0'
         )
         OR 
         (
            _cardiac_surgery_type_valve IS NOT NULL 
            AND _cardiac_surgery_type_valve <> '' 
            AND _cardiac_surgery_type_valve <> 'No' 
            AND _cardiac_surgery_type_valve <> '0'
         )
         OR 
         (
            _cardiac_surgery_type_aortic IS NOT NULL 
            AND _cardiac_surgery_type_aortic <> '' 
            AND _cardiac_surgery_type_aortic <> 'No' 
            AND _cardiac_surgery_type_aortic <> '0'
         )
         OR 
         (
            _hoc_chronic_renal_failure IS NOT NULL 
            AND _hoc_chronic_renal_failure <> '' 
            AND _hoc_chronic_renal_failure <> 'No' 
            AND _hoc_chronic_renal_failure <> '0'
         )
         OR 
         (
            _hoc_chronic_renal_failure_s1 IS NOT NULL 
            AND _hoc_chronic_renal_failure_s1 <> '' 
            AND _hoc_chronic_renal_failure_s1 <> 'No' 
            AND _hoc_chronic_renal_failure_s1 <> '0'
         )
         OR 
         (
            _hoc_airway_disease IS NOT NULL 
            AND _hoc_airway_disease <> '' 
            AND _hoc_airway_disease <> 'No' 
            AND _hoc_airway_disease <> '0'
         )
         OR 
         (
            _hoc_airway_disease_type IS NOT NULL 
            AND _hoc_airway_disease_type <> '' 
            AND _hoc_airway_disease_type <> 'No' 
            AND _hoc_airway_disease_type <> '0'
         )
         OR 
         (
            _hoc_obstructive_sleep_apnoea IS NOT NULL 
            AND _hoc_obstructive_sleep_apnoea <> '' 
            AND _hoc_obstructive_sleep_apnoea <> 'No' 
            AND _hoc_obstructive_sleep_apnoea <> '0'
         )
         OR 
         (
            _chronic_liver_disease IS NOT NULL 
            AND _chronic_liver_disease <> '' 
            AND _chronic_liver_disease <> 'No' 
            AND _chronic_liver_disease <> '0'
         )
         OR 
         (
            _gastro_intestinal_liver_s2 IS NOT NULL 
            AND _gastro_intestinal_liver_s2 <> '' 
            AND _gastro_intestinal_liver_s2 <> 'No' 
            AND _gastro_intestinal_liver_s2 <> '0'
         )
         OR 
         (
            _peptic_ulcer_disease IS NOT NULL 
            AND _peptic_ulcer_disease <> '' 
            AND _peptic_ulcer_disease <> 'No' 
            AND _peptic_ulcer_disease <> '0'
         )
         OR 
         (
            _hoc_anaemia IS NOT NULL 
            AND _hoc_anaemia <> '' 
            AND _hoc_anaemia <> 'No' 
            AND _hoc_anaemia <> '0'
         )
         OR 
         (
            _connective_tissue_disease IS NOT NULL 
            AND _connective_tissue_disease <> '' 
            AND _connective_tissue_disease <> 'No' 
            AND _connective_tissue_disease <> '0'
         )
         OR 
         (
            _non_metastatic_solid_tumour IS NOT NULL 
            AND _non_metastatic_solid_tumour <> '' 
            AND _non_metastatic_solid_tumour <> 'No' 
            AND _non_metastatic_solid_tumour <> '0'
         )
         OR 
         (
            _metastatic_solid_tumour IS NOT NULL 
            AND _metastatic_solid_tumour <> '' 
            AND _metastatic_solid_tumour <> 'No' 
            AND _metastatic_solid_tumour <> '0'
         )
         OR 
         (
            _lymphoma IS NOT NULL 
            AND _lymphoma <> '' 
            AND _lymphoma <> 'No' 
            AND _lymphoma <> '0'
         )
         OR 
         (
            _leukemia IS NOT NULL 
            AND _leukemia <> '' 
            AND _leukemia <> 'No' 
            AND _leukemia <> '0'
         )
         OR 
         (
            _aids IS NOT NULL 
            AND _aids <> '' 
            AND _aids <> 'No' 
            AND _aids <> '0'
         )
         OR 
         (
            _hoc_dementia IS NOT NULL 
            AND _hoc_dementia <> '' 
            AND _hoc_dementia <> 'No' 
            AND _hoc_dementia <> '0'
         )
         OR 
         (
            _non_cardiac_depression IS NOT NULL 
            AND _non_cardiac_depression <> '' 
            AND _non_cardiac_depression <> 'No' 
            AND _non_cardiac_depression <> '0'
         )
         OR 
         (
            _past_medical_history_add IS NOT NULL 
            AND _past_medical_history_add <> '' 
            AND _past_medical_history_add <> 'No' 
            AND _past_medical_history_add <> '0'
         )
;
GO

