WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT 
	age.age,
	height.height, 
	weight.weight, 
    urine.urineoutput as urine_output,
    CASE WHEN rrt.dialysis_active IS NULL or rrt.dialysis_active = 0 THEN 0 ELSE 1 END AS rrt,
	CASE WHEN icu.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
FROM mimiciv_icu.icustays icu
LEFT JOIN mimiciv_derived.age age
ON icu.subject_id = age.subject_id
LEFT JOIN mimiciv_derived.height height
ON icu.stay_id = height.stay_id
LEFT JOIN mimiciv_derived.first_day_weight weight
ON icu.stay_id = weight.stay_id
LEFT JOIN mimiciv_derived.first_day_rrt rrt
ON icu.stay_id = rrt.stay_id
LEFT JOIN mimiciv_derived.first_day_urine_output urine
ON icu.stay_id = urine.stay_id