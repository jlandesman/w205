-- Variance between procedures
drop table if exists variance_measures;

create table variance_measures as
select measure_name, stddev_samp(cast(score as int)) as var_score
from effective_care
where measure_id not in ('ED_1b','ED_2b','OP_1','OP_3b','OP_5','OP_18b','OP_20','OP_21','OP_22', 'PC_01','VTE_6')
group by measure_name
order by var_score desc;
