WITH 
cbc AS (
    SELECT
        cs.stay_id
        , MIN(hematocrit) AS hematocrit_min
        , MAX(hematocrit) AS hematocrit_max
        , AVG(hematocrit) AS hematocrit_avg
        , STDDEV(hematocrit) AS hematocrit_std
        , MIN(hemoglobin) AS hemoglobin_min
        , MAX(hemoglobin) AS hemoglobin_max
        , AVG(hemoglobin) AS hemoglobin_avg
        , STDDEV(hemoglobin) AS hemoglobin_std
        , MIN(platelet) AS platelets_min
        , MAX(platelet) AS platelets_max
        , AVG(platelet) AS platelets_avg
        , STDDEV(platelet) AS platelets_std
        , MIN(wbc) AS wbc_min
        , MAX(wbc) AS wbc_max
        , AVG(wbc) AS wbc_avg
        , STDDEV(wbc) AS wbc_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.complete_blood_count le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)

, chem AS (
    SELECT
        cs.stay_id
        , MIN(albumin) AS albumin_min
        , MAX(albumin) AS albumin_max
        , AVG(albumin) as albumin_avg
        , STDDEV(albumin) AS albumin_std
        , MIN(globulin) AS globulin_min
        , MAX(globulin) AS globulin_max
        , AVG(globulin) as globulin_avg
        , STDDEV(globulin) AS globulin_std
        , MIN(total_protein) AS total_protein_min
        , MAX(total_protein) AS total_protein_max
        , AVG(total_protein) as total_protein_avg
        , STDDEV(total_protein) AS total_protein_std
        , MIN(aniongap) AS aniongap_min
        , MAX(aniongap) AS aniongap_max
        , AVG(aniongap) as aniongap_avg
        , STDDEV(aniongap) AS aniongap_std
        , MIN(bicarbonate) AS bicarbonate_min
        , MAX(bicarbonate) AS bicarbonate_max
        , AVG(bicarbonate) as bicarbonate_avg
        , STDDEV(bicarbonate) AS bicarbonate_std
        , MIN(bun) AS bun_min
        , MAX(bun) AS bun_max
        , AVG(bun) AS bun_avg
        , STDDEV(bun) AS bun_std
        , MIN(calcium) AS calcium_min
        , MAX(calcium) AS calcium_max
        , AVG(calcium) AS calcium_avg
        , STDDEV(calcium) AS calcium_std
        , MIN(chloride) AS chloride_min
        , MAX(chloride) AS chloride_max
        , AVG(chloride) AS chloride_avg
        , STDDEV(chloride) AS chloride_std
        , MIN(creatinine) AS creatinine_min
        , MAX(creatinine) AS creatinine_max
        , AVG(creatinine) AS creatinine_avg
        , STDDEV(creatinine) AS creatinine_std
        , MIN(glucose) AS glucose_min
        , MAX(glucose) AS glucose_max
        , AVG(glucose) AS glucose_avg
        , STDDEV(glucose) AS glucose_std
        , MIN(sodium) AS sodium_min
        , MAX(sodium) AS sodium_max
        , AVG(sodium) AS sodium_avg
        , STDDEV(sodium) AS sodium_std
        , MIN(potassium) AS potassium_min
        , MAX(potassium) AS potassium_max
        , AVG(potassium) AS potassium_avg
        , STDDEV(potassium) AS potassium_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.chemistry le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)

