SELECT a.age::INTEGER, count(distinct a.subject_id)
FROM mimiciv_hosp.patients p
JOIN mimiciv_derived.age a on p.subject_id = a.subject_id
--WHERE (p.subject_id in (select subject_id from mimiciv_icu.icustays))
GROUP BY a.age::INTEGER                                                    
ORDER BY a.age::INTEGER asc;