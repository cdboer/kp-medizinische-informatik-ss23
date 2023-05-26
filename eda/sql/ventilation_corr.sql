WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT 
    icu.stay_id,
    CASE 
        WHEN ARRAY['SupplementalOxygen', 'HFNC', 'NonInvasiveVent'] && array_agg(v.ventilation_status) THEN 1 
        ELSE 0 
    END AS non_invasive_vent,
    CASE 
        WHEN ARRAY['Tracheostomy', 'InvasiveVent'] && array_agg(v.ventilation_status) THEN 1 
        ELSE 0 
    END AS invasive_vent,
    (ARRAY[NULL] = array_agg(v.ventilation_status))::integer as no_ventilation,
    CASE WHEN icu.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
FROM mimiciv_icu.icustays icu
LEFT JOIN mimiciv_derived.ventilation v
ON icu.stay_id = v.stay_id
GROUP BY icu.stay_id