WITH sepsis AS (SELECT subject_id FROM mimiciv_derived.sepsis3)
SELECT race, gender, CASE WHEN subject_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
FROM (
  SELECT p.subject_id, p.gender, a.age, adm.race, row_number() over (partition by p.subject_id) as rn
  FROM mimiciv_hosp.patients p
  JOIN mimiciv_derived.age a on p.subject_id = a.subject_id
  JOIN mimiciv_hosp.admissions adm on p.subject_id = adm.subject_id
  WHERE p.subject_id in (SELECT DISTINCT (subject_id) from mimiciv_icu.icustays)
) t
WHERE rn = 1;