--Strategy: 
--1. Filter out all measures for which a lower score is better. This analysis is restricted to indicators for which higher score is better. 
--2. Filter to top 10 most commonly measured items across all hospitals. 
--3. Weight the score by the number of samples taken (sample column)  
--4. Take the average of those top ten scores and order them for each hospital. 
--5. Order by top score on the average 


--attempt to remove small hospitals

drop table if exists my_filter;

create table my_filter
as select distinct provider_id 
from effective_care where score = 'Low (0 - 19,999 patients annually)';

drop table if exists filtered_table;

create table filtered_table 
as select a.* 
from effective_care a left join my_filter b on a.provider_id = b.provider_id where b.provider_id  is null;

-- remove measures for which lower is better

drop table if exists only_high;

create table only_high
as select provider_id, state_abbrev, measure_id, measure_name, hospital_name, score, cast(score as int) as intscore, cast(sample as int) as intsample
from filtered_table
where measure_id not in ('ED_1b','ED_2b','OP_1','OP_3b','OP_5','OP_18b','OP_20','OP_21','OP_22', 'PC_01','VTE_6','EDV') 
and footnote = '' 
and sample <> 'Not Available';

--get list of only the highest measures
create table top_measures as
SELECT measure_name, measure_id, count(measure_id) as num
FROM only_high GROUP BY measure_name, measure_id
order by num DESC
limit 10;

--IMM_3_OP_27_FAC_ADHPCT  2767                                                    
--STK_1	101
--STK_10	58
--STK_2	37
--SCIP_VTE_2	33
--SCIP_INF_1	27
--SCIP_INF_2	27
--SCIP_INF_3	26
--VTE_1	25
--IMM_2	21

--manually input list into new filtering command, as my attempts to automate it failed. 

drop table if exists analysis_table;

create table analysis_table as 
select * from only_high
where measure_id in ('IMM_3_OP_27_FAC_ADHPCT','STK_1','STK_10','STK_2','SCIP_VTE_2','SCIP_INF_2','SCIP_INF_1','SCIP_INF_3','VTE_1','IMM_2') and intsample > 500;


