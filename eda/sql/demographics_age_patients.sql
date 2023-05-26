SELECT age, gender
FROM (
	SELECT p.subject_id, a.age, p.gender, row_number() over (partition by p.subject_id order by a.age) as rn
	FROM mimiciv_hosp.patients p
	JOIN mimiciv_derived.age a on p.subject_id = a.subject_id
) t WHERE rn = 1