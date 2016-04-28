rm(list=ls())

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
data$birth_year<-as.numeric(data$birth_year)
data<-data[complete.cases(data),]

data<-tbl_df(data)

data<-filter(data,tripduration<3000) #removing 0.5% of the trips greater than 66 minutes

data$start_time <- as.POSIXct(strptime(data$starttime, "%m/%d/%Y %H:%M:%S"))
data$data_year <- year(data$start_time)
data$age<-data$data_year-data$birth_year #create age variable
data<-na.omit(data)

data<-filter(data,age<75) #set cutoff equal to 75
data<-data %>%mutate(age.buckets = as.integer(5 * round(data$age/5))) #create age buckets

#Now lets break up each ride into its station pair, day, and hour
sorted.data<-data %>% 
  filter(start_station_id != end_station_id) %>% #remove roundtrips to same station
  mutate(start.time = mdy_hms(starttime)) %>% #fix start_time for narrowing down intervals
  mutate(day = mdy(paste0(month(start.time),"/",day(start.time),"/",year(start.time))),hour = hour(start.time)) %>% #simplify to days and hours
  mutate(gender = ifelse(gender==1,"male","female")) %>% # 0 = male, 1 = female
  mutate(distance = paste0(start_station_id,",", end_station_id)) %>% #create tuples of each station to station pair
  ungroup

median(data$tripduration)

###################################################################
#Calculate Differentials
###################################################################

##Create buckets
hourly.data <- sorted.data %>%
  group_by(day,hour, distance,gender,age.buckets) %>% 
  summarize(avg.trip = mean(tripduration))%>% 
  arrange(distance,gender,age.buckets)

#Break into clusters for faster processing

cluster <- create_cluster(7)
set_default_cluster(cluster)
hourly.data <- hourly.data %>% 
  partition(cluster = cluster)

cluster_library(hourly.data, "dplyr")
hourly.data<-partition(hourly.data)

#Do Calculation
hourly.data<-hourly.data %>%
  do(mutate(.,pct = ifelse(lag(age.buckets,1)==age.buckets-5, (avg.trip/lag(avg.trip,1)-1),NA)))

hourly.data<-collect(hourly.data)
results<-na.omit(hourly.data)

results<- results %>% ungroup

##########################################################################
#Build graphs
###########################################################################

mapping<-data.frame(age.buckets = seq(from=15,to=70,by=5),text.age=c("15-20","20-25","25-30","30-35", "35-40","40-45", "45-50","50-55","55-60","60-65","65-70","70-75"))

results<-merge(results,mapping)

#Overall
mean<- results %>% 
  group_by(gender,text.age) %>% ##Lots of outliers, limit to change less than 100%
  summarize(result = mean(pct)*100,count=n(),sd=sd(pct*100))

median<- results %>% 
  group_by(gender,text.age) %>%
  summarize(result = median(pct)*100)

densities<-results %>% 
  group_by(gender,text.age)

densitygraph<-ggplot(densities,aes(x=pct,fill=gender))+geom_density(alpha=0.3)+ggtitle("Kernel densities of Slowdown")
png("densitygraph.jpg")
densitygraph
dev.off()

winsorized.dens.graph<-results %>%
  filter(pct<10) %>%
  group_by(gender,text.age)
  
wins.densitygraph<-ggplot(winsorized.dens.graph,aes(x=pct,fill=gender))+geom_density(alpha=.3)+ggtitle("Winsorized Kernel densities of Slowdown")
png("winsdensitygraph.jpg")
wins.densitygraph
dev.off()

