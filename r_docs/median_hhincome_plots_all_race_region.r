# median_hhincome_plots_all_race_region.r
# Author: David Van Riper
# Date: 2020-06-16
# 
# This script generates plots of median, 25th percentile, and 75th percentiles of household income by 
# geographic region (nationwide, northeast, midwest, and south), race of public housing project (black, 
# white, integrated), and scale (public housing development, neighborhood, and city).
# 
# This script generates single plots with all combinations of race and region (a 4 by 4 panel plot). 

library(tidyverse)
library(here)

#### Load data ####
df <- read_csv("data/ph_hhincome_20200616_v2.csv")

#### Prepare data ####
# create a long data frame and split apart ntile into region and ntile
df <- df %>%
  pivot_longer(p25_nation:p75_s, names_to = "temp", values_to = "estimate") %>%
  separate(temp, sep = "_", into = c("ntile", "region"))

# create factors from the variables 
df$race <- factor(df$race, levels = c("all", "white", "aa", "both"), labels = c("All", "White", "Black", "Integrated"))
df$scale <- factor(df$scale, levels = c("ph", "nb", "city"), labels = c("PH", "Nhood", "City"))
df$region <- factor(df$region, levels = c("nation", "ne", "mw", "s"), labels = c("Nation", "Northeast", "Midwest", "South"))
df$ntile <- factor(df$ntile, levels = c("p75", "p50", "p25"), labels = c("75th", "Median", "25th"))

#### Plot #### 
# Each row is a ph race and each column is a region 
region_by_race <- df %>% 
  ggplot(aes(x = scale, y = estimate)) +
  geom_point(aes(shape = ntile)) +
  facet_wrap(vars(race, region))

# Each row is a region and each column is a ph race
race_by_region <- df %>% 
  ggplot(aes(x = scale, y = estimate)) +
  geom_point(aes(shape = ntile)) +
  facet_wrap(vars(region, race))  

#### Save plots #### 
ggsave("figures/region_by_race.png", plot = region_by_race, width = 6, height = 6, units = "in")
ggsave("figures/race_by_region.png", plot = race_by_region, width = 6, height = 6, units = "in")
