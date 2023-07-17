DROP TABLE IF EXISTS mimiciv_derived.cohort_selection;
CREATE TABLE mimiciv_derived.cohort_selection AS
SELECT ie.stay_id, ie.subject_id
from mimiciv_icu.icustays ie
LEFT JOIN mimiciv_derived.sepsis3 s
	on s.stay_id = ie.stay_id
where ie.outtime - ie.intime >= INTERVAL '8' hour
and case when s.sofa_time is not null then s.sofa_time - ie.intime >= INTERVAL '8' hour else true end;