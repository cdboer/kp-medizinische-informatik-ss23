DROP TABLE IF EXISTS mimiciv_derived.transfer_flow; CREATE TABLE mimiciv_derived.transfer_flow AS

WITH transfers as (
    SELECT 
        hadm_id, 
        eventtype, 
        careunit, 
        rank() over (partition by hadm_id order by intime) as r FROM mimiciv_hosp.transfers
)
SELECT 
    t1.r as transfer_num, 
    t1.eventtype, 
    t1.careunit as from_unit, 
    t2.careunit as to_unit
FROM transfers t1
LEFT JOIN transfers t2
ON 
    t1.hadm_id = t2.hadm_id 
    AND t1.r = t2.r - 1