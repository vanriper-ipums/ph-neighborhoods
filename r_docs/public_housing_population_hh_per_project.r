# public_housing_population_hh_per_project.r
# Author: David Van Riper
# Date: 2020-06-16
# 
# This script generates a table with the population and HH count per public housing project and
# neighborhood. It uses FINAL_DATA_V8.dta to generate the counts

library(tidyverse)
library(haven)

#### Load data ####
df <- read_dta("/pkg/ancestryprojects/immigrant_public_housing/neighborhood/Catalina/A-NewData/FINAL_DATA_V8.dta")

#### Create list of dummy var names #### 
var_list <- names(df)

# keep variable names in positions 182 through 247 - those are the development-specific dummies
var_list<- var_list[182:247]

#### Create empty data frame to hold counts
persons_by_dev <- data.frame(ph_merge = as.numeric(),
                             race1 = as.numeric(),
                             persons = as.numeric(),
                             dev = as.character())

hh_by_dev <- data.frame(ph_merge = as.numeric(),
                        race1 = as.numeric(),
                        hh = as.numeric(),
                        dev = as.character())

#### Create development specific counts from df and var_list names ####
# Loop over all developments in var_list, creating counts of persons and households by race and
# ph_merge status (in neighborhood or in public housing)
# 
# Append each development specific count to a data frame, which can be used for further processing 

for(i in var_list){

  # Person by race by ph_merge status 
  z <- df %>%
    filter((!!sym(i)) == 1) %>%
    group_by(ph_merge, race1) %>%
    summarise(persons = n()) %>%
    mutate(dev = i)
  
  # Households by race by ph_merge status
  y <- df %>%
    filter(pernum==1)%>%
    filter((!!sym(i)) == 1) %>%
    group_by(ph_merge, race1) %>%
    summarise(hh = n()) %>%
    mutate(dev = i)
  
  # Append z df to persons_by_dev df 
  persons_by_dev <- bind_rows(persons_by_dev, z)
  
  # Append y df to hh_by_dev df 
  hh_by_dev <- bind_rows(hh_by_dev, y)
}


