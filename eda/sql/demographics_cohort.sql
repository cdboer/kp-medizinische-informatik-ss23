SELECT stay.stay_id, stay.sepsis3 as sepsis, age.age, adm.race, pat.gender, (stay.sofa_time - icu.intime) as time_to_onset
FROM mimiciv_derived.sepsis_with_rdm_onset_time stay
JOIN mimiciv_icu.icustays icu ON icu.stay_id = stay.stay_id
JOIN mimiciv_hosp.admissions adm ON icu.hadm_id = adm.hadm_id
JOIN mimiciv_hosp.patients pat ON pat.subject_id = adm.subject_id
JOIN mimiciv_derived.age age ON icu.hadm_id = age.hadm_id
