WITH
	all_patients AS (select count(*) from mimiciv_hosp.patients),
	icu_patients AS (select count(distinct subject_id) from mimiciv_icu.icustays),
	adults AS (select count(distinct subject_id) from mimiciv_derived.age where age >= 18),
	sepsis AS (select count(distinct subject_id) from mimiciv_derived.sepsis3),
	morethanonesepsis AS (select count(subject_id) from mimiciv_derived.sepsis3 
						  where subject_id in (
			SELECT one.subject_id from mimiciv_derived.sepsis3 one
			JOIN mimiciv_derived.sepsis3 two on two.subject_id = one.subject_id and one.stay_id <> two.stay_id
		)
	)
SELECT *
FROM all_patients, adults, icu_patients, sepsis, morethanonesepsis;
