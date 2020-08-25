# neighborhood_size_comparison.r
# Author: David Van Riper
# Created: 2020-08-24
# 
# This script examines the neighborhood sizes for first order, 1/4 mile buffer, and 1/2 mile buffer
# around a public housing development. I use the geographic reference file (GRF) from John Logan's 
# Urban Historical Transition GIS project (https://s4.ad.brown.edu/Projects/UTP2/citymaps.htm) for the 
# 1/4 and 1/2 mile buffer neighborhood sizes and the IPUMS USA complete count data for the first order
# neighborhood sizes.
# 
# Problems:
# 1. GRF ED codes use upper case letters, and shapefiles use lower case letters
# 2. Birmingham - GRF has a 7a and 7b but the shapefile just has a 7
# 

require(tidyverse)
#require(haven)

#### Constants #### 
grf_ed_path <- "data/grf_ed_freqs/"
ed_buffer_path <- "data/ed_lists/"

# file names
quarter_mile_file <- "quarter_mile_eds.csv"
half_mile_file <- "half_mile_eds.csv"
first_order_file <- "data/ph_devshorthand_freqs_20200824_v9.csv"
first_order_ed_file <- "data/ph_ed_freqs_20200818_v9.csv"

#### Load files #### 
quarter_mile <- read_csv(paste0(ed_buffer_path, quarter_mile_file))
half_mile <- read_csv(paste0(ed_buffer_path, half_mile_file))
first_order <- read_csv(first_order_file)
first_order_ed <- read_csv(first_order_ed_file)


# GRF ED files
file_list <- list.files(grf_ed_path, pattern = "^ed")

for(i in file_list){
  j <- str_split(i, "\\.")
  
  df <- read_csv(paste0(grf_ed_path, i), col_types = "cci")
  
  # assign(j[[1]][1], df)
  if(exists("grf_ed_freq")){
    grf_ed_freq <- bind_rows(grf_ed_freq, df)
  }else{
    grf_ed_freq <- df
  }
  
}

rm(j)
rm(df)

#### Convert ED alpha characters to lowercase #### 
# Logan's various datasets have varying cases for alpha characters in ED numbers
grf_ed_freq <- grf_ed_freq %>%
  mutate(ed = tolower(B_ed))

#### Join grf_ed_freq to half and quarter mile files #### 
quarter_mile <- quarter_mile %>%
  left_join(grf_ed_freq, by = c("city" = "B_city", "ED_num" = "ed"))

half_mile <- half_mile %>%
  left_join(grf_ed_freq, by = c("city" = "B_city", "ED_num" = "ed"))

#### Create first_order neighborhood total #### 
first_order <- first_order %>%
  mutate(first_order_total = ph_1 + ph_3)