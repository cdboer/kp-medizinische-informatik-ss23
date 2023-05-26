-- ICU Stays with their GCS values for the first day
WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT 
	gcs.gcs_min,
	gcs.gcs_motor,
	gcs.gcs_verbal,
	gcs.gcs_eyes,
    (gcs.gcs_motor + gcs.gcs_verbal + gcs.gcs_eyes) AS gcs_total,
	gcs.gcs_unable,
	CASE WHEN icu.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
FROM mimiciv_icu.icustays icu
LEFT JOIN mimiciv_derived.first_day_gcs gcs
ON icu.stay_id = gcs.stay_id
-- WHERE (gcs.gcs_motor + gcs.gcs_eyes + gcs.gcs_verbal) != 15 or gcs.gcs_unable = 0
