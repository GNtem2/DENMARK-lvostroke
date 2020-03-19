library(tidyverse)
library(sf)
library(here)
library(curl)
library(rvest)
# sf::st_read doesn't cope with files > 2G!
# neither does geojsonio::geojson_read
# Therefore we need to fetch the kommunes, but they don't have a nie
# labelling scheme to automate it. Thus we will need to parse the html
fetchifmissing <- function(url, dest) {
  if (!file.exists(dest)) {
    curl_download(url = url, destfile=dest, quiet=FALSE)
  }
  return(dest)
}

f <- here("GeoJSON", "kommueURLs.Rda")
if (file.exists(f)) {
  load(f)
} else {
  da <- read_html("https://download.aws.dk/adresser")
  
  # html_structure(da)
  
  alltables <- html_nodes(da, "div.table-responsive")
  kommunes <- alltables[[1]]
  kommuneURLs <- html_nodes(kommunes, "tbody") %>%
    html_nodes(xpath="//a[contains(@href, 'geojson')]") %>% 
    html_attr("href")
  # only want the ones with kommunekode
  kommuneURLs <- grep(x=kommuneURLs, pattern="kommunekode", value = TRUE)
  
  # now for kommune names - this selects nodes without children
  ff <- html_nodes(kommunes, "tbody") %>%html_nodes(xpath="//th[not(a)]")
  ff <- html_text(ff)
  # we want the ones that start with a number
  ff <- grep(x=ff, pattern="^0.+", value=TRUE)
  # turn this into a table
  kommune.df <- tibble(webid=stringr::str_replace(ff, "^([[:digit:]]+) .+", "\\1"),
                       kommune=stringr::str_replace(ff, "^([[:digit:]]+) (.+)", "\\2"))
  kommuneURLs <- tibble(url=kommuneURLs, 
                        webid=stringr::str_replace(kommuneURLs, "^.+=([[:digit:]]+)$", "\\1"))
  kommuneURLs <- left_join(kommuneURLs, kommune.df, by="webid")
  save(kommuneURLs, file=f)
}
kommuneURLs <- mutate(kommuneURLs, dest=here("GeoJSON", paste0(webid, ".geojson")))

kommuneGJ <- map2_chr(kommuneURLs$url, kommuneURLs$dest, fetchifmissing)
names(kommuneGJ) <- kommuneURLs$kommune

f <- here("GeoJSON" ,"kommune_adresser.Rda")
if (file.exists(f)) {
  load(f)
} else {
  kommuneSF <- map(kommuneGJ, st_read)
  save(kommuneSF, file=f)
}

# 
dummy <- function() {
  # Most of these files appear to big for the readers. We will need to download kommunes
  # I've left this code in for reference, but it won't be run when you source the file.
  fetchifmissing("http://dawa.aws.dk/adresser?format=geojson&regionskode=1081", here("GeoJSON" ,"nordjylland.geojson"))
  fetchifmissing("http://dawa.aws.dk/adresser?format=geojson&regionskode=1082", here("GeoJSON" ,"midtjylland.geojson"))
  fetchifmissing("http://dawa.aws.dk/adresser?format=geojson&regionskode=1083", here("GeoJSON" ,"syddanmark.geojson"))
  fetchifmissing("http://dawa.aws.dk/adresser?format=geojson&regionskode=1084", here("GeoJSON" ,"hovedstaden.geojson"))
  fetchifmissing("http://dawa.aws.dk/adresser?format=geojson&regionskode=1085", here("GeoJSON" ,"sjaelland.geojson"))
  
  f <- here("GeoJSON", "addresser.Rda")
  if (file.exists(f)) {
    load(f)
  } else {
    # most of this doesn't work
    nordjylland <- st_read(here("GeoJSON" ,"nordjylland.geojson"))
    midtjylland <- st_read(here("GeoJSON" ,"midtjylland.geojson"))
    syddanmark <- st_read(here("GeoJSON" ,"syddanmark.geojson"))
    hovedstaden <- st_read(here("GeoJSON" ,"hovedstaden.geojson"))
    sjaelland <- st_read(here("GeoJSON" ,"sjaelland.geojson"))
    save(nordjylland, 
         #midtjylland, 
         syddanmark, hovedstaden, sjaelland, file=f)
  }
}