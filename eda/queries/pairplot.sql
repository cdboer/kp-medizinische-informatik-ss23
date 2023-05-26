-- All icu stay_id's with a target variable that denotes whether they developed a sepsis during their icu stay.

-- We need to join the icustays table with the patients table to get
WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT 
	age.age,
	height.height, 
	weight.weight, 
	-- vs.heart_rate_min, 
	-- vs.heart_rate_max, 
	-- vs.heart_rate_mean,
	-- vs.sbp_min,
	-- vs.sbp_max,
	-- vs.sbp_mean,
	-- vs.dbp_min,
	-- vs.dbp_max,
	-- vs.dbp_mean,
	-- vs.mbp_min,
	-- vs.mbp_max,
	-- vs.mbp_mean,
	-- vs.temperature_min,
	-- vs.temperature_max,
	-- vs.temperature_mean,
	-- vs.spo2_min,
	-- vs.spo2_max,
	-- vs.spo2_mean,
	-- vs.glucose_min,
	-- vs.glucose_max,
	-- vs.glucose_mean,
	-- vs.resp_rate_min,
	-- vs.resp_rate_max,
	-- vs.resp_rate_mean,
	urine.urineoutput,
	bg.lactate_min,
	bg.lactate_max,
	bg.ph_min,
	bg.ph_max,
	bg.so2_min,
	bg.so2_max,
	bg.po2_min,
	bg.po2_max,
	bg.pco2_min,
	bg.pco2_max,
	bg.aado2_min,
	bg.aado2_max,
	bg.aado2_calc_min,
	bg.aado2_calc_max,
	bg.pao2fio2ratio_min,
	bg.pao2fio2ratio_max,
	bg.baseexcess_min,
	bg.baseexcess_max,
	bg.bicarbonate_min,
	bg.bicarbonate_max,
	bg.totalco2_min,
	bg.totalco2_max,
	bg.hematocrit_min,
	bg.hematocrit_max,
	bg.hemoglobin_min,
	bg.hemoglobin_max,
	bg.carboxyhemoglobin_min,
	bg.carboxyhemoglobin_max,
	bg.methemoglobin_min,
	bg.methemoglobin_max,
	bg.chloride_min,
	bg.chloride_max,
	bg.calcium_min,
	bg.calcium_max,
	bg.potassium_min,
	bg.potassium_max,
	bg.sodium_min,
	bg.sodium_max,
	CASE WHEN icu.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
FROM mimiciv_icu.icustays icu
LEFT JOIN mimiciv_derived.age age
ON icu.subject_id = age.subject_id
LEFT JOIN mimiciv_derived.height height
ON icu.stay_id = height.stay_id
LEFT JOIN mimiciv_derived.first_day_weight weight
ON icu.stay_id = weight.stay_id
LEFT JOIN mimiciv_derived.first_day_vitalsign vs
ON icu.stay_id = vs.stay_id
LEFT JOIN mimiciv_derived.first_day_urine_output urine 
ON icu.stay_id = urine.stay_id
LEFT JOIN mimiciv_derived.first_day_bg bg
ON icu.stay_id = bg.stay_id
LEFT JOIN mimiciv_derived.first_day_gcs gcs
ON icu.stay_id = gcs.stay_id