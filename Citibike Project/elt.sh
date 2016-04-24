#! /bin/bash

## Install necessary programs
yum -y install unzip
yum -y install openssl-devel
yum -y install libcurl-devel

#Download the data

mkdir -p final_project/raw_data
cd final_project/raw_data

wget https://s3.amazonaws.com/tripdata/201307-201402-citibike-tripdata.zip
wget https://s3.amazonaws.com/tripdata/2014{03..12}-citibike-tripdata.zip #includes all from 201403-201412
wget https://s3.amazonaws.com/tripdata/2015{01..12}-citibike-tripdata.zip
wget https://s3.amazonaws.com/tripdata/2016{01..02}-citibike-tripdata.zip

find . -name "*-citibike-tripdata.zip" -exec unzip {} \; #unzip all

rm *.zip #delete zip files

shopt -s globstar #Set Up Recursive renaming
rename \ -\ Citi\ Bike\ trip\ data.csv .csv ** #Rename both file name types
rename -citibike-tripdata.csv .csv **

#Strip all headers
for i in {7..9}
do
tail -n +2 2013-0$i.csv > 2013_0$i.csv
done

for i in {10..12}
do
tail -n +2 2013-$i.csv > 2013_$i.csv
done

for i in {1..8}
do
tail -n +2 2014-0$i.csv > 2014_0$i.csv
done

tail -n +2 201409.csv > 2014_09.csv

for i in {10..12}
do
tail -n +2 2014$i.csv > 2014_$i.csv
done

for i in {1..9}
do
tail -n +2 20150$i.csv > 2015_0$i.csv
done

for i in {10..12}
do
tail -n +2 2015$i.csv > 2015_$i.csv
done

for i in {1..2}
do
tail -n +2 20160$i.csv > 2016_0$i.csv
done

# Remove unecessary files
rm *-*.csv
rm 201409.csv #I ran the original ETL and ended up with a number of duplicate files, this gets rid of them
rm 201410.csv
rm 201411.csv
rm 201412.csv
rm 201501.csv
rm 201502.csv
rm 201503.csv
rm 201504.csv
rm 201505.csv
rm 201506.csv
rm 201507.csv
rm 201508.csv
rm 201509.csv
rm 201510.csv
rm 201511.csv
rm 201512.csv
rm 201601.csv
rm 201602.csv


#Concatenate everything
cat *.csv > mydb.csv

#Change User and transfer to hdfs
#su w205
#hdfs dfs -mkdir /user/w205/final_project
#hdfs dfs -put mydb.csv /user/w205/final_project/


#Sets up accessible database in Postgres
psql -U postgres -c "DROP DATABASE IF EXISTS citibike;"
psql -U postgres -c "CREATE DATABASE citibike;"
psql -U postgres -d citibike -c "DROP TABLE IF EXISTS cb_all;"
psql -U postgres -d citibike -c "CREATE TABLE cb_all (trip_duration INT, start_time TIMESTAMP, stop_time TIMESTAMP, start_station_ID INT, start_station_name TEXT, start_station_lat NUMERIC, start_station_long NUMERIC, end_station_ID INT, end_station_name TEXT, end_station_lat NUMERIC, end_station_long NUMERIC, bike_ID int, user_type TEXT, birth_year TEXT, gender INT);"
psql -U postgres -d citibike -c "COPY cb_all FROM '/data/final_project/raw_data/mydb.csv' DELIMITER ',' CSV;"
