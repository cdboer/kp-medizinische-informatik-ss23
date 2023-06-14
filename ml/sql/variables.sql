-- DROP TABLE IF EXISTS mimiciv_derived.pre_septic_lab_8h; CREATE TABLE mimiciv_derived.pre_septic_lab_8h  AS
WITH 
sepsis AS (SELECT stay_id, sofa_time FROM mimiciv_derived.sepsis3)

, cbc AS (
    SELECT
        ie.stay_id
        , MIN(hematocrit) AS hematocrit_min
        , MAX(hematocrit) AS hematocrit_max
        , MIN(hemoglobin) AS hemoglobin_min
        , MAX(hemoglobin) AS hemoglobin_max
        , MIN(platelet) AS platelets_min
        , MAX(platelet) AS platelets_max
        , MIN(wbc) AS wbc_min
        , MAX(wbc) AS wbc_max
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.complete_blood_count le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '8' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '8' HOUR END
    GROUP BY ie.stay_id
)

, chem AS (
    SELECT
        ie.stay_id
        , MIN(albumin) AS albumin_min, MAX(albumin) AS albumin_max
        , MIN(globulin) AS globulin_min, MAX(globulin) AS globulin_max
        , MIN(total_protein) AS total_protein_min
        , MAX(total_protein) AS total_protein_max
        , MIN(aniongap) AS aniongap_min, MAX(aniongap) AS aniongap_max
        , MIN(bicarbonate) AS bicarbonate_min
        , MAX(bicarbonate) AS bicarbonate_max
        , MIN(bun) AS bun_min, MAX(bun) AS bun_max
        , MIN(calcium) AS calcium_min, MAX(calcium) AS calcium_max
        , MIN(chloride) AS chloride_min, MAX(chloride) AS chloride_max
        , MIN(creatinine) AS creatinine_min, MAX(creatinine) AS creatinine_max
        , MIN(glucose) AS glucose_min, MAX(glucose) AS glucose_max
        , MIN(sodium) AS sodium_min, MAX(sodium) AS sodium_max
        , MIN(potassium) AS potassium_min, MAX(potassium) AS potassium_max
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.chemistry le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '8' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '8' HOUR END
    GROUP BY ie.stay_id
)

, diff AS (
    SELECT
        ie.stay_id
        , MIN(basophils_abs) AS abs_basophils_min
        , MAX(basophils_abs) AS abs_basophils_max
        , MIN(eosinophils_abs) AS abs_eosinophils_min
        , MAX(eosinophils_abs) AS abs_eosinophils_max
        , MIN(lymphocytes_abs) AS abs_lymphocytes_min
        , MAX(lymphocytes_abs) AS abs_lymphocytes_max
        , MIN(monocytes_abs) AS abs_monocytes_min
        , MAX(monocytes_abs) AS abs_monocytes_max
        , MIN(neutrophils_abs) AS abs_neutrophils_min
        , MAX(neutrophils_abs) AS abs_neutrophils_max
        , MIN(atypical_lymphocytes) AS atyps_min
        , MAX(atypical_lymphocytes) AS atyps_max
        , MIN(bands) AS bands_min, MAX(bands) AS bands_max
        , MIN(immature_granulocytes) AS imm_granulocytes_min
        , MAX(immature_granulocytes) AS imm_granulocytes_max
        , MIN(metamyelocytes) AS metas_min, MAX(metamyelocytes) AS metas_max
        , MIN(nrbc) AS nrbc_min, MAX(nrbc) AS nrbc_max
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.blood_differential le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '8' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '8' HOUR END
    GROUP BY ie.stay_id
)

, coag AS (
    SELECT
        ie.stay_id
        , MIN(d_dimer) AS d_dimer_min, MAX(d_dimer) AS d_dimer_max
        , MIN(fibrinogen) AS fibrinogen_min, MAX(fibrinogen) AS fibrinogen_max
        , MIN(thrombin) AS thrombin_min, MAX(thrombin) AS thrombin_max
        , MIN(inr) AS inr_min, MAX(inr) AS inr_max
        , MIN(pt) AS pt_min, MAX(pt) AS pt_max
        , MIN(ptt) AS ptt_min, MAX(ptt) AS ptt_max
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.coagulation le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '8' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '8' HOUR END
    GROUP BY ie.stay_id
)

