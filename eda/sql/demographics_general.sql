WITH sepsis AS (
    SELECT stay_id
    FROM mimiciv_derived.sepsis3
)
SELECT adm.race,
    pat.gender,
    adm.marital_status,
    adm.insurance,
    age.age,
    CASE
        WHEN stay_id in (
            SELECT *
            FROM sepsis
        ) THEN 1
        ELSE 0
    END AS sepsis
FROM mimiciv_icu.icustays icu
    JOIN mimiciv_hosp.admissions adm ON icu.hadm_id = adm.hadm_id
    JOIN mimiciv_hosp.patients pat ON icu.subject_id = pat.subject_id
    LEFT JOIN mimiciv_derived.age age ON icu.hadm_id = age.hadm_id