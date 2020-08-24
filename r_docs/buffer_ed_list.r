# buffer_ed_list.r
# Author: David Van Riper
# Created: 2020-08-24
# 
# This script generates buffers around public housing devs and identifies EDs that intersect with 
# the buffer.

require(tidyverse)
require(sf)

#### Constants #### 
file_path <- "data/shps/ed/"
quarter_mile <- 402.336
half_mile <- 804.672

#### Read in PH development point shapefile ####
dev <- read_sf("data/shps/developments/ph_site_developments_albers.shp")
#ed_bham <- read_sf("data/shps/BirminghamAL_1940_EDmap.shp")

#### Generate list of city shapefiles #### 
file_list <- list.files(file_path, pattern = "?.shp")

#### Loop over file list ####
for(i in file_list){
  if(!str_detect(i, "xml")){
    j <- str_split(i, "_")
    x <- read_sf(paste0(file_path, i))
    
    x <- x %>%
      group_by(ED_num) %>%
      summarise(blk_count = n()) %>%
      mutate(city = j[[1]][1])
    
    # identify EDs that touch a quarter mile buffer around an development
    q_mile <- dev %>%
      st_buffer(dist = quarter_mile) %>%
      st_join(x) %>%
      filter(!is.na(ED_num))
    
    # identify EDs that touch a half mile buffer around an development
    h_mile <- dev %>%
      st_buffer(dist = half_mile) %>%
      st_join(x) %>%
      filter(!is.na(ED_num))
    
    if(exists("q_mile_final")){
      q_mile_final <- rbind(q_mile_final, q_mile)
    }else{
      q_mile_final <- q_mile 
    }
    
    if(exists("h_mile_final")){
      h_mile_final <- rbind(h_mile_final, h_mile)
    }else{
      h_mile_final <- h_mile 
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
