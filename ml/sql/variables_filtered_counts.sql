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
        COUNT(so2) AS so2_num,
        COUNT(aado2_calc) AS aado2_calc_num,
        COUNT(hematocrit) AS hematocrit_num,
        COUNT(hemoglobin) AS hemoglobin_num,
        COUNT(chloride) AS chloride_num,
		ie.stay_id
    FROM mimiciv_icu.icustays ie
        LEFT JOIN mimiciv_derived.sepsis3 sepsis ON ie.stay_id = sepsis.stay_id
        LEFT JOIN mimiciv_derived.bg bg ON ie.subject_id = bg.subject_id
        AND bg.charttime >= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime
                ELSE sepsis.sofa_time - INTERVAL '24' HOUR
            END
        )
        AND bg.charttime <= (
            CASE
                WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '24' HOUR
                ELSE sepsis.sofa_time
            END
        )
    GROUP BY ie.subject_id,
        ie.stay_id
    )

, cbc AS (
    SELECT
        ie.stay_id,
        COUNT(platelet) AS platelets_num
       
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.complete_blood_count le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '24' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '24' HOUR END
    GROUP BY ie.stay_id
)

, chem AS (
    SELECT
        ie.stay_id,
        COUNT(albumin) AS albumin_num,
        COUNT(bicarbonate) AS bicarbonate_num,
        COUNT(bun) AS bun_num,
        COUNT(calcium) AS calcium_num,
        COUNT(chloride) AS chloride_num,
        COUNT(potassium) AS potassium_num
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.chemistry le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '24' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '24' HOUR END
    GROUP BY ie.stay_id
)

, diff AS (
    SELECT
        ie.stay_id,
        COUNT(neutrophils_abs) AS abs_neutrophils_num
    FROM mimiciv_icu.icustays ie
    LEFT JOIN sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.blood_differential le
        ON le.subject_id = ie.subject_id
            AND le.charttime >= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time - INTERVAL '24' HOUR ELSE ie.intime END
            AND le.charttime <= CASE WHEN sepsis.sofa_time IS NOT NULL THEN sepsis.sofa_time ELSE ie.intime + INTERVAL '24' HOUR END
    GROUP BY ie.stay_id
)



, gcs as (
        WITH sepsis AS (SELECT stay_id, sofa_time as sepsis_onset FROM mimiciv_derived.sepsis3)
    SELECT 
        COUNT(gcs.gcs_motor) as gcs_motor_num,
        COUNT(gcs.gcs_verbal) as gcs_verbal_num,
        COUNT(gcs.gcs_eyes) as gcs_eyes_num,
		ie.stay_id
    FROM mimiciv_icu.icustays ie
    LEFT JOIN mimiciv_derived.sepsis3 sepsis
        ON ie.stay_id = sepsis.stay_id
    LEFT JOIN mimiciv_derived.gcs gcs
        ON ie.subject_id = gcs.subject_id
            AND gcs.charttime >= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime ELSE sepsis.sofa_time - INTERVAL '24' HOUR END)
            AND gcs.charttime <= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '24' HOUR ELSE sepsis.sofa_time END)
    GROUP BY ie.subject_id, ie.stay_id
)

, lab as (
WITH sepsis AS (SELECT stay_id FROM mimiciv_derived.sepsis3)
SELECT
    COUNT(heart_rate) AS heart_rate_num,
    COUNT(sbp) AS sbp_num,
    COUNT(dbp) AS dbp_num,
    COUNT(mbp) AS mbp_num,
    COUNT(resp_rate) AS resp_rate_num,
    COUNT(temperature) AS temperature_num
    , CASE WHEN ie.stay_id in (SELECT * FROM sepsis) THEN 1 ELSE 0 END AS sepsis
	, ie.stay_id
FROM mimiciv_icu.icustays ie
LEFT JOIN mimiciv_derived.sepsis3 sepsis
    ON ie.stay_id = sepsis.stay_id
LEFT JOIN mimiciv_derived.vitalsign vs
    ON ie.subject_id = vs.subject_id
    -- pre septic window defined as 24 hours before sepsis onset
    -- if no sepsis onset, then 24 hours after ICU admission to get the same window size
    -- resolution could be improved ..
        AND vs.charttime >= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime ELSE sepsis.sofa_time - INTERVAL '24' HOUR END)
        AND vs.charttime <= (CASE WHEN sepsis.sofa_time IS NULL THEN ie.intime + INTERVAL '24' HOUR ELSE sepsis.sofa_time END)
GROUP BY ie.subject_id, ie.stay_id
)
SELECT
    ie.subject_id
    --, ie.stay_id
    -- complete blood count
	, lab.*
    , cbc.*
    , chem.*
    , diff.*
    , gcs.*
    , bga.*
FROM mimiciv_icu.icustays ie
LEFT JOIN cbc
    ON ie.stay_id = cbc.stay_id
LEFT JOIN chem
    ON ie.stay_id = chem.stay_id
LEFT JOIN diff
    ON ie.stay_id = diff.stay_id
Left Join lab
	on ie.stay_id = lab.stay_id
LEFT JOIN gcs
    on ie.stay_id = gcs.stay_id
LEFT JOIN bga
    on ie.stay_id = bga.stay_id
;