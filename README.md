# w205

##Introduction

This project uses data from the October 2015 HCAPS survey.  The data are available here.  Note that this file reflects updated data from last semester’s project, which had data from May 2015.  

##Key Files

1.	**load_data_lake.sh** – downloads the data in zip format, unzips its and loads the data in into HDFS.  Note – please ensure your volume has an unzip program installed. 

2.	**hive_base_ddl.sql** – loads the data into SQL tables

3.	**transform_survey.sql** – transforms the relevant patient survey table and outputs a table called survey_scores with the top hospitals via patient survesy.  

4.	**transform_complications.sql** and transform_readmit_deaths.sql – transforms the complications and readmit_deaths tables into useable format (probably not needed.) 

5.	**analytical_output.sql** – main SQL script for conducting the analysis.  This script results in three key tables, which are accessed from files in the investigations folders: 

a.	best_hospitals: lists the top 10 best hospitals culled from the data

b.	best_states: lists the best states in the data

c.	variance_measures: sorts the quality control measures by the measure with the highest standard deviation.  
