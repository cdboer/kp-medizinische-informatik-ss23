select avg(s.sofa_time - i.intime), s.sepsis3 from mimiciv_hosp.patients
	left join mimiciv_icu.icustays i on i.subject_id = mimiciv_hosp.patients.subject_id
	left join mimiciv_derived.sepsis3 s on s.subject_id = mimiciv_hosp.patients.subject_id
where s.stay_id = i.stay_id
group by s.sepsis3