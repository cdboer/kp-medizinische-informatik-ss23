/*
For round 3 of the reviews of the paper, we try smaller feature numbers.
For this query, a threshold of 0.2 for the pearson correlation has been used, so this query returns 11 columns:
metas_std              0.477263
ld_ldh_std             0.413667
abs_neutrophils_std    0.285801
globulin_min           0.226008
globulin_avg           0.225360
globulin_max           0.224320
atyps_std              0.204782
bands_std             -0.204830
thrombin_min          -0.286329
thrombin_max          -0.286329
thrombin_avg          -0.286329

Extracts MIN, MAX, MEAN, STD blood gas measurements for all patients for a given window size (Parameter: window_size_h).
    The window is defined as X hours before sepsis onset for septic patients, and X hours after ICU admission for non-septic patients.
    We use the sepsis3 sofa_time as the sepsis onset time for septic patients, and the ICU intime for non-septic patients.
    
    NOTE: When we talk about patients, what we really mean is ICU stays. Patients can have multiple ICU stays as evidenced by the icustays table.
    
*/

WITH 
diff AS (
    SELECT
        cs.stay_id
        , STDDEV(neutrophils_abs) AS abs_neutrophils_std
        , STDDEV(metamyelocytes) AS metas_std
        , STDDEV(atypical_lymphocytes) AS atyps_std
        , STDDEV(bands) AS bands_std
        
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.blood_differential le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)

, coag AS (
    SELECT
        cs.stay_id

        , MIN(thrombin) AS thrombin_min
        , MAX(thrombin) AS thrombin_max
        , AVG(thrombin) AS thrombin_avg
        /*, STDDEV(thrombin) AS thrombin_std*/

    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.coagulation le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)

, enz AS (
    SELECT
        cs.stay_id

        , STDDEV(ld_ldh) AS ld_ldh_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
        on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.enzyme le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)


, lab as (
    SELECT

    MAX(srt.sepsis3) as sepsis
	, cs.stay_id
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.vitalsign vs
        ON cs.subject_id = vs.subject_id
            AND vs.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND vs.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.subject_id, cs.stay_id
)


, chem AS (
    SELECT
        cs.stay_id
        , MIN(globulin) AS globulin_min
        , MAX(globulin) AS globulin_max
        , AVG(globulin) as globulin_avg
        , STDDEV(globulin) AS globulin_std
    FROM mimiciv_derived.cohort_selection cs
    LEFT JOIN mimiciv_derived.sepsis_with_rdm_onset_time srt
            on cs.stay_id = srt.stay_id
    LEFT JOIN mimiciv_derived.chemistry le
        ON le.subject_id = cs.subject_id
            AND le.charttime >= srt.sofa_time - INTERVAL '%(window_size_h)s' HOUR
            AND le.charttime <= srt.sofa_time - INTERVAL '%(window_stop_size_h)s' HOUR
    GROUP BY cs.stay_id
)

SELECT
    cs.subject_id
    , diff.*
    , lab.*
    , coag.*
    , enz.*
    , chem.*
FROM mimiciv_derived.cohort_selection cs
LEFT JOIN diff
    ON cs.stay_id = diff.stay_id
left join enz
    on cs.stay_id = enz.stay_id
left join coag
    on cs.stay_id = coag.stay_id
left join lab
    on cs.stay_id = lab.stay_id
left join chem
    on cs.stay_id = chem.stay_id
;