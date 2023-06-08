WITH sepsis AS (SELECT stay_id, sofa_time as sepsis_onset FROM mimiciv_derived.sepsis3)
SELECT 
    MAX(gcs.gcs_motor) as gcs_motor_max,
    MIN(gcs.gcs_motor) as gcs_motor_min,
    AVG(gcs.gcs_motor) as gcs_motor_avg,
    STDDEV(gcs.gcs_motor) as gcs_motor_stddev,
    MAX(gcs.gcs_verbal) as gcs_verbal_max,
    MIN(gcs.gcs_verbal) as gcs_verbal_min,
    AVG(gcs.gcs_verbal) as gcs_verbal_avg,
    STDDEV(gcs.gcs_verbal) as gcs_verbal_stddev,
    MAX(gcs.gcs_eyes) as gcs_eyes_max,
    MIN(gcs.gcs_eyes) as gcs_eyes_min,
    AVG(gcs.gcs_eyes) as gcs_eyes_avg,
    STDDEV(gcs.gcs_eyes) as gcs_eyes_stddev,
    (MAX(gcs.gcs_motor) + MAX(gcs.gcs_verbal) + MAX(gcs.gcs_eyes)) AS gcs_total_max,
    (MIN(gcs.gcs_motor) + MIN(gcs.gcs_verbal) + MIN(gcs.gcs_eyes)) AS gcs_total_min,
    (AVG(gcs.gcs_motor) + AVG(gcs.gcs_verbal) + AVG(gcs.gcs_eyes)) AS gcs_total_avg,
    (STDDEV(gcs.gcs_motor) + STDDEV(gcs.gcs_verbal) + STDDEV(gcs.gcs_eyes)) AS gcs_total_stddev,
    CASE WHEN ie.stay_id in (SELECT stay_id FROM sepsis) THEN 1 ELSE 0 END AS sepsis
FROM mimiciv_icu.icustays ie
LEFT JOIN mimiciv_derived.sepsis3 sepsis
    ON ie.stay_id = sepsis.stay_id
LEFT JOIN mimiciv_derived.gcs gcs
    ON ie.subject_id = gcs.subject_id
        AND gcs.charttime >= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime ELSE sepsis.sofa_time - INTERVAL '4' HOUR END)
        AND gcs.charttime <= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '4' HOUR ELSE sepsis.sofa_time END)
GROUP BY ie.subject_id, ie.stay_id