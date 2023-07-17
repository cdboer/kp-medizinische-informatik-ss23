-- DROP TABLE IF EXISTS mimiciv_derived.pre_septic_lab_24h; CREATE TABLE mimiciv_derived.pre_septic_lab_24h  AS
WITH 
sepsis AS (SELECT stay_id, sofa_time FROM mimiciv_derived.sepsis3)


, bga as (
        /*
    Extracts MIN, MAX, MEAN, STD blood gas measurements for all patients for a given window size (Parameter: window_size_h).
    The window is defined as X hours before sepsis onset for septic patients, and X hours after ICU admission for non-septic patients.
    We use the sepsis3 sofa_time as the sepsis onset time for septic patients, and the ICU intime for non-septic patients.
    
    NOTE: When we talk about patients, what we really mean is ICU stays. Patients can have multiple ICU stays as evidenced by the icustays table.
    */
    WITH sepsis AS (
        SELECT stay_id
        FROM mimiciv_derived.sepsis3
    )
    SELECT 
        MIN(so2) AS so2_min,
        MAX(so2) AS so2_max,
        AVG(so2) AS so2_mean,
        STDDEV(so2) AS so2_std,
       
        MIN(aado2_calc) AS aado2_calc_min,
        MAX(aado2_calc) AS aado2_calc_max,
        AVG(aado2_calc) AS aado2_calc_mean,
        STDDEV(aado2_calc) AS aado2_calc_std,
       
        MIN(hematocrit) AS hematocrit_min,
        MAX(hematocrit) AS hematocrit_max,
        AVG(hematocrit) AS hematocrit_mean,
        STDDEV(hematocrit) AS hematocrit_std,
        MIN(hemoglobin) AS hemoglobin_min,
        MAX(hemoglobin) AS hemoglobin_max,
        AVG(hemoglobin) AS hemoglobin_mean,
        STDDEV(hemoglobin) AS hemoglobin_std,
      
        MIN(chloride) AS chloride_min,
        MAX(chloride) AS chloride_max,
        AVG(chloride) AS chloride_mean,
        STDDEV(chloride) AS chloride_std,
        
        MIN(lactate) AS lactate_min,
        MAX(lactate) AS lactate_max,
        AVG(lactate) AS lactate_mean,
        STDDEV(lactate) AS lactatee_std,

        MIN(totalco2) AS totalco2_min,
        MAX(totalco2) AS totalco2_max,
        AVG(totalco2) AS totalco2_mean,
        STDDEV(totalco2) AS totalco2_std,

        MIN(ph) AS ph_min,
        MAX(ph) AS ph_max,
        AVG(ph) AS ph_mean,
        STDDEV(ph) AS ph_std,

        
		cs.stay_id
    FROM mimiciv_derived.cohort_selection cs
        LEFT JOIN mimiciv_derived.sepsis3 sepsis ON cs.stay_id = sepsis.stay_id
        LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
        LEFT JOIN mimiciv_derived.bg bg ON cs.subject_id = bg.subject_id
        AND bg.charttime >= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN srt.sofa_time - INTERVAL '%(window_size_h)s'
                ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            END
        )
        AND bg.charttime <= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN srt.sofa_time - INTERVAL '%(window_stop_size_h)s'  HOUR
                ELSE sepsis.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
            END
        )
    GROUP BY cs.subject_id,
        cs.stay_id
)

, cbc AS (
    SELECT
        cs.stay_id
       
        , MIN(platelet) AS platelets_min
        , MAX(platelet) AS platelets_max
        , AVG(platelet) AS platelets_avg
        , STDDEV(platelet) AS platelets_std
       
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN sepsis
        ON cs.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.complete_blood_count le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR ELSE srt.sofa_time - INTERVAL '%(window_size_h)s' END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR ELSE srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR END

    
    GROUP BY cs.stay_id
)

, chem AS (
    SELECT
        cs.stay_id
        , MIN(albumin) AS albumin_min, MAX(albumin) AS albumin_max
        , AVG(albumin) AS albumin_mean, STDDEV(albumin) AS albumin_std
       
        , MIN(bicarbonate) AS bicarbonate_min
        , MAX(bicarbonate) AS bicarbonate_max
        , AVG(bicarbonate) as bicarbonate_avg, STDDEV(bicarbonate) as bicarbonate_std
        , MIN(bun) AS bun_min, MAX(bun) AS bun_max
        , AVG(bun) as bun_avg, STDDEV(bun) as bun_std
        , MIN(calcium) AS calcium_min, MAX(calcium) AS calcium_max
        , AVG(calcium) AS calcium_avg, STDDEV(calcium) AS calcium_std
       
        , MIN(sodium) AS sodium_min, MAX(sodium) AS sodium_max
        , AVG(sodium) AS sodium_avg, STDDEV(sodium) AS sodium_std
        , MIN(potassium) AS potassium_min, MAX(potassium) AS potassium_max
        , AVG(potassium) AS potassium_avg, STDDEV(potassium) AS potassium_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN sepsis
        ON cs.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.chemistry le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR ELSE srt.sofa_time - INTERVAL '%(window_size_h)s' END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR ELSE srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR END
    GROUP BY cs.stay_id
)

