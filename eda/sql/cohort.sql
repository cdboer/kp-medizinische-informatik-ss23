WITH 
    adults AS (select subject_id from mimiciv_derived.age where age >= 18),
    sepsis AS (select distinct subject_id from mimiciv_derived.sepsis3),
    first_icu_stay AS (select subject_id from mimiciv_derived.icustay_detail where first_icu_stay),
    min_24h AS (select subject_id from mimiciv_derived.icustay_detail where (icu_outtime - icu_intime) >= '24:00:00' and first_icu_stay)
SELECT
    patients.subject_id
FROM
    mimiciv_hosp.patients patients
WHERE
    patients.subject_id in (select subject_id from adults) and
    patients.subject_id in (select subject_id from sepsis) and
    patients.subject_id in (select subject_id from min_24h) and
    patients.subject_id in (select subject_id from first_icu_stay)
