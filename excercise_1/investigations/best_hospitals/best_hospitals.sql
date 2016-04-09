
--select top hospitals and their variance along these 10 dimensions
drop table if exists best_hospitals;

create table best_hospitals as
select provider_id, hospital_name, state_abbrev, avg(intsample) as sample_size, avg(intscore) as avg_score, stddev_samp(intscore) as var_score
from analysis_table 
group by provider_id, hospital_name, state_abbrev 
order by avg_score desc 
limit 10;

-- build table to cross check against complications table

drop table if exists crosscheck;

create table crosscheck as select provider_id, hospital_name, avg(intsample) as sample_size, avg(intscore) as avg_score, stddev_samp(intscore) as var_score
from analysis_table 
group by provider_id, hospital_name 
order by avg_score desc 
limit 10;

-- check to make sure none of these are in the worst 100 tables in the data set

drop table if exists complications_worst;

create table complications_worst as
select provider_id, hospital_name, avg(score) as avg_score 
from complications_clean 
group by provider_id, hospital_name
order by avg_score desc limit 100;

select * from crosscheck JOIN complications_worst ON (crosscheck.provider_id = complications_worst.provider_id);
-- a okay!

-- same for readmits and deaths

drop table if exists readmissions_worst;

create table readmissions_worst as
select provider_id, hospital_name, avg(score) as avg_score 
from readmit_deaths_clean 
group by provider_id, hospital_name
order by avg_score desc limit 100;

select * from crosscheck JOIN readmissions_worst ON (crosscheck.provider_id = readmissions_worst.provider_id);
