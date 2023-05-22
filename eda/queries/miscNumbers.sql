WITH
	all_patients AS (select count(*) as all_patients from mimiciv_hosp.patients),
	icu_patients AS (select count(distinct subject_id) as icu_patients from mimiciv_icu.icustays),
	adults AS (select distinct subject_id from mimiciv_derived.age where age >= 18),
	adults_count AS (select count(distinct subject_id) as adults from mimiciv_derived.age where age >= 18),
	sepsis AS (select count(stay_id) as sepsis from mimiciv_derived.sepsis3 where subject_id in (select * from adults)),
	morethanonesepsis AS (select count(subject_id) as morethanonesepsis from mimiciv_derived.sepsis3 
						  where subject_id in (
			SELECT one.subject_id from mimiciv_derived.sepsis3 one
			JOIN mimiciv_derived.sepsis3 two on two.subject_id = one.subject_id and one.stay_id <> two.stay_id
		) and subject_id in (select * from adults)
	)
SELECT all_patients, adults_count, icu_patients, sepsis, (sepsis - morethanonesepsis) as single, morethanonesepsis
From all_patients, adults_count, icu_patients, sepsis, morethanonesepsis;
	
	