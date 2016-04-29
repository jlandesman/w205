library(ggmap)
library(dplyr)

#This analysis is limited to only month of data, so it is run locally rather than on the full set in AWS
download.file("https://s3.amazonaws.com/tripdata/201405-citibike-tripdata.zip", "201405-citibike-tripdata.zip")
unzip("201405-citibike-tripdata.zip")
data <- read.csv("2014-05 - Citi Bike trip data.csv")

bikecounts <- as.data.frame(table(data$bikeid))
bikeid_max <- bikecounts$Var1[which(bikecounts$Freq == max(bikecounts$Freq))]

bike <- data %>% filter(bikeid == bikeid_max) %>% select(start.station.id, start.station.latitude, start.station.longitude, end.station.latitude, end.station.longitude)
bike$id <- 1:nrow(bike)
colnames(bike) <- c("station_id", "lat", "long", "lat", "long", "id")
bike_long <- rbind(bike[,c(2,3,6)], bike[,c(4:6)])
bike_long <- bike_long[order(bike_long$id),]


map <- get_map(location = "New York City", zoom = 13)
mapGG <- ggmap(ggmap = map, extent = "device", legend = "right")
mapGG + geom_line(data = data.frame(bike_long), aes(x = long, y = lat, group = id), color = "dark blue", ) + geom_point(aes(x = long, y = lat), data = bike, color = "dark red")
