DROP TABLE if exists hospital_geninfo;

CREATE EXTERNAL TABLE  hospital_geninfo
(provider_id int,
hospital_name string,
address string,
city string,
state_abrev string,
zip_code string,
county string,
phone int,
hospital_type string,
ownership string,
emergency string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/raw_data/hospital_geninfo/';

DROP TABLE if exists measure_codes;
CREATE EXTERNAL TABLE  measure_codes
(measure_name string,
measure_id int,
start_quarter string,
start_date date,
end_quarter string,
end_date date)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/raw_data/measure_codes';


DROP TABLE if exists readmit_deaths;
CREATE EXTERNAL TABLE  readmit_deaths
(provider_id int,
hospital_name string,
address string,
city string,
state_abbrev string,
zip_code string,
county string,
phone int,
measure_name string,
measure_id string,
compared_to_national string,
denominator int,
score float,
lower_estimate float,
higher_estimate float,
footnote string,
measure_start date,
measure_end date)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/raw_data/readmit_deaths';



DROP TABLE if exists complications;
CREATE EXTERNAL TABLE  complications
(provider_id int,
hospital_name string,
address string,
city string,
state_abbrev string,
zip_code string,
county string,
phone int,
measure_name string,
measure_id string,
compared_to_national string,
denominator int,
score float,
lower_estimate float,
higher_estimate float,
footnote string,
measure_start date,
measure_end date)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/raw_data/complications';


DROP TABLE if exists effective_care;
CREATE EXTERNAL TABLE  effective_care
(provider_id int,
hospital_name string,
address string,
city string,
state_abbrev string,
zip_code string,
county string,
phone int,
condition_name string,
measure_id string,
measure_name string,
score float,
sample int,
footnote string,
measure_start date,
measure_end date)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/raw_data/effective_care';

DROP TABLE if exists survey;
CREATE EXTERNAL TABLE survey
(provider_id int,
hospital_name string,
address string,
city string,
state_abbrev string,
zip_code string,
county string,
nurses_achievement string,
nurses_improvement string,
nurses_dimension string,
doctors_achievement string,
doctors_improvement string,
doctors_dimesion string,
responsiveness_achievement string,
responsiveness_improvement string,
responsiveness_dimension string,
pain_achievement string,
pain_improvement string,
pain_dimension string,
communication_achievement string,
communication_improvement string,
communication_dimension string,
cleanliness_achievement string,
cleanliness_improvement string,
cleanliness_dimension string,
discharge_achievement string,
discharge_improvement string,
discharge_dimension string,
overall_achievement string,
overall_improvement string,
overall_dimension string,
HCAHPS_base_score string,
HCAHPS_base_consistency string,
measure_start date,
measure_end date)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/raw_data/survey';

