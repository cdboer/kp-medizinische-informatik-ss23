/*
 Extracts MIN, MAX, MEAN, STD lab results for all ICU patients for a given window size (Parameter: window_size_h).
 The window is defined as X hours before sepsis onset for septic patients, and X hours after ICU admission for non-septic patients.
 We use the sepsis3 sofa_time as the sepsis onset time for septic patients, and the ICU intime for non-septic patients.
 
 NOTE: When we talk about patients, what we really mean is ICU stays. Patients can have multiple ICU stays as evidenced by the icustays table.
 */
WITH sepsis AS (
    SELECT stay_id
    FROM mimiciv_derived.sepsis3
),
cbc AS (
    SELECT ie.stay_id,
        MIN(hematocrit) AS hematocrit_min,
        MAX(hematocrit) AS hematocrit_max,
        AVG(hematocrit) AS hematocrit_mean,
        STDDEV(hematocrit) AS hematocrit_std,
        MIN(hemoglobin) AS hemoglobin_min,
        MAX(hemoglobin) AS hemoglobin_max,
        AVG(hemoglobin) AS hemoglobin_mean,
        STDDEV(hemoglobin) AS hemoglobin_std,
        MIN(platelet) AS platelets_min,
        MAX(platelet) AS platelets_max,
        AVG(platelet) AS platelets_mean,
        STDDEV(platelet) AS platelets_std,
        MIN(wbc) AS wbc_min,
        MAX(wbc) AS wbc_max,
        AVG(wbc) AS wbc_mean,
        STDDEV(wbc) AS wbc_std
    FROM mimiciv_icu.icustays ie
        LEFT JOIN mimiciv_derived.complete_blood_count le ON le.subject_id = ie.subject_id
        LEFT JOIN mimiciv_derived.sepsis3 sepsis ON ie.stay_id = sepsis.stay_id
        AND le.charttime >= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime
                ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND le.charttime <= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '%(window_size_h)s' HOUR
                ELSE sepsis.sofa_time
            END
        )
    GROUP BY ie.stay_id
),
chem AS (
    SELECT ie.stay_id,
        MIN(albumin) AS albumin_min,
        MAX(albumin) AS albumin_max,
        AVG(albumin) AS albumin_mean,
        STDDEV(albumin) AS albumin_std,
        MIN(globulin) AS globulin_min,
        MAX(globulin) AS globulin_max,
        AVG(globulin) AS globulin_mean,
        STDDEV(globulin) AS globulin_std,
        MIN(total_protein) AS total_protein_min,
        MAX(total_protein) AS total_protein_max,
        AVG(total_protein) AS total_protein_mean,
        STDDEV(total_protein) AS total_protein_std,
        MIN(aniongap) AS aniongap_min,
        MAX(aniongap) AS aniongap_max,
        AVG(aniongap) AS aniongap_mean,
        STDDEV(aniongap) AS aniongap_std,
        MIN(bicarbonate) AS bicarbonate_min,
        MAX(bicarbonate) AS bicarbonate_max,
        AVG(bicarbonate) AS bicarbonate_mean,
        STDDEV(bicarbonate) AS bicarbonate_std,
        MIN(bun) AS bun_min,
        MAX(bun) AS bun_max,
        AVG(bun) AS bun_mean,
        STDDEV(bun) AS bun_std,
        MIN(calcium) AS calcium_min,
        MAX(calcium) AS calcium_max,
        AVG(calcium) AS calcium_mean,
        STDDEV(calcium) AS calcium_std,
        MIN(chloride) AS chloride_min,
        MAX(chloride) AS chloride_max,
        AVG(chloride) AS chloride_mean,
        STDDEV(chloride) AS chloride_std,
        MIN(creatinine) AS creatinine_min,
        MAX(creatinine) AS creatinine_max,
        AVG(creatinine) AS creatinine_mean,
        STDDEV(creatinine) AS creatinine_std,
        MIN(glucose) AS glucose_min,
        MAX(glucose) AS glucose_max,
        AVG(glucose) AS glucose_mean,
        STDDEV(glucose) AS glucose_std,
        MIN(sodium) AS sodium_min,
        MAX(sodium) AS sodium_max,
        AVG(sodium) AS sodium_mean,
        STDDEV(sodium) AS sodium_std,
        MIN(potassium) AS potassium_min,
        MAX(potassium) AS potassium_max,
        AVG(potassium) AS potassium_mean,
        STDDEV(potassium) AS potassium_std
    FROM mimiciv_icu.icustays ie
        LEFT JOIN mimiciv_derived.chemistry le ON le.subject_id = ie.subject_id
        LEFT JOIN mimiciv_derived.sepsis3 sepsis ON ie.stay_id = sepsis.stay_id
        AND le.charttime >= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime
                ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND le.charttime <= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '%(window_size_h)s' HOUR
                ELSE sepsis.sofa_time
            END
        )
    GROUP BY ie.stay_id
),
diff AS (
    SELECT ie.stay_id,
        MIN(basophils_abs) AS abs_basophils_min,
        MAX(basophils_abs) AS abs_basophils_max,
        AVG(basophils_abs) AS abs_basophils_mean,
        STDDEV(basophils_abs) AS abs_basophils_std,
        MIN(eosinophils_abs) AS abs_eosinophils_min,
        MAX(eosinophils_abs) AS abs_eosinophils_max,
        AVG(eosinophils_abs) AS abs_eosinophils_mean,
        STDDEV(eosinophils_abs) AS abs_eosinophils_std,
        MIN(lymphocytes_abs) AS abs_lymphocytes_min,
        MAX(lymphocytes_abs) AS abs_lymphocytes_max,
        AVG(lymphocytes_abs) AS abs_lymphocytes_mean,
        STDDEV(lymphocytes_abs) AS abs_lymphocytes_std,
        MIN(monocytes_abs) AS abs_monocytes_min,
        MAX(monocytes_abs) AS abs_monocytes_max,
        AVG(monocytes_abs) AS abs_monocytes_mean,
        STDDEV(monocytes_abs) AS abs_monocytes_std,
        MIN(neutrophils_abs) AS abs_neutrophils_min,
        MAX(neutrophils_abs) AS abs_neutrophils_max,
        AVG(neutrophils_abs) AS abs_neutrophils_mean,
        STDDEV(neutrophils_abs) AS abs_neutrophils_std,
        MIN(atypical_lymphocytes) AS atyps_min,
        MAX(atypical_lymphocytes) AS atyps_max,
        AVG(atypical_lymphocytes) AS atyps_mean,
        STDDEV(atypical_lymphocytes) AS atyps_std,
        MIN(bands) AS bands_min,
        MAX(bands) AS bands_max,
        AVG(bands) AS bands_mean,
        STDDEV(bands) AS bands_std,
        MIN(immature_granulocytes) AS imm_granulocytes_min,
        MAX(immature_granulocytes) AS imm_granulocytes_max,
        AVG(immature_granulocytes) AS imm_granulocytes_mean,
        STDDEV(immature_granulocytes) AS imm_granulocytes_std,
        MIN(metamyelocytes) AS metas_min,
        MAX(metamyelocytes) AS metas_max,
        AVG(metamyelocytes) AS metas_mean,
        STDDEV(metamyelocytes) AS metas_std,
        MIN(nrbc) AS nrbc_min,
        MAX(nrbc) AS nrbc_max,
        AVG(nrbc) AS nrbc_mean,
        STDDEV(nrbc) AS nrbc_std
    FROM mimiciv_icu.icustays ie
        LEFT JOIN mimiciv_derived.blood_differential le ON le.subject_id = ie.subject_id
        LEFT JOIN mimiciv_derived.sepsis3 sepsis ON ie.stay_id = sepsis.stay_id
        AND le.charttime >= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime
                ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND le.charttime <= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '%(window_size_h)s' HOUR
                ELSE sepsis.sofa_time
            END
        )
    GROUP BY ie.stay_id
),
coag AS (
    SELECT ie.stay_id,
        MIN(d_dimer) AS d_dimer_min,
        MAX(d_dimer) AS d_dimer_max,
        AVG(d_dimer) AS d_dimer_mean,
        STDDEV(d_dimer) AS d_dimer_std,
        MIN(fibrinogen) AS fibrinogen_min,
        MAX(fibrinogen) AS fibrinogen_max,
        AVG(fibrinogen) AS fibrinogen_mean,
        STDDEV(fibrinogen) AS fibrinogen_std,
        MIN(thrombin) AS thrombin_min,
        MAX(thrombin) AS thrombin_max,
        AVG(thrombin) AS thrombin_mean,
        STDDEV(thrombin) AS thrombin_std,
        MIN(inr) AS inr_min,
        MAX(inr) AS inr_max,
        AVG(inr) AS inr_mean,
        STDDEV(inr) AS inr_std,
        MIN(pt) AS pt_min,
        MAX(pt) AS pt_max,
        AVG(pt) AS pt_mean,
        STDDEV(pt) AS pt_std,
        MIN(ptt) AS ptt_min,
        MAX(ptt) AS ptt_max,
        AVG(ptt) AS ptt_mean,
        STDDEV(ptt) AS ptt_std
    FROM mimiciv_icu.icustays ie
        LEFT JOIN mimiciv_derived.coagulation le ON le.subject_id = ie.subject_id
        LEFT JOIN mimiciv_derived.sepsis3 sepsis ON ie.stay_id = sepsis.stay_id
        AND le.charttime >= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime
                ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND le.charttime <= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '%(window_size_h)s' HOUR
                ELSE sepsis.sofa_time
            END
        )
    GROUP BY ie.stay_id
),
enz AS (
    SELECT ie.stay_id,
        MIN(alt) AS alt_min,
        MAX(alt) AS alt_max,
        AVG(alt) AS alt_mean,
        STDDEV(alt) AS alt_std,
        MIN(alp) AS alp_min,
        MAX(alp) AS alp_max,
        AVG(alp) AS alp_mean,
        STDDEV(alp) AS alp_std,
        MIN(ast) AS ast_min,
        MAX(ast) AS ast_max,
        AVG(ast) AS ast_mean,
        STDDEV(ast) AS ast_std,
        MIN(amylase) AS amylase_min,
        MAX(amylase) AS amylase_max,
        AVG(amylase) AS amylase_mean,
        STDDEV(amylase) AS amylase_std,
        MIN(bilirubin_total) AS bilirubin_total_min,
        MAX(bilirubin_total) AS bilirubin_total_max,
        AVG(bilirubin_total) AS bilirubin_total_mean,
        STDDEV(bilirubin_total) AS bilirubin_total_std,
        MIN(bilirubin_direct) AS bilirubin_direct_min,
        MAX(bilirubin_direct) AS bilirubin_direct_max,
        AVG(bilirubin_direct) AS bilirubin_direct_mean,
        STDDEV(bilirubin_direct) AS bilirubin_direct_std,
        MIN(bilirubin_indirect) AS bilirubin_indirect_min,
        MAX(bilirubin_indirect) AS bilirubin_indirect_max,
        AVG(bilirubin_indirect) AS bilirubin_indirect_mean,
        STDDEV(bilirubin_indirect) AS bilirubin_indirect_std,
        MIN(ck_cpk) AS ck_cpk_min,
        MAX(ck_cpk) AS ck_cpk_max,
        AVG(ck_cpk) AS ck_cpk_mean,
        STDDEV(ck_cpk) AS ck_cpk_std,
        MIN(ck_mb) AS ck_mb_min,
        MAX(ck_mb) AS ck_mb_max,
        AVG(ck_mb) AS ck_mb_mean,
        STDDEV(ck_mb) AS ck_mb_std,
        MIN(ggt) AS ggt_min,
        MAX(ggt) AS ggt_max,
        AVG(ggt) AS ggt_mean,
        STDDEV(ggt) AS ggt_std,
        MIN(ld_ldh) AS ld_ldh_min,
        MAX(ld_ldh) AS ld_ldh_max,
        AVG(ld_ldh) AS ld_ldh_mean,
        STDDEV(ld_ldh) AS ld_ldh_std
    FROM mimiciv_icu.icustays ie
        LEFT JOIN mimiciv_derived.enzyme le ON le.subject_id = ie.subject_id
        LEFT JOIN mimiciv_derived.sepsis3 sepsis ON ie.stay_id = sepsis.stay_id
        AND le.charttime >= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime
                ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND le.charttime <= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '%(window_size_h)s' HOUR
                ELSE sepsis.sofa_time
            END
        )
    GROUP BY ie.stay_id
)
SELECT -- complete blood count
    hematocrit_min,
    hematocrit_max,
    hematocrit_mean,
    hematocrit_std,
    hemoglobin_min,
    hemoglobin_max,
    hemoglobin_mean,
    hemoglobin_std,
    platelets_min,
    platelets_max,
    platelets_mean,
    platelets_std,
    wbc_min,
    wbc_max,
    wbc_mean,
    wbc_std,
    -- chemistry
    albumin_min,
    albumin_max,
    albumin_mean,
    albumin_std,
    globulin_min,
    globulin_max,
    globulin_mean,
    globulin_std,
    total_protein_min,
    total_protein_max,
    total_protein_mean,
    total_protein_std,
    aniongap_min,
    aniongap_max,
    aniongap_mean,
    aniongap_std,
    bicarbonate_min,
    bicarbonate_max,
    bicarbonate_mean,
    bicarbonate_std,
    bun_min,
    bun_max,
    bun_mean,
    bun_std,
    calcium_min,
    calcium_max,
    calcium_mean,
    calcium_std,
    chloride_min,
    chloride_max,
    chloride_mean,
    chloride_std,
    creatinine_min,
    creatinine_max,
    creatinine_mean,
    creatinine_std,
    glucose_min,
    glucose_max,
    glucose_mean,
    glucose_std,
    sodium_min,
    sodium_max,
    sodium_mean,
    sodium_std,
    potassium_min,
    potassium_max,
    potassium_mean,
    potassium_std,
    -- blood differential
    abs_basophils_min,
    abs_basophils_max,
    abs_basophils_mean,
    abs_basophils_std,
    abs_eosinophils_min,
    abs_eosinophils_max,
    abs_eosinophils_mean,
    abs_eosinophils_std,
    abs_lymphocytes_min,
    abs_lymphocytes_max,
    abs_lymphocytes_mean,
    abs_lymphocytes_std,
    abs_monocytes_min,
    abs_monocytes_max,
    abs_monocytes_mean,
    abs_monocytes_std,
    abs_neutrophils_min,
    abs_neutrophils_max,
    abs_neutrophils_mean,
    abs_neutrophils_std,
    atyps_min,
    atyps_max,
    atyps_mean,
    atyps_std,
    bands_min,
    bands_max,
    bands_mean,
    bands_std,
    imm_granulocytes_min,
    imm_granulocytes_max,
    imm_granulocytes_mean,
    imm_granulocytes_std,
    metas_min,
    metas_max,
    metas_mean,
    metas_std,
    nrbc_min,
    nrbc_max,
    nrbc_mean,
    nrbc_std,
    -- coagulation
    d_dimer_min,
    d_dimer_max,
    d_dimer_mean,
    d_dimer_std,
    fibrinogen_min,
    fibrinogen_max,
    fibrinogen_mean,
    fibrinogen_std,
    thrombin_min,
    thrombin_max,
    thrombin_mean,
    thrombin_std,
    inr_min,
    inr_max,
    inr_mean,
    inr_std,
    pt_min,
    pt_max,
    pt_mean,
    pt_std,
    ptt_min,
    ptt_max,
    ptt_mean,
    ptt_std,
    -- enzymes and bilirubin
    alt_min,
    alt_max,
    alt_mean,
    alt_std,
    alp_min,
    alp_max,
    alp_mean,
    alp_std,
    ast_min,
    ast_max,
    ast_mean,
    ast_std,
    amylase_min,
    amylase_max,
    amylase_mean,
    amylase_std,
    bilirubin_total_min,
    bilirubin_total_max,
    bilirubin_total_mean,
    bilirubin_total_std,
    bilirubin_direct_min,
    bilirubin_direct_max,
    bilirubin_direct_mean,
    bilirubin_direct_std,
    bilirubin_indirect_min,
    bilirubin_indirect_max,
    bilirubin_indirect_mean,
    bilirubin_indirect_std,
    ck_cpk_min,
    ck_cpk_max,
    ck_cpk_mean,
    ck_cpk_std,
    ck_mb_min,
    ck_mb_max,
    ck_mb_mean,
    ck_mb_std,
    ggt_min,
    ggt_max,
    ggt_mean,
    ggt_std,
    ld_ldh_min,
    ld_ldh_max,
    ld_ldh_mean,
    ld_ldh_std,
    CASE
        WHEN ie.stay_id in (
            SELECT *
            FROM sepsis
        ) THEN 1
        ELSE 0
    END AS sepsis
FROM mimiciv_icu.icustays ie
    LEFT JOIN cbc ON ie.stay_id = cbc.stay_id
    LEFT JOIN chem ON ie.stay_id = chem.stay_id
    LEFT JOIN diff ON ie.stay_id = diff.stay_id
    LEFT JOIN coag ON ie.stay_id = coag.stay_id
    LEFT JOIN enz ON ie.stay_id = enz.stay_id;