meangraph<-ggplot(mean,aes(x=text.age,y=result,fill=gender)) + 
  geom_bar(stat="identity",position="dodge") +
  ggtitle("Average Slowdown") + 
  labs(x="Age Bucket",y="Average Slowdown (percent)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

countgraph<-ggplot(mean,aes(x=text.age,y=count,fill=gender)) + 
  geom_bar(stat="identity",position="dodge") +
  ggtitle("Number of Riders by Gender")+
  labs(x="Age Bucket",y="Count of Riders")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


mediangraph<-ggplot(median,
                    aes(x=text.age,y=result,fill=gender))+
                    geom_bar(stat="identity",position="dodge") + 
                    ggtitle("Median Slowdown by Age") + 
                    labs(x="Age Bucket",y="Median Slowdown (percent)")+
                    theme(axis.text.x = element_text(angle = 45, hjust = 1))


png("Starting trip times.jpg")
hist(sorted.data$hour,main="Frequency Count of Starting Trip Times")
dev.off()

png("Ridersbyage.jpg")
hist(sorted.data$age,main="Frequency  Count of Citibike Riders by Age")
dev.off()

png("Countgraph.jpg")
countgraph
dev.off()

png("meangraph.jpg")
meangraph
dev.off()

png("mediangraph.jpg")
mediangraph
dev.off()

###################################################################
#Graphs excluding 70>
###################################################################
#Overall
results<-filter(results, text.age != "70-75")

mean<- results %>% 
  group_by(gender,text.age) %>% ##Lots of outliers, limit to change less than 100%
  summarize(result = mean(pct)*100,count=n(),sd=sd(pct*100))

median<- results %>% 
  group_by(gender,text.age) %>%
  summarize(result = median(pct)*100) 


densities<-results %>% 
  group_by(gender,text.age)

densitygraph<-ggplot(densities,aes(x=pct,fill=gender))+geom_density(alpha=0.3)+ggtitle("Kernel densities of Slowdown")
png("densitygraph.ex70.jpg")
densitygraph
dev.off()

winsorized.dens.graph<-results %>%
  filter(pct<10) %>%
  group_by(gender,text.age)

wins.densitygraph<-ggplot(winsorized.dens.graph,aes(x=pct,fill=gender))+geom_density(alpha=.3)+ggtitle("Winsorized Kernel densities of Slowdown")
png("winsdensitygraph.ex70.jpg")
wins.densitygraph
dev.off()

meangraph<-ggplot(mean,aes(x=text.age,y=result,fill=gender)) + 
  geom_bar(stat="identity",position="dodge") +
  ggtitle("Average Slowdown")+
  labs(x="Age Bucket",y="Average Slowdown (percent)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


countgraph<-ggplot(mean,aes(x=text.age,y=count,fill=gender)) + 
  geom_bar(stat="identity",position="dodge") +
  ggtitle("Number of Riders by Gender")+
  labs(x="Age Bucket",y="Count of Rider")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


mediangraph<-ggplot(median,
                    aes(x=text.age,y=result,fill=gender))+
  geom_bar(stat="identity",position="dodge") + 
  ggtitle("Median Slowdown by Age") + 
  labs(x="Age Bucket",y="Median Slowdown (percent)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


png("Starting trip times.ex70.jpg")
hist(sorted.data$hour,main="Frequency Count of Starting Trip Times")
dev.off()

png("Ridersbyage.ex70.jpg")
hist(sorted.data$age,main="Frequency  Count of Citibike Riders by Age")
dev.off()

png("Countgraph.ex70.jpg")
countgraph
dev.off()

png("meangraph.ex70.jpg")
meangraph
dev.off()

png("mediangraph.ex70.jpg")
mediangraph
dev.off()

mean.line.graph<-ggplot(mean,aes(x=text.age,y=result,color=gender)) + 
  geom_line(aes(group=gender)) +
  ggtitle("Average Slowdown")+labs(x="Age Bucket",y="Average Slowdown (percent)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


median.line.graph<-ggplot(median,
                    aes(x=text.age,y=result,color=gender))+
  geom_line(aes(group=gender)) + 
  ggtitle("Median Slowdown by Age")

png("mean.line.ex70.jpg")
mean.line.graph
dev.off()

png("mediangraph.line.ex70.jpg")
median.line.graph
dev.off()


###################################################################
#Rejoin with Google maps distance
###################################################################

distances <- read.csv("~/unique.csv")
distances<-na.omit(distances)
distances$distance<-paste0(distances$start, "," ,distances$end)
distances<-tbl_df(distances)
distances<-distances %>% select(distance,paths)

gg.data<-tbl_df(merge(sorted.data,distances,by.x="distance",by.y="distance"))
gg.data<-na.omit(gg.data)

gg.data<-merge(gg.data,mapping)

##Build differential
gg.results<-gg.data %>% ungroup %>%
  group_by(text.age,gender) %>%
  mutate(deviation = tripduration-(paths*60)) %>%
  summarize(mean.deviation = mean(deviation),median.deviation = median(deviation), count=n()) 

deviation.graph<-ggplot(gg.results,aes(x=text.age,y=mean.deviation,fill=factor(gender))) + 
  geom_bar(stat="identity",position="dodge") + 
  ggtitle("Mean Deviation from Google Maps Biking Time")+
  labs(x="Age Bucket",y="Average Slowdown (seconds)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


png("deviation.graph.jpg")
deviation.graph
dev.off()

deviation.line<-ggplot(gg.results,aes(x=text.age,y=mean.deviation,color=factor(gender),group = 1)) + 
  geom_line(aes(group=gender)) + 
  ggtitle("Mean Deviation from Google Maps Biking Time")+
  labs(x="Age Bucket",y="Average Slowdown (seconds)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

png("deviation.graph.line.jpg")
deviation.line
dev.off()

dev.density<-gg.data %>% mutate(deviation = tripduration-paths) %>% select(text.age,gender,deviation)

deviation.density<-ggplot(dev.density,aes(x=deviation,fill=factor(gender))) + 
  geom_density(alpha=.5) + 
  ggtitle("Kernel Density of Deviation from Google Maps Time")

png("deviation.density.jpg")
deviation.density
dev.off()

deviation.density.age<-ggplot(dev.density,aes(x=deviation,fill=factor(text.age))) + 
  geom_density(alpha=.5) + 
  ggtitle("Kernel Density of Deviation from Google Maps Time")

png("deviation.density.age.jpg")
deviation.density.age
dev.off()
