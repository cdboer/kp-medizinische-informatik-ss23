DROP TABLE IF EXISTS mimiciv_derived.sepsis_with_rdm_onset_time;
CREATE TABLE mimiciv_derived.sepsis_with_rdm_onset_time AS 
SELECT 
cs.stay_id,
CASE 
    WHEN s.sofa_time IS NULL THEN 
        (
            SELECT (ie.intime + (ss.sofa_time - ie2.intime)) 
            FROM mimiciv_derived.sepsis3 ss
            JOIN mimiciv_icu.icustays ie2 on ss.stay_id = ie2.stay_id
            WHERE ss.sofa_time IS NOT NULL 
            AND (ss.sofa_time - ie2.intime) <= (ie.outtime - ie.intime)
            AND (ss.sofa_time - ie2.intime) >= INTERVAL '%(window_size_h)' hour
            ORDER BY RANDOM() 
            LIMIT 1
        ) 
    ELSE s.sofa_time 
END as sofa_time,
CASE 
    WHEN s.sepsis3 IS NULL THEN 0 
    ELSE 1 
END as sepsis3
FROM mimiciv_derived.cohort_selection cs
LEFT JOIN mimiciv_derived.sepsis3 s ON s.stay_id = cs.stay_id
LEFT JOIN mimiciv_icu.icustays ie ON ie.stay_id = cs.stay_id
;

