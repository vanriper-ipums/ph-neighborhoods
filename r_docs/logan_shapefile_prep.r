# logan_shapefile_prep.r
# Author: David Van Riper
# Created: 2020-10-07
# 
# This script prepares Logan's Urban Transition Historical GIS shapefiles for further analysis. The
# shapefiles are tiled by city and in Web Mercator projection. This script merges the cities together
# for each year (1930 and 1940) and projects them to albers equal area.
# 
# The Logan shapefiles aren't dissolved on ED - multipart EDs just have same attributes on each part. Need to
# handle this, eventually.
# 
# Documentation about the 1940 ED shapefiles can be found at https://s4.ad.brown.edu/Projects/UTP2/citymaps.htm

require(tidyverse)
require(sf)
require(lwgeom)

#### Constants #### 
path40 <- "data/shps/ed1940/"
path30 <- "data/shps/ed1930/"
quarter_mile <- 402.336
half_mile <- 804.672

#### List files in dir ####
files40 <- intersect(list.files(path40, pattern = "shp$", recursive = TRUE), list.files(path40, pattern = "ed", recursive = TRUE))
files30 <- intersect(list.files(path30, pattern = "shp$", recursive = TRUE), list.files(path30, pattern = "ed", recursive = TRUE))

#### Load ph dev shapefile #### 
dev <- read_sf("data/shps/developments/ph_site_developments_albers.shp")

#### Loop over 1940 file list, finding the EDs the touch the quarter and half mile buffers ####
for(i in files40){
    
    # City name 
    j <- str_split(i, "/")
    
    # Read in city-specific ED shapefile
    x <- read_sf(paste0(path40, i))
    
    # Dissolve by ed 
    x <- x %>%
      group_by(ed) %>%
      summarise(totalpop = max(totalpop),
                wpop = max(wpop),
                bpop = max(bpop))
    
    # Add city name to each ED 
    x <- x %>%
      mutate(city_name = j[[1]][1])
    
    # bind together the quarter mile EDs for a given development
    if(exists("ed1940")){
      ed1940 <- rbind(ed1940, x)
    }else{
      ed1940 <- x
    }
}

#### Loop over 1930 file list, finding the EDs the touch the quarter and half mile buffers ####
for(i in files30){
  
  # City name 
  j <- str_split(i, "/")
  
  # Read in city-specific ED shapefile
  x <- read_sf(paste0(path30, i))
  
  # Dissolve by ed 
  x <- x %>%
    group_by(ed) %>%
    summarise(totalpop = max(totalpop),
              wpop = max(wpop),
              bpop = max(bpop))
  # Add city name to each ED 
  x <- x %>%
    mutate(city_name = j[[1]][1])
  
  # bind together the quarter mile EDs for a given development
  if(exists("ed1930")){
    ed1930 <- rbind(ed1930, x)
  }else{
    ed1930 <- x
  }
}

#### Transform ed1940 and ed1930 to Albers Equal Area #### 
ed1940 <- st_transform(ed1940, crs = st_crs(dev))
ed1930 <- st_transform(ed1930, crs = st_crs(dev))

#### Make ED geometries valid ####
ed1940 <- st_make_valid(ed1940)
ed1930 <- st_make_valid(ed1930)

#### Compute area of each ED
ed1940 <- ed1940 %>%
  mutate(ed_area = st_area(geometry))

ed1930 <- ed1930 %>%
  mutate(ed_area = st_area(geometry))

#### Buffer PH devs by 1/4 and 1/2 mile #### 
q_mile_dev <- dev %>%
  st_buffer(dist = quarter_mile)

h_mile_dev <- dev %>%
  st_buffer(dist = half_mile)

#### Select 1940 EDs that touch the 1/4 and 1/2 mile buffers #### 
# quarter mile and retains all EDs with value for site_name
q_mile_ed_1940 <- ed1940 %>%
  st_join(q_mile_dev) %>%
  filter(!is.na(site_name))

# half mile buffer onto ED shapes and retains all EDs with a value for site_name
h_mile_ed_1940 <- ed1940 %>%
  st_join(h_mile_dev) %>%
  filter(!is.na(site_name))    

#### Select 1930 EDs that touch the 1/4 and 1/2 mile buffers #### 
# quarter mile and retains all EDs with value for site_name
q_mile_ed_1930 <- ed1930 %>%
  st_join(q_mile_dev) %>%
  filter(!is.na(site_name))

# half mile buffer onto ED shapes and retains all EDs with a value for site_name
h_mile_ed_1930 <- ed1930 %>%
  st_join(h_mile_dev) %>%
  filter(!is.na(site_name))   

#### Use st_intersection to intersect buffers with ED shapes ####
dev_quarter_intersect_1940 <- st_intersection(q_mile_dev, q_mile_ed_1940) 
dev_quarter_intersect_1930 <- st_intersection(q_mile_dev, q_mile_ed_1930) 

dev_half_intersect_1940 <- st_intersection(h_mile_dev, h_mile_ed_1940) 
dev_half_intersect_1930 <- st_intersection(h_mile_dev, h_mile_ed_1930) 

#### Compute areas of intersection polygons #### 
dev_quarter_intersect_1940 <- dev_quarter_intersect_1940 %>%
  mutate(isct_area = st_area(geometry),
         p_over = (isct_area / ed_area) * 100)

dev_quarter_intersect_1930 <- dev_quarter_intersect_1930 %>%
  mutate(isct_area = st_area(geometry),
         p_over = (isct_area / ed_area) * 100)

dev_half_intersect_1940 <- dev_half_intersect_1940 %>%
  mutate(isct_area = st_area(geometry),
         p_over = (isct_area / ed_area) * 100)

dev_half_intersect_1930 <- dev_half_intersect_1930 %>%
  mutate(isct_area = st_area(geometry),
         p_over = (isct_area / ed_area) * 100)

#### Keep EDs that meet selection criteria #### 
# 1/4 mile buffer - 25% overlap
# 1/2 mile buffer - 50% overlap

dev_quarter_interect_25percent_1940 <- dev_quarter_intersect_1940 %>%
  mutate(p_over_n = as.numeric(p_over)) %>%
  filter(p_over_n >= 25.0)

dev_half_interect_50percent_1940 <- dev_half_intersect_1940 %>%
  mutate(p_over_n = as.numeric(p_over)) %>%
  filter(p_over_n >= 50.0)

dev_quarter_interect_25percent_1930 <- dev_quarter_intersect_1930 %>%
  mutate(p_over_n = as.numeric(p_over)) %>%
  filter(p_over_n >= 25.0)

dev_half_interect_50percent_1930 <- dev_half_intersect_1930 %>%
  mutate(p_over_n = as.numeric(p_over)) %>%
  filter(p_over_n >= 50.0)

#### Write out sfs to shps #### 
st_write(dev_quarter_interect_25percent_1940, paste0(path40, "quarter_mile_25percent_eds_1940.shp"), update = TRUE)
st_write(dev_half_interect_50percent_1940, paste0(path40, "half_mile_50percent_eds_1940.shp"), update = TRUE)
st_write(dev_quarter_interect_25percent_1930, paste0(path30, "quarter_mile_25percent_eds_1930.shp"), update = TRUE)
st_write(dev_half_interect_50percent_1930, paste0(path30, "half_mile_50percent_eds_1930.shp"), update = TRUE)

st_write(q_mile_ed_1940, paste0(path40, "quarter_mile_eds_1940.shp"), update = TRUE)
st_write(h_mile_ed_1940, paste0(path40, "half_mile_eds_1940.shp"), update = TRUE)
st_write(q_mile_ed_1930, paste0(path30, "quarter_mile_eds_1930.shp"), update = TRUE)
st_write(h_mile_ed_1940, paste0(path30, "half_mile_eds_1930.shp"), update = TRUE)