
DROP TABLE complications_clean;
CREATE EXTERNAL TABLE  complications_clean
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

INSERT OVERWRITE TABLE complications_clean
SELECT
provider_id int,
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
measure_end date
FROM complications
WHERE denominator <> "Not Available" OR score <> "Not Available" or lower_estimate <> "Not Available" or higher_estimate <> "Not Available";

