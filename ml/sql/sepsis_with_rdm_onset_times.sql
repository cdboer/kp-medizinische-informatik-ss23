DROP TABLE IF EXISTS mimiciv_derived.sepsis_with_rdm_onset_time;
CREATE TABLE mimiciv_derived.sepsis_with_rdm_onset_time AS 
SELECT 
cs.stay_id,
CASE WHEN s.sofa_time is null 
    THEN (SELECT (ie.intime + (s.sofa_time - ie2.intime)) as sofa_time from mimiciv_derived.cohort_selection cs
          JOIN mimiciv_derived.sepsis3 s on cs.stay_id = s.stay_id  
          JOIN mimiciv_icu.icustays ie2 on ie2.stay_id = cs.stay_id
		  where s.sofa_time is not null 
          AND ((s.sofa_time - ie2.intime) >= INTERVAL '8' hour)
          ORDER BY RANDOM() LIMIT 1
        ) 
    else s.sofa_time 
end,
CASE when s.sepsis3 is null then 0 else 1 end
FROM mimiciv_derived.cohort_selection cs
LEFT JOIN mimiciv_derived.sepsis3 s on s.stay_id = cs.stay_id
LEFT JOIN mimiciv_icu.icustays ie on ie.stay_id = cs.stay_id
;

