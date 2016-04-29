library(ggmap)

#This map uses the data Stations.csv, gathered using the Google Maps API and available in the Google Maps Data folder
data <- read.csv("stations.csv")
data$color <- ifelse(data$Year == 2013, "dark blue", ifelse(data$Year == 2015, "dark green", "dark orange"))

map <- get_map(location = "New York City", zoom = 12, source = "google", maptype = "roadmap")
mapGG <- ggmap(ggmap = map, extent = "device", legend = "bottom")
mapGG + geom_point(aes(x = Longitude, y = Latitude), data = data, col = data$color, alpha = 0.5, size = round(data$Count/1250+2))
