CREATE TABLE citibike
(tripduration text,
starttime text, 
stoptime text,
start_station_id text,
start_station_name text,
start_station_latitude text,
start_station_longitude text,
end_station_id text,
end_station_name text,
end_station_latitude text,
end_station_longitude text,
bikeid text,
usertype text,
birth_year text,
gender text);

COPY citibike FROM '/data/final_project/raw_data/mydb.csv' DELIMITER ',' CSV;

ALTER TABLE citibike
DROP COLUMN stoptime, DROP COLUMN start_station_name, DROP COLUMN end_station_name, DROP COLUMN usertype;