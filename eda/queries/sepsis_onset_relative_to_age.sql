WITH sepsis as (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT 
	age.age::integer,
	height.height::integer, 
	weight.weight::integer, 
	CASE WHEN icu.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
FROM mimiciv_icu.icustays icu
JOIN mimiciv_derived.age age
ON icu.subject_id = age.subject_id
JOIN mimiciv_derived.height height
ON icu.stay_id = height.stay_id
JOIN mimiciv_derived.first_day_weight weight
ON icu.stay_id = weight.stay_id