, diff AS (
    SELECT
        cs.stay_id
        , MIN(basophils_abs) AS abs_basophils_min
        , MAX(basophils_abs) AS abs_basophils_max
        , AVG(basophils_abs) AS abs_basophils_avg
        , STDDEV(basophils_abs) AS abs_basophils_std
        , MIN(eosinophils_abs) AS abs_eosinophils_min
        , MAX(eosinophils_abs) AS abs_eosinophils_max
        , AVG(eosinophils_abs) AS abs_eosinophils_avg
        , STDDEV(eosinophils_abs) AS abs_eosinophils_std
        , MIN(lymphocytes_abs) AS abs_lymphocytes_min
        , MAX(lymphocytes_abs) AS abs_lymphocytes_max
        , AVG(lymphocytes_abs) AS abs_lymphocytes_avg
        , STDDEV(lymphocytes_abs) AS abs_lymphocytes_std
        , MIN(monocytes_abs) AS abs_monocytes_min
        , MAX(monocytes_abs) AS abs_monocytes_max
        , AVG(monocytes_abs) AS abs_monocytes_avg
        , STDDEV(monocytes_abs) AS abs_monocytes_std
        , MIN(neutrophils_abs) AS abs_neutrophils_min
        , MAX(neutrophils_abs) AS abs_neutrophils_max
        , AVG(neutrophils_abs) AS abs_neutrophils_avg
        , STDDEV(neutrophils_abs) AS abs_neutrophils_std
        , MIN(atypical_lymphocytes) AS atyps_min
        , MAX(atypical_lymphocytes) AS atyps_max
        , AVG(atypical_lymphocytes) AS atyps_avg
        , STDDEV(atypical_lymphocytes) AS atyps_std
        , MIN(bands) AS bands_min
        , MAX(bands) AS bands_max
        , AVG(bands) AS bands_avg
        , STDDEV(bands) AS bands_std
        , MIN(immature_granulocytes) AS imm_granulocytes_min
        , MAX(immature_granulocytes) AS imm_granulocytes_max
        , AVG(immature_granulocytes) AS imm_granulocytes_avg
        , STDDEV(immature_granulocytes) AS imm_granulocytes_std
        , MIN(metamyelocytes) AS metas_min
        , MAX(metamyelocytes) AS metas_max
        , AVG(metamyelocytes) AS metas_avg
        , STDDEV(metamyelocytes) AS metas_std
        , MIN(nrbc) AS nrbc_min
        , MAX(nrbc) AS nrbc_max
        , AVG(nrbc) AS nrbc_avg
        , STDDEV(nrbc) AS nrbc_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.blood_differential le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)

, coag AS (
    SELECT
        cs.stay_id
        , MIN(d_dimer) AS d_dimer_min
        , MAX(d_dimer) AS d_dimer_max
        , AVG(d_dimer) AS d_dimer_avg
        , STDDEV(d_dimer) AS d_dimer_std
        , MIN(fibrinogen) AS fibrinogen_min
        , MAX(fibrinogen) AS fibrinogen_max
        , AVG(fibrinogen) AS fibrinogen_avg
        , STDDEV(fibrinogen) AS fibrinogen_std
        , MIN(thrombin) AS thrombin_min
        , MAX(thrombin) AS thrombin_max
        , AVG(thrombin) AS thrombin_avg
        , STDDEV(thrombin) AS thrombin_std
        , MIN(inr) AS inr_min
        , MAX(inr) AS inr_max
        , AVG(inr) AS inr_avg
        , STDDEV(inr) AS inr_std
        , MIN(pt) AS pt_min
        , MAX(pt) AS pt_max
        , AVG(pt) AS pt_avg
        , STDDEV(pt) AS pt_std
        , MIN(ptt) AS ptt_min
        , MAX(ptt) AS ptt_max
        , AVG(ptt) AS ptt_avg
        , STDDEV(ptt) AS ptt_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.coagulation le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)

