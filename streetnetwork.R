
library(dodgr)
library(tidyverse)
library(sf)

load("euro_nuts2_sf.Rda")

#subset 5 regions of Denmark
#DKnuts2_sf<- euro_nuts2_sf%>% filter(str_detect(NUTS_ID,"^DK"))

#extract streetnetwork for Midtjylland
#https://richardbeare.github.io/GeospatialStroke/RehabCatchment/README.html#7_create_a_street_network_database
Midtjylland<-euro_nuts2_sf%>% filter(str_detect(NUTS_ID,"^DK")) %>% 
filter (NUTS_NAME=="Midtjylland")

Midtjylland_sf<-euro_nuts2_sf%>% filter(str_detect(NUTS_ID,"^DK")) %>% 
  filter (NUTS_NAME=="Midtjylland")


#bounding polygom
bounding_polygon <- sf::st_transform(Midtjylland_sf,
                                     sf::st_crs(4326)) %>%
  sf::st_union () %>%
  sf::st_coordinates ()
bounding_polygon <- bounding_polygon [, 1:2]

Midtjylland_streets <- dodgr_streetnet (bounding_polygon, expand = 0, quiet = FALSE)

#save street network
#saveRDS(Midtjylland_streets,file="Midtjylland_street.Rds")

#load streetnetwork
#Midtjylland_streets<-readRDS("Midtjylland_street.Rds")

#number of distinct street lines
format (nrow (Midtjylland_streets), big.mark = ",")
#[1] "170,940"

#estimate travel time by distance
net <- weight_streetnet (Midtjylland_streets, wt_profile = "motorcar")
format (nrow (net), big.mark = ",")
#[1] "1,275,125"

#
