select count(icu.subject_id)
from mimiciv_icu.icustays icu
join mimiciv_derived.sepsis3 sep on sep.subject_id = icu.subject_id
where 
(icu.outtime - icu.intime) > interval '4 hours'
and (sep.sofa_time - icu.intime) > interval '4 hours'
and icu.stay_id = sep.stay_id
and sep.sepsis3