, enz AS (
    SELECT
        ie.stay_id
        , MIN(alt) AS alt_min, MAX(alt) AS alt_max
        , MIN(alp) AS alp_min, MAX(alp) AS alp_max
        , MIN(ast) AS ast_min, MAX(ast) AS ast_max
        , MIN(amylase) AS amylase_min, MAX(amylase) AS amylase_max
        , MIN(bilirubin_total) AS bilirubin_total_min
        , MAX(bilirubin_total) AS bilirubin_total_max
        , MIN(bilirubin_direct) AS bilirubin_direct_min
        , MAX(bilirubin_direct) AS bilirubin_direct_max
        , MIN(bilirubin_indirect) AS bilirubin_indirect_min
        , MAX(bilirubin_indirect) AS bilirubin_indirect_max
        , MIN(ck_cpk) AS ck_cpk_min, MAX(ck_cpk) AS ck_cpk_max
        , MIN(ck_mb) AS ck_mb_min, MAX(ck_mb) AS ck_mb_max
        , MIN(ggt) AS ggt_min, MAX(ggt) AS ggt_max
        , MIN(ld_ldh) AS ld_ldh_min, MAX(ld_ldh) AS ld_ldh_max
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.enzyme le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '8' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '8' HOUR END
    GROUP BY ie.stay_id
)
, lab as (
WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT
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
    , CASE WHEN ie.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
	, ie.stay_id
FROM mimiciv_icu.icustays ie
LEFT JOIN mimiciv_derived.sepsis3 sepsis
    ON ie.stay_id = sepsis.stay_id
LEFT JOIN mimiciv_derived.vitalsign vs
    ON ie.subject_id = vs.subject_id
    -- pre septic window defined as 8 hours before sepsis onset
    -- if no sepsis onset, then 8 hours after ICU admission to get the same window size
    -- resolution could be improved ..
        AND vs.charttime >= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime ELSE sepsis.sofa_time - INTERVAL '8' HOUR END)
        AND vs.charttime <= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '8' HOUR ELSE sepsis.sofa_time END)
GROUP BY ie.subject_id, ie.stay_id
)
SELECT
    ie.subject_id
    --, ie.stay_id
    -- complete blood count
    , hematocrit_min, hematocrit_max
    , hemoglobin_min, hemoglobin_max
    , platelets_min, platelets_max
    , wbc_min, wbc_max
    -- chemistry
    , albumin_min, albumin_max
    , globulin_min, globulin_max
    , total_protein_min, total_protein_max
    , aniongap_min, aniongap_max
    , bicarbonate_min, bicarbonate_max
    , bun_min, bun_max
    , calcium_min, calcium_max
    , chloride_min, chloride_max
    , creatinine_min, creatinine_max
    , lab.glucose_min, lab.glucose_max
    , sodium_min, sodium_max
    , potassium_min, potassium_max
    -- blood differential
    , abs_basophils_min, abs_basophils_max
    , abs_eosinophils_min, abs_eosinophils_max
    , abs_lymphocytes_min, abs_lymphocytes_max
    , abs_monocytes_min, abs_monocytes_max
    , abs_neutrophils_min, abs_neutrophils_max
    , atyps_min, atyps_max
    , bands_min, bands_max
    , imm_granulocytes_min, imm_granulocytes_max
    , metas_min, metas_max
    , nrbc_min, nrbc_max
    -- coagulation
    , d_dimer_min, d_dimer_max
    , fibrinogen_min, fibrinogen_max
    , thrombin_min, thrombin_max
    , inr_min, inr_max
    , pt_min, pt_max
    , ptt_min, ptt_max
    -- enzymes and bilirubin
    , alt_min, alt_max
    , alp_min, alp_max
    , ast_min, ast_max
    , amylase_min, amylase_max
    , bilirubin_total_min, bilirubin_total_max
    , bilirubin_direct_min, bilirubin_direct_max
    , bilirubin_indirect_min, bilirubin_indirect_max
    , ck_cpk_min, ck_cpk_max
    , ck_mb_min, ck_mb_max
    , ggt_min, ggt_max
    , ld_ldh_min, ld_ldh_max
	, lab.*
FROM mimiciv_icu.icustays ie
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