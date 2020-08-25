# buffer_ed_list.r
# Author: David Van Riper
# Created: 2020-08-24
# 
# This script generates buffers around public housing devs and identifies EDs that intersect with 
# the buffer. It uses the public housing development point shapefile created by David Van Riper and
# the 1940 ED shapefiles created by the Urban Transition Historical GIS project at Brown Uniersity. 
# 
# Documentation about the 1940 ED shapefiles can be found at https://s4.ad.brown.edu/Projects/UTP2/citymaps.htm

require(tidyverse)
require(sf)

#### Constants #### 
file_path <- "data/shps/ed/"
# the 1/4 and 1/2 mile buffers are in meters
quarter_mile <- 402.336
half_mile <- 804.672

#### Read in PH development point shapefile ####
dev <- read_sf("data/shps/developments/ph_site_developments_albers.shp")

#### Buffer the dev shapefile #### 
q_mile_dev <- dev %>%
  st_buffer(dist = quarter_mile)

h_mile_dev <- dev %>%
  st_buffer(dist = half_mile)

#### Generate list of city ED shapefiles #### 
file_list <- list.files(file_path, pattern = "?.shp")

#### Loop over file list, finding the EDs the touch the quarter and half mile buffers ####
for(i in file_list){
  if(!str_detect(i, "xml")){
    j <- str_split(i, "_")
    
    # Read in city-specific ED shapefile
    x <- read_sf(paste0(file_path, i))
    
    # Dissolve city-specific shapefile to create ED polygons
    # Add a city name to sf
    x <- x %>%
      group_by(ED_num) %>%
      summarise(blk_count = n()) %>%
      mutate(city = j[[1]][1])
    
    # Join quarter mile buffer onto ED shapes and retains all EDs with a value for site_name
    q_mile_ed <- x %>%
      st_join(q_mile_dev) %>%
      filter(!is.na(site_name))

    # Join half mile buffer onto ED shapes and retains all EDs with a value for site_name
    h_mile_ed <- x %>%
      st_join(h_mile_dev) %>%
      filter(!is.na(site_name))    

    # bind together the quarter mile EDs for a given development
    if(exists("q_mile_final")){
      q_mile_final <- rbind(q_mile_final, q_mile_ed)
    }else{
      q_mile_final <- q_mile_ed
    }
    
    # bind together the half mile EDs for a given development
    if(exists("h_mile_final")){
      h_mile_final <- rbind(h_mile_final, h_mile_ed)
    }else{
      h_mile_final <- h_mile_ed
    }
  }
}

#### Write out to shapefiles ####
st_write(q_mile_final, "data/ed_lists/quarter_mile_eds.shp")
st_write(h_mile_final, "data/ed_lists/half_mile_eds.shp")

#### Write out to CSVs ####
q <- as_tibble(q_mile_final) %>%
  select(-geometry)

h <- as_tibble(h_mile_final) %>%
  select(-geometry)

write_csv(q, "data/ed_lists/quarter_mile_eds.csv")
write_csv(h, "data/ed_lists/half_mile_eds.csv")
