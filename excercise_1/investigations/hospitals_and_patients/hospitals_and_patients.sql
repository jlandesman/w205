drop table if exists survey_scores;

create table survey_scores as
select hospital_name, state_abbrev, cast(overall_achievement as int) as overall_score 
from survey_clean
order by overall_score desc
limit 20;
