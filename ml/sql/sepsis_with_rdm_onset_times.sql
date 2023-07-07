DROP TABLE IF EXISTS mimiciv_derived.sepsis_with_rdm_onset_time;
CREATE TABLE mimiciv_derived.sepsis_with_rdm_onset_time(
    stay_id int not null primary key,
    sofa_time datetime not null,
    sepsis int not null,
) AS 
SELECT 
stay_id, 
CASE WHEN s.sofa_time is null 
THEN (SELECT sofa_time from mimiciv_derived.sepsis where sofa_time is not null AND ie.outtime > sofa_time) 
else s.sofa_time end,
CASE when s.sepsis is null then 0 else 1 end
FROM mimiciv_icu.icustays ie
LEFT JOIN mimiciv_derived.sepsis s on s.stay_id = ie.stay_id
;