, enz AS (
    SELECT
        cs.stay_id
        , MIN(alt) AS alt_min
        , MAX(alt) AS alt_max
        , AVG(alt) AS alt_avg
        , STDDEV(alt) AS alt_std
        , MIN(alp) AS alp_min
        , MAX(alp) AS alp_max
        , AVG(alp) AS alp_avg
        , STDDEV(alp) AS alp_std
        , MIN(ast) AS ast_min
        , MAX(ast) AS ast_max
        , AVG(ast) AS ast_avg
        , STDDEV(ast) AS ast_std
        , MIN(amylase) AS amylase_min
        , MAX(amylase) AS amylase_max
        , AVG(amylase) AS amylase_avg
        , STDDEV(amylase) AS amylase_std
        , MIN(bilirubin_total) AS bilirubin_total_min
        , MAX(bilirubin_total) AS bilirubin_total_max
        , AVG(bilirubin_total) AS bilirubin_total_avg
        , STDDEV(bilirubin_total) AS bilirubin_total_std
        , MIN(bilirubin_direct) AS bilirubin_direct_min
        , MAX(bilirubin_direct) AS bilirubin_direct_max
        , AVG(bilirubin_direct) AS bilirubin_direct_avg
        , STDDEV(bilirubin_direct) AS bilirubin_direct_std
        , MIN(bilirubin_indirect) AS bilirubin_indirect_min
        , MAX(bilirubin_indirect) AS bilirubin_indirect_max
        , AVG(bilirubin_indirect) AS bilirubin_indirect_avg
        , STDDEV(bilirubin_indirect) AS bilirubin_indirect_std
        , MIN(ck_cpk) AS ck_cpk_min
        , MAX(ck_cpk) AS ck_cpk_max
        , AVG(ck_cpk) AS ck_cpk_avg
        , STDDEV(ck_cpk) AS ck_cpk_std
        , MIN(ck_mb) AS ck_mb_min
        , MAX(ck_mb) AS ck_mb_max
        , AVG(ck_mb) AS ck_mb_avg
        , STDDEV(ck_mb) AS ck_mb_std
        , MIN(ggt) AS ggt_min
        , MAX(ggt) AS ggt_max
        , AVG(ggt) AS ggt_avg
        , STDDEV(ggt) AS ggt_std
        , MIN(ld_ldh) AS ld_ldh_min
        , MAX(ld_ldh) AS ld_ldh_max
        , AVG(ld_ldh) AS ld_ldh_avg
        , STDDEV(ld_ldh) AS ld_ldh_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.enzyme le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)
, lab as (
SELECT
    cs.stay_id,
    MIN(heart_rate) AS heart_rate_min
    , MAX(heart_rate) AS heart_rate_max
    , AVG(heart_rate) AS heart_rate_mean
    , STDDEV(heart_rate) AS heart_rate_std
    , MIN(sbp) AS sbp_min
    , MAX(sbp) AS sbp_max
    , AVG(sbp) AS sbp_mean
    , STDDEV(sbp) AS sbp_std
    , MIN(dbp) AS dbp_min
    , MAX(dbp) AS dbp_max
    , AVG(dbp) AS dbp_mean
    , STDDEV(dbp) AS dbp_std
    , MIN(mbp) AS mbp_min
    , MAX(mbp) AS mbp_max
    , AVG(mbp) AS mbp_mean
    , STDDEV(mbp) AS mbp_std
    , MIN(resp_rate) AS resp_rate_min
    , MAX(resp_rate) AS resp_rate_max
    , AVG(resp_rate) AS resp_rate_mean
    , STDDEV(resp_rate) AS resp_rate_std
    , MIN(temperature) AS temperature_min
    , MAX(temperature) AS temperature_max
    , AVG(temperature) AS temperature_mean
    , STDDEV(temperature) AS temperature_std
    , MIN(spo2) AS spo2_min
    , MAX(spo2) AS spo2_max
    , AVG(spo2) AS spo2_mean
    , STDDEV(spo2) AS spo2_std
    , MIN(glucose) AS glucose_min
    , MAX(glucose) AS glucose_max
    , AVG(glucose) AS glucose_mean
    , STDDEV(glucose) AS glucose_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.vitalsign vs
        ON cs.subject_id = vs.subject_id
            AND vs.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND vs.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.subject_id, cs.stay_id
)
SELECT
    ie.stay_id,
    srt.sepsis3 as sepsis,
    enz.*, 
    coag.*, 
    diff.*, 
    chem.*, 
    cbc.*,
	lab.*
FROM mimiciv_icu.icustays ie
LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
    on ie.stay_id = srt.stay_id
LEFT JOIN cbc
    ON ie.stay_id = cbc.stay_id
LEFT JOIN chem
    ON ie.stay_id = chem.stay_id
LEFT JOIN diff
    ON ie.stay_id = diff.stay_id
LEFT JOIN coag
    ON ie.stay_id = coag.stay_id
LEFT JOIN enz
    ON ie.stay_id = enz.stay_id
Left Join lab
	on ie.stay_id = lab.stay_id
;