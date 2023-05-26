-- only include patients that have been in the ICU
SELECT age, gender FROM (
	SELECT icu.subject_id, a.age, p.gender, row_number() over (partition by icu.subject_id order by a.age) as rn
	FROM mimiciv_icu.icustays icu
	JOIN mimiciv_derived.age a on icu.subject_id = a.subject_id
	JOIN mimiciv_hosp.patients p on icu.subject_id = p.subject_id
) t WHERE rn = 1