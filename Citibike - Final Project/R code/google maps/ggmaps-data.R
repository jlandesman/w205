rm(list=ls())
set.seed(1)

#install.packages("devtools")
#install.packages("ggmap")
#devtools::install_github("hadley/multidplyr")

library(ggmap)
library(multidplyr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(RPostgreSQL)

options(scipen=999) #no scientific notation

##Cnnect to db
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user="postgres")

##Remove rows where start station = end station;
data<-dbGetQuery(con, "select * from citibike")

##Transform
data$tripduration <- as.numeric(data$tripduration)
data<-data[complete.cases(data),]

data<-tbl_df(data)

data<-filter(data,tripduration<3000) #removing 0.5% of the trips greater than 66 minutes

data<-filter(data,age<75) #set cutoff equal to 75
data<-data %>%mutate(age.buckets = as.integer(5 * round(data$age/5))) #create age buckets

##Extract longitude and latitude measures
from<-data.frame(start = data$start_station_id, lon.s = data$start_station_longitude, lat.s= data$start_station_latitude)
to<-data.frame(end = data$end_station_id, lon.e = data$end_station_longitude, lat.e= data$end_station_latitude)

check<-tbl_df(cbind(from,to))
check<-lapply(check,as.numeric)
check<-tbl_df(as.data.frame(check))
check<-filter(check,start!=end)

unique.check<-unique(check)

unique.sample<-sample_n(unique.check,10000)
from<-data.frame(lon=unique.sample$lon.s,lat=unique.sample$lat.s)
to<-data.frame(lon=unique.sample$lon.e,lat=unique.sample$lat.e)

paths<-rep(NA,10000)  

for(i in  1:10000){
  paths[i]<-sum(route(unlist(from[i,]), unlist(to[i,]), 
                      mode = "bicycling", 
                      output = "simple")$minutes)
}

unique.sample$paths<-paths
write.csv(unique.sample,"unique2.csv")



unique.temp<-tbl_df(cbind(from,to))

##Remove relevatne columns from dataframe for RAM purposes
data<- data %>% select(-start_station_longitude,-start_station_latitude,-end_station_longitude,-end_station_latitude)

#Exclude rides where start station == end station
unique.paths <- data.frame(lapply(unique.temp, as.character),stringsAsFactors = FALSE)
unique.paths<- tbl_df(unique.paths)
unique.paths<-filter(unique.paths,start!=end)
unique.paths<-unique(unique.paths)

##Prepare to download from google
unique.sample<-sample_n(unique.paths,2500) ##Google's API restrictions to 2500/day
rm(unique.paths)

from<-data.frame(lat=unique.sample$lat.s,lon=unique.sample$lon.s)
to<-data.frame(lat=unique.sample$lat.e,lon=unique.sample$lon.e)

from<-data.frame(lapply(from,as.character),stringsAsFactors=FALSE)
to<-data.frame(lapply(to,as.character),stringsAsFactors=FALSE)

path.distances<-data.frame(distance=rep(NA,2500),minutes=rep(NA,2500))

for(i in 1:2500){
  path.distances$distance[i]<-paste0(unique.sample$start[i],",",unique.sample$end[i])
  path.distances$minutes[i]<-sum(route(from[i,], to[i,], mode = "bicycling", output = "simple")$minutes)
}

unique.sample$paths<-paths
write.csv(unique.sample,"unique.csv")
