#! /bin/bash
cd /data
wget -O hospital_data.zip https://data.medicare.gov/views/bg9k-emty/files/Dlx5-ywq01dGnGrU09o_Cole23nv5qWeoYaL-OzSLSU?content_type=application%2Fzip%3B%20charset%3Dbinary&filename=Hospital_Revised_Flatfiles.zip

sleep 60

mkdir hospitals
unzip hospital_data.zip -d hospitals
cd hospitals

#Cleaning header info
tail -n +2 Measure\ Dates.csv > measure_codes.csv
tail -n +2 Readmissions\ and\ Deaths\ -\ Hospital.csv > readmit_deaths.csv
tail -n +2 Complications\ -\ Hospital.csv > complications.csv
tail -n +2 Hospital\ General\ Information.csv > hospital_geninfo.csv
tail -n +2 Timely\ and\ Effective\ Care\ -\ Hospital.csv > effective_care.csv
tail -n +2 hvbp_hcahps_10_28_2015.csv > survey.csv

#Make directories
hdfs dfs -mkdir /user/w205/hospital_compare
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data/measure_codes/
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data/readmit_deaths/
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data/complications/
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data/hospital_geninfo/
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data/effective_care/
hdfs dfs -mkdir /user/w205/hospital_compare/raw_data/survey/


#place tables into hdfs
hdfs dfs -put /data/hospitals/measure_codes.csv /user/w205/hospital_compare/raw_data/measure_codes/
hdfs dfs -put /data/hospitals/readmit_deaths.csv /user/w205/hospital_compare/raw_data/readmit_deaths/
hdfs dfs -put /data/hospitals/complications.csv /user/w205/hospital_compare/raw_data/complications/
hdfs dfs -put /data/hospitals/hospital_geninfo.csv /user/w205/hospital_compare/raw_data/hospital_geninfo/
hdfs dfs -put /data/hospitals/effective_care.csv /user/w205/hospital_compare/raw_data/effective_care/
hdfs dfs -put /data/hospitals/survey.csv /user/w205/hospital_compare/raw_data/survey/