, diff AS (
    SELECT
        cs.stay_id
       
        , MIN(neutrophils_abs) AS abs_neutrophils_min
        , MAX(neutrophils_abs) AS abs_neutrophils_max
        , AVG(neutrophils_abs) AS abs_neutrophils_avg
        , STDDEV(neutrophils_abs) AS abs_neutrophils_std
        
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN sepsis
        ON cs.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.blood_differential le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR ELSE srt.sofa_time - INTERVAL '%(window_size_h)s' END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR ELSE srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR END
    GROUP BY cs.stay_id
)

, gcs as (
        WITH sepsis AS (SELECT stay_id, sofa_time as sepsis_onset FROM mimiciv_derived.sepsis3)
    SELECT 
        MAX(gcs.gcs_motor) as gcs_motor_max,
        MIN(gcs.gcs_motor) as gcs_motor_min,
        AVG(gcs.gcs_motor) as gcs_motor_avg,
        STDDEV(gcs.gcs_motor) as gcs_motor_stddev,
        MAX(gcs.gcs_verbal) as gcs_verbal_max,
        MIN(gcs.gcs_verbal) as gcs_verbal_min,
        AVG(gcs.gcs_verbal) as gcs_verbal_avg,
        STDDEV(gcs.gcs_verbal) as gcs_verbal_stddev,
        MAX(gcs.gcs_eyes) as gcs_eyes_max,
        MIN(gcs.gcs_eyes) as gcs_eyes_min,
        AVG(gcs.gcs_eyes) as gcs_eyes_avg,
        STDDEV(gcs.gcs_eyes) as gcs_eyes_stddev,
        (MAX(gcs.gcs_motor) + MAX(gcs.gcs_verbal) + MAX(gcs.gcs_eyes)) AS gcs_total_max,
        (MIN(gcs.gcs_motor) + MIN(gcs.gcs_verbal) + MIN(gcs.gcs_eyes)) AS gcs_total_min,
        (AVG(gcs.gcs_motor) + AVG(gcs.gcs_verbal) + AVG(gcs.gcs_eyes)) AS gcs_total_avg,
        (STDDEV(gcs.gcs_motor) + STDDEV(gcs.gcs_verbal) + STDDEV(gcs.gcs_eyes)) AS gcs_total_stddev,
		cs.stay_id
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis3 sepsis
        ON cs.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.gcs gcs
        ON cs.subject_id = gcs.subject_id
            AND gcs.charttime >= (CASE WHEN sepsis.sofa_time IS NULL THEN srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR END)
            AND gcs.charttime <= (CASE WHEN sepsis.sofa_time IS NULL THEN srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR ELSE sepsis.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR END)
    GROUP BY cs.subject_id, cs.stay_id
)

, lab as (
    WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
    SELECT
    MIN(heart_rate) AS heart_rate_min
    , MAX(heart_rate) AS heart_rate_max
    , AVG(heart_rate) AS heart_rate_mean
    , STDDEV(heart_rate) AS heart_rate_std
    , MIN(sbp) AS sbp_min
    , MAX(sbp) AS sbp_max
    , AVG(sbp) AS sbp_mean
    , STDDEV(sbp) AS sbp_std
    , MIN(dbp) AS dbp_min
    , MAX(dbp) AS dbp_max
    , AVG(dbp) AS dbp_mean
    , STDDEV(dbp) AS dbp_std
    , MIN(mbp) AS mbp_min
    , MAX(mbp) AS mbp_max
    , AVG(mbp) AS mbp_mean
    , STDDEV(mbp) AS mbp_std
    , MIN(resp_rate) AS resp_rate_min
    , MAX(resp_rate) AS resp_rate_max
    , AVG(resp_rate) AS resp_rate_mean
    , STDDEV(resp_rate) AS resp_rate_std
    , MIN(temperature) AS temperature_min
    , MAX(temperature) AS temperature_max
    , AVG(temperature) AS temperature_mean
    , STDDEV(temperature) AS temperature_std

    , CASE WHEN cs.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
	, cs.stay_id
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis3 sepsis
        ON cs.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.vitalsign vs
        ON cs.subject_id = vs.subject_id
        -- pre septic window defined as 24 hours before sepsis onset
        -- if no sepsis onset, then 24 hours after ICU admission to get the same window size
        -- resolution could be improved ..
            AND vs.charttime >= (CASE WHEN sepsis.sofa_time IS NULL THEN srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR ELSE sepsis.sofa_time - INTERVAL '%(window_size_h)s' HOUR END)
            AND vs.charttime <= (CASE WHEN sepsis.sofa_time IS NULL THEN srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR ELSE sepsis.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR END)
    GROUP BY cs.subject_id, cs.stay_id
)
SELECT
    cs.subject_id
    --, cs.stay_id
    -- complete blood count
	, lab.*
    , cbc.*
    , chem.*
    , diff.*
    , gcs.*
    , bga.*
FROM mimiciv_derived.cohort_selection cs
LEFT JOIN cbc
    ON cs.stay_id = cbc.stay_id
LEFT JOIN chem
    ON cs.stay_id = chem.stay_id
LEFT JOIN diff
    ON cs.stay_id = diff.stay_id
Left Join lab
	on cs.stay_id = lab.stay_id
LEFT JOIN gcs
    on cs.stay_id = gcs.stay_id
LEFT JOIN bga
    on cs.stay_id = bga.stay_id
;