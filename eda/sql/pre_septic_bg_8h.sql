-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
-- DROP TABLE IF EXISTS mimiciv_derived.pres_septic_bg; CREATE TABLE mimiciv_derived.pres_septic_bg AS
-- Highest/lowest blood gas values for all blood specimens, 
-- including venous/arterial/mixed
-- DROP TABLE mimiciv_derived.pre_septic_bg_4h; CREATE TABLE mimiciv_derived.pre_septic_bg_4h  AS

WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT
    MIN(lactate) AS lactate_min, MAX(lactate) AS lactate_max, AVG(lactate) AS lactate_mean, STDDEV(lactate) AS lactate_std
    , MIN(ph) AS ph_min, MAX(ph) AS ph_max, AVG(ph) AS ph_mean, STDDEV(ph) AS ph_std
    , MIN(so2) AS so2_min, MAX(so2) AS so2_max, AVG(so2) AS so2_mean, STDDEV(so2) AS so2_std
    , MIN(po2) AS po2_min, MAX(po2) AS po2_max, AVG(po2) AS po2_mean, STDDEV(po2) AS po2_std
    , MIN(pco2) AS pco2_min, MAX(pco2) AS pco2_max, AVG(pco2) AS pco2_mean, STDDEV(pco2) AS pco2_std
    , MIN(aado2) AS aado2_min, MAX(aado2) AS aado2_max, AVG(aado2) AS aado2_mean, STDDEV(aado2) AS aado2_std
    , MIN(aado2_calc) AS aado2_calc_min, MAX(aado2_calc) AS aado2_calc_max, AVG(aado2_calc) AS aado2_calc_mean, STDDEV(aado2_calc) AS aado2_calc_std
    , MIN(pao2fio2ratio) AS pao2fio2ratio_min
    , MAX(pao2fio2ratio) AS pao2fio2ratio_max, AVG(pao2fio2ratio) AS pao2fio2ratio_mean, STDDEV(pao2fio2ratio) AS pao2fio2ratio_std
    , MIN(baseexcess) AS baseexcess_min, MAX(baseexcess) AS baseexcess_max, AVG(baseexcess) AS baseexcess_mean, STDDEV(baseexcess) AS baseexcess_std
    , MIN(bicarbonate) AS bicarbonate_min, MAX(bicarbonate) AS bicarbonate_max, AVG(bicarbonate) AS bicarbonate_mean, STDDEV(bicarbonate) AS bicarbonate_std
    , MIN(totalco2) AS totalco2_min, MAX(totalco2) AS totalco2_max, AVG(totalco2) AS totalco2_mean, STDDEV(totalco2) AS totalco2_std
    , MIN(hematocrit) AS hematocrit_min, MAX(hematocrit) AS hematocrit_max, AVG(hematocrit) AS hematocrit_mean, STDDEV(hematocrit) AS hematocrit_std
    , MIN(hemoglobin) AS hemoglobin_min, MAX(hemoglobin) AS hemoglobin_max, AVG(hemoglobin) AS hemoglobin_mean, STDDEV(hemoglobin) AS hemoglobin_std
    , MIN(carboxyhemoglobin) AS carboxyhemoglobin_min
    , MAX(carboxyhemoglobin) AS carboxyhemoglobin_max, AVG(carboxyhemoglobin) AS carboxyhemoglobin_mean, STDDEV(carboxyhemoglobin) AS carboxyhemoglobin_std
    , MIN(methemoglobin) AS methemoglobin_min
    , MAX(methemoglobin) AS methemoglobin_max, AVG(methemoglobin) AS methemoglobin_mean, STDDEV(methemoglobin) AS methemoglobin_std
    , MIN(temperature) AS temperature_min, MAX(temperature) AS temperature_max, AVG(temperature) AS temperature_mean, STDDEV(temperature) AS temperature_std
    , MIN(chloride) AS chloride_min, MAX(chloride) AS chloride_max, AVG(chloride) AS chloride_mean, STDDEV(chloride) AS chloride_std
    , MIN(calcium) AS calcium_min, MAX(calcium) AS calcium_max, AVG(calcium) AS calcium_mean, STDDEV(calcium) AS calcium_std
    , MIN(glucose) AS glucose_min, MAX(glucose) AS glucose_max, AVG(glucose) AS glucose_mean, STDDEV(glucose) AS glucose_std
    , MIN(potassium) AS potassium_min, MAX(potassium) AS potassium_max, AVG(potassium) AS potassium_mean, STDDEV(potassium) AS potassium_std
    , MIN(sodium) AS sodium_min, MAX(sodium) AS sodium_max, AVG(sodium) AS sodium_mean, STDDEV(sodium) AS sodium_std
    , CASE WHEN ie.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis 
FROM mimiciv_icu.icustays ie
-- for all negative cases, define onset of sepsis as 8 hours after ICU. Since the mean onset interval is 6.98 hours, this might be a reasonable assumption.
-- for all positive cases, the sepsis onset is the sofa_time as recorded in the sepsis3 table
LEFT JOIN mimiciv_derived.sepsis3 sepsis
    ON ie.stay_id = sepsis.stay_id
LEFT JOIN mimiciv_derived.bg bg
    ON ie.subject_id = bg.subject_id
        AND bg.charttime >= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime ELSE sepsis.sofa_time - INTERVAL '8' HOUR END)
        AND bg.charttime <= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '8' HOUR ELSE sepsis.sofa_time END)
GROUP BY ie.subject_id, ie.stay_id
