SELECT 
    a.age::INTEGER, 
    count(DISTINCT a.subject_id) 
FROM mimiciv_hosp.patients p 
JOIN mimiciv_derived.age a 
ON p.subject_id = a.subject_id 
WHERE (p.subject_id IN (SELECT subject_id FROM mimiciv_icu.icustays)) 
GROUP BY a.age::INTEGER 
ORDER BY a.age::INTEGER ASC;