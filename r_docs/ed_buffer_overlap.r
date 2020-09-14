# ed_buffer_overlap.r
# Author: David Van Riper
# Created: 2020-09-13
# 
# This script generates buffers around public housing devs, intersects those buffers with ED polygons,
# and then determines whether the ED should be included in the public housing neighborhood.
# 
# For the 1/4 mile buffer, we will keep EDs if 25% or more of the ED's area is in the buffer. 
# 
# For the 1/2 mile buffer, we will keep EDs if 50% or more of the ED's area is in the buffer. 
# 
# It uses the public housing development point shapefile created by David Van Riper and
# the 1940 ED shapefiles created by the Urban Transition Historical GIS project at Brown Uniersity. 
# 
# Documentation about the 1940 ED shapefiles can be found at https://s4.ad.brown.edu/Projects/UTP2/citymaps.htm

require(tidyverse)
require(sf)
require(lwgeom)

#### Constants #### 
#file_path <- "data/shps/ed/"
# the 1/4 and 1/2 mile buffers are in meters
#quarter_mile <- 402.336
#half_mile <- 804.672

#### Read in PH development point shapefile ####
dev_quarter <- read_sf("data/shps/developments/ph_site_developments_albers_quarter_mile_buffer.shp")
dev_half <- read_sf("data/shps/developments/ph_site_developments_albers_half_mile_buffer.shp")

#### Read in the ED shapefile #### 
ed <- read_sf("data/shps/ed_dissolve/ed_num_1940.shp")

#### Compute area of ED #### 
ed <- ed %>%
  mutate(ed_area = st_area(geometry))

#### Make ED geometries valid ####
ed_valid <- st_make_valid(ed)

#### Use st_intersection to intersect buffers with ED shapes ####
dev_quarter_intersect <- st_intersection(dev_quarter, ed_valid) 

dev_half_intersect <- st_intersection(dev_half, ed_valid) 

#### Compute areas of intersection polygons #### 
dev_quarter_intersect <- dev_quarter_intersect %>%
  mutate(isct_area = st_area(geometry),
         p_over = (isct_area / ed_area) * 100)

dev_half_intersect <- dev_half_intersect %>%
  mutate(isct_area = st_area(geometry),
         p_over = (isct_area / ed_area) * 100)

#### Keep EDs that meet selection criteria #### 
# 1/4 mile buffer - 25% overlap
# 1/2 mile buffer - 50% overlap

dev_quarter_interect_25percent <- dev_quarter_intersect %>%
  mutate(p_over_n = as.numeric(p_over)) %>%
  filter(p_over_n >= 25.0)

dev_half_interect_50percent <- dev_half_intersect %>%
  mutate(p_over_n = as.numeric(p_over)) %>%
  filter(p_over_n >= 50.0)

#### Write out intersected EDs to shapefile #### 
st_write(dev_quarter_interect_25percent, "data/shps/quarter_mile_25percent_eds.shp")
st_write(dev_half_interect_50percent, "data/shps/half_mile_50percent_eds.shp")

