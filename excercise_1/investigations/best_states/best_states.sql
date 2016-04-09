-- run same procedure for states
drop table if exists best_states;

create table best_states as
select state_abbrev, avg(intsample) as sample_size, avg(intscore) as avg_score, stddev_samp(intscore) as var_score
from analysis_table 
group by state_abbrev 
order by avg_score desc 
limit 10;
