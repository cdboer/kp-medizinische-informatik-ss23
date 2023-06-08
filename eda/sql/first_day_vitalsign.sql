/*
 Extracts the first day vitalsigns for each ICU stay.
 */
WITH sepsis AS (
    SELECT stay_id
    FROM mimiciv_derived.sepsis3
)
SELECT MIN(heart_rate) AS heart_rate_min,
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
    MIN(spo2) AS spo2_min,
    MAX(spo2) AS spo2_max,
    AVG(spo2) AS spo2_mean,
    STDDEV(spo2) AS spo2_std,
    MIN(glucose) AS glucose_min,
    MAX(glucose) AS glucose_max,
    AVG(glucose) AS glucose_mean,
    STDDEV(glucose) AS glucose_std,
    CASE
        WHEN ie.stay_id in (
            SELECT *
            FROM sepsis
        ) THEN 1
        ELSE 0
    END AS sepsis,
    AVG(w.weight) as weight_mean,
    AVG(w.weight_min) as weight_min,
    AVG(w.weight_max) as weight_max,
    AVG(h.height) as height,
    AVG(a.age) as age
FROM mimiciv_icu.icustays ie
    LEFT JOIN mimiciv_derived.vitalsign vs ON ie.subject_id = vs.subject_id
        AND vs.charttime >= ie.intime - INTERVAL '6' HOUR
        AND vs.charttime <= ie.intime + INTERVAL '1' DAY
    LEFT JOIN mimiciv_derived.first_day_weight w on ie.stay_id = w.stay_id
    LEFT JOIN mimiciv_derived.first_day_height h on ie.stay_id = h.stay_id
    LEFT JOIN mimiciv_derived.age a on ie.subject_id = a.subject_id
GROUP BY ie.subject_id,
    ie.stay_id;