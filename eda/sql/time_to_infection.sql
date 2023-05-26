SELECT 
	s3.stay_id,
	cast (extract(epoch from s3.sofa_time - icu.intime)/3600 as integer) AS time_to_infection
FROM mimiciv_derived.sepsis3 s3
INNER JOIN mimiciv_icu.icustays icu
ON s3.stay_id = icu.stay_id
