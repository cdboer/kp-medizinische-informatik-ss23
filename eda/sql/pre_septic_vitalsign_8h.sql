-- DROP TABLE IF EXISTS mimiciv_derived.pre_septic_vitalsign; CREATE TABLE mimiciv_derived.pre_septic_vitalsign AS
-- This query pivots vital signs and aggregates them
-- for the first 8 hours of a patient's stay or 8 hours before sepsis onset, depending on whether the patient developed sepsis during their stay
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
GROUP BY ie.subject_id, ie.stay_id;