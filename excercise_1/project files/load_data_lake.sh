#! /bin/bash

sudo yum install unzip

wget -O hospital_data.zip https://data.medicare.gov/views/bg9k-emty/files/Dlx5-ywq01dGnGrU09o_Cole23nv5qWeoYaL-OzSLSU?content_type=application%2Fzip%3B%20charset%3Dbinary&filename=Hospital_Revised_Flatfiles.zip

mkdir hospitals

unzip hospital_data.zip -d hospitals

#Cleaning header info
tail -n +2 Measure\ Dates.csv > measure_codes.csv
tail -n +2 Readmissions\ and\ Deaths\ -\ Hospital.csv > readmit_deaths.csv
tail -n +2 Complications\ -\ Hospital.csv > complications.csv
tail -n +2 Hospital\ General\ Information.csv > hospital_geninfo.csv
tail -n +2 Timely\ and\ Effective\ Care\ -\ Hospital.csv > effective_care.csv
tail -n +2 HCAHPS\ -\ Hospital.csv > survey.csv

#Get ready to load data into HDFS
hdfs dfs -ls /user/w205

su w205
hdfs dfs -mkdir /user/w205/hospital_compare
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data

hdfs dfs -put measure_codes.csv /user/w205/hospital_compare/raw_data
hdfs dfs -put readmit_deaths.csv /user/w205/hospital_compare/raw_data
hdfs dfs -put complications.csv /user/w205/hospital_compare/raw_data
hdfs dfs -put hospital_geninfo.csv /user/w205/hospital_compare/raw_data
hdfs dfs -put effective_care.csv /user/w205/hospital_compare/raw_data
hdfs dfs -put survey.csv /user/w205/hospital_compare/raw_data

hdfs dfs -ls /user/w205/hospital_compare/raw_data

