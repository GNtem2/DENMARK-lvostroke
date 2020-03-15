# DENMARK-lvostroke
This is a start for the project
It uses the following packages: eurostat, dplyr, sf and mapview. Mapview provides interactive map view using leaflet. Data on population in Denmark can be obtained at this link. https://www.statbank.dk/INDAMP01. The shapefile for the NUTS2 and NUTS3 can be obtained from eurostat package. The shapefile from the kommune can be obtained at this site https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/communes.

The data for the hospitals in demark contains comprehensive stroke unit (CSC) and primary stroke centre (PSC). The geocoding of the hospital is performed using geocode_OSM function from tmaptools. This project is written with codes adapted from https://richardbeare.github.io/GeospatialStroke/. Click the edit button to see the codes for creating this web page. 


[![denmark hospital](./denmark_stroke_nuts2.png)](./denmark_stroke_nuts2.html)

The map below contains data on number of stroke in 2018 within each NUTS2 region and 30 mkm catchment of each hospital.

[![denmark stroke hospital](./denmark_stroke_nuts2_catchment.png)](./denmark_stroke_nuts2_catchment.html)


