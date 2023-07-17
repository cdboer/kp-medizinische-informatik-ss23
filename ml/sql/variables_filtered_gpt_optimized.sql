CREATE INDEX idx_icustays_stay_id ON mimiciv_icu.icustays (stay_id);
CREATE INDEX idx_icustays_subject_id ON mimiciv_icu.icustays (subject_id);

CREATE INDEX idx_bg_subject_id_charttime ON mimiciv_derived.bg (subject_id, charttime);
CREATE INDEX idx_complete_blood_count_subject_id_charttime ON mimiciv_derived.complete_blood_count (subject_id, charttime);
CREATE INDEX idx_chemistry_subject_id_charttime ON mimiciv_derived.chemistry (subject_id, charttime);
CREATE INDEX idx_blood_differential_subject_id_charttime ON mimiciv_derived.blood_differential (subject_id, charttime);
CREATE INDEX idx_gcs_subject_id_charttime ON mimiciv_derived.gcs (subject_id, charttime);
CREATE INDEX idx_vitalsign_subject_id_charttime ON mimiciv_derived.vitalsign (subject_id, charttime);

-- Optimize and rewrite the query
SELECT
    ie.subject_id,
    lab.*,
    cbc.*,
    chem.*,
    diff.*,
    gcs.*,
    bga.*
FROM
    mimiciv_icu.icustays ie
LEFT JOIN (
    SELECT
        stay_id,
        MIN(heart_rate) AS heart_rate_min,
        MAX(heart_rate) AS heart_rate_max,
        AVG(heart_rate) AS heart_rate_mean,
        STDDEV(heart_rate) AS heart_rate_std,
        MIN(sbp) AS sbp_min,
        MAX(sbp) AS sbp_max,
        AVG(sbp) AS sbp_mean,
        STDDEV(sbp) AS sbp_std,
        MIN(dbp) AS dbp_min,
        MAX(dbp) AS dbp_max,
        AVG(dbp) AS dbp_mean,
        STDDEV(dbp) AS dbp_std,
        MIN(mbp) AS mbp_min,
        MAX(mbp) AS mbp_max,
        AVG(mbp) AS mbp_mean,
        STDDEV(mbp) AS mbp_std,
        MIN(resp_rate) AS resp_rate_min,
        MAX(resp_rate) AS resp_rate_max,
        AVG(resp_rate) AS resp_rate_mean,
        STDDEV(resp_rate) AS resp_rate_std,
        MIN(temperature) AS temperature_min,
        MAX(temperature) AS temperature_max,
        AVG(temperature) AS temperature_mean,
        STDDEV(temperature) AS temperature_std,
        CASE WHEN ie.stay_id IN (SELECT stay_id FROM mimiciv_derived.sepsis3) THEN 1 ELSE 0 END AS sepsis
    FROM
        mimiciv_icu.icustays ie
    LEFT JOIN mimiciv_derived.vitalsign vs ON ie.subject_id = vs.subject_id
        AND vs.charttime >= (
            CASE
                WHEN (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) IS NULL THEN
                    (SELECT sofa_time FROM mimiciv_derived.sepsis_with_rdm_onset_time WHERE stay_id = ie.stay_id) - INTERVAL '%(window_size_h)s' HOUR
                ELSE
                    (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND vs.charttime <= (
            CASE
                WHEN (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) IS NULL THEN
                    (SELECT sofa_time FROM mimiciv_derived.sepsis_with_rdm_onset_time WHERE stay_id = ie.stay_id) - INTERVAL '%(window_stop_size_h)s' HOUR
                ELSE
                    (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) - INTERVAL '%(window_stop_size_h)s' HOUR
            END
        )
    GROUP BY
        ie.stay_id
) lab ON ie.stay_id = lab.stay_id
LEFT JOIN (
    SELECT
        stay_id,
        MIN(platelet) AS platelets_min,
        MAX(platelet) AS platelets_max,
        AVG(platelet) AS platelets_avg,
        STDDEV(platelet) AS platelets_std
    FROM
        mimiciv_icu.icustays ie
    LEFT JOIN mimiciv_derived.complete_blood_count le ON le.subject_id = ie.subject_id
        AND le.charttime >= (
            CASE
                WHEN (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) IS NOT NULL THEN
                    (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) - INTERVAL '%(window_size_h)s' HOUR
                ELSE
                    (SELECT sofa_time FROM mimiciv_derived.sepsis_with_rdm_onset_time WHERE stay_id = ie.stay_id) - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND le.charttime <= (
            CASE
                WHEN (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) IS NOT NULL THEN
                    (SELECT sofa_time FROM mimiciv_derived.sepsis3 WHERE stay_id = ie.stay_id) - INTERVAL '%(window_stop_size_h)s' HOUR
                ELSE
                    (SELECT sofa_time FROM mimiciv_derived.sepsis_with_rdm_onset_time WHERE stay_id = ie.stay_id) - INTERVAL '%(window_stop_size_h)s' HOUR
            END
        )
    GROUP BY
        ie.stay_id
) cbc ON ie.stay_id = cbc.stay_id
LEFT JOIN (
    SELECT
        stay_id,
        MIN(albumin) AS albumin_min,
        MAX(albumin) AS albumin_max,
        AVG(albumin) AS albumin_mean,
        STDDEV(albumin) AS albumin_std,
        MIN(bicarbonate) AS bicarbonate_min,
        MAX(bicarbonate) AS bicarbonate_max,
        AVG(bicarbonate) AS bicarbonate_avg,
        STDDEV(bicarbonate) AS bicarbonate_std,
        MIN(bun) AS bun_min,
        MAX(bun) AS bun_max,
        AVG(bun) AS bun_avg,
        STDDEV(bun) AS bun_std,
        MIN(calcium) AS calcium_min,
        MAX(calcium) AS calcium_max,
        AVG(calcium) AS calcium_avg,
        STDDEV(calcium) AS calcium_std,
        MIN(sodium) AS sodium_min,
        MAX(sodium) AS sodium_max,
        AVG(sodium) AS sodium_avg,
        STDDEV(sodium) AS sodium_std,
        MIN(potassium) AS potassium_min,
        MAX(potassium) AS potassium_max,
        AVG(potassium) AS potassium_avg,
        STDDEV(potassium) AS potassium_std
    FROM
        mimiciv_icu.icustays ie
    LEFT JOIN
