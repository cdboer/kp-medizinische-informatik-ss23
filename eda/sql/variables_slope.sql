-- DROP TABLE IF EXISTS mimiciv_derived.pre_septic_lab_24h; CREATE TABLE mimiciv_derived.pre_septic_lab_24h  AS
WITH 

lab as (
SELECT
	cs.stay_id,
	regr_slope(heart_rate, EXTRACT(EPOCH FROM charttime)/60) AS heart_rate_slope,
	regr_slope(sbp, EXTRACT (EPOCH FROM charttime)/60) AS sbp_slope,
    regr_slope(dbp, EXTRACT (EPOCH FROM charttime)/60) AS dbp_slope,
    regr_slope(mbp, EXTRACT (EPOCH FROM charttime)/60) AS mbp_slope,
    regr_slope(resp_rate, EXTRACT (EPOCH FROM charttime)/60) AS resp_rate_slope,
    regr_slope(temperature, EXTRACT (EPOCH FROM charttime)/60) AS temperature_slope,
	MAX(srt.sepsis3) as sepsis
FROM mimiciv_derived.cohort_selection cs
LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
on cs.stay_id = srt.stay_id
LEFT JOIN mimiciv_derived.vitalsign vs
ON cs.subject_id = vs.subject_id
    --AND vs.charttime >= srt.sofa_time - INTERVAL '8' HOUR
    --AND vs.charttime < srt.sofa_time - INTERVAL '2' HOUR
    AND vs.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
    AND vs.charttime < srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
GROUP BY cs.subject_id, cs.stay_id
)
SELECT
    cs.subject_id
    --, cs.stay_id
    -- complete blood count
	, lab.*
FROM mimiciv_derived.cohort_selection cs
Left Join lab
	on cs.stay_id = lab.stay_id
;