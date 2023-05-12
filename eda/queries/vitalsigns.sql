SELECT charttime, heart_rate, sbp, dbp, mbp, sbp_ni, dbp_ni, mbp_ni, resp_rate, temperature, spo2, glucose
FROM 
	mimiciv_derived.vitalsign
WHERE subject_id = 16534814
LIMIT 100