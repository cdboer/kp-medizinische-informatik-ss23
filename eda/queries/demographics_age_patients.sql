SELECT a.age::INTEGER, count(distinct a.subject_id) FROM mimiciv_hosp.patients p JOIN mimiciv_derived.age a on p.subject_id = a.subject_id GROUP BY a.age::INTEGER ORDER BY a.age::INTEGER asc;
