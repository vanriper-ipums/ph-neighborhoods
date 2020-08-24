# verify_eds_V9.r
# Author: David Van Riper
# Created: 2020-08-18
# 
# This script compares the ED csv files that we created in July 2019 to see how they differ. I expect to 
# find discrepancies between the two files. 
# 
# The script also generates a list of EDs currently in the V9 analytical dataset. I want to cross-ref that
# list against the ED csv files (and eventually againt Logan's GRF file).

require(tidyverse)
require(readxl)
require(haven)

#### File paths ####
# ED csv path 
path_ed_csv <- "/pkg/ancestryprojects/immigrant_public_housing/neighborhood/Cori/"
# Analytical dataset path 
path_dataset <- "/pkg/ancestryprojects/immigrant_public_housing/neighborhood/Catalina/A-NewData/"

#### Read in ED CSVs ####
no_dups_ipums <- read_xlsx(paste0(path_ed_csv, "NoDupsIPUMS.xlsx"))
no_dups_orig <- read_xlsx(paste0(path_ed_csv, "NoDupsOrig.xlsx"))

#### Read in analytical DTA ####
v9 <- read_dta(paste0(path_dataset, "FINAL_DATA_V9.dta"))

#### Drop extraneous fields from dfs #### 
no_dups_ipums <- no_dups_ipums %>%
  select(-...1, -n, -num)

no_dups_orig <- no_dups_orig %>%
  select(-...1, -n, -num)

#### Full join between orig and ipums to examine missings #### 
no_dups_fj <- full_join(no_dups_orig, no_dups_ipums, by=c("ED" = "OrigED"))

#### Missing from no_dups_ipums #### 
# There are three records in missing_no_dups_ipums df - all Techwood Homes EDs
missing_no_dups_ipums <- no_dups_fj %>%
  filter(is.na(development.y))

#### Missing from no_dups_orig #### 
# Every record in no_dups_orig has a match in no_dups_ipums
missing_no_dups_orig <- no_dups_fj %>%
  filter(is.na(development.x))

#### Create ED list from existing analytical dataset #### 
# Keep required variables to generate the list - statefip, OrigED, IPUMSED, enum_dist
v9_ed <- v9 %>%
  select(statefip, countyicp, OrigED, IPUMSED, enum_dist)

# Are there any NAs in the v8_ed variables 
# No - every record has four values 
table(is.na(v9_ed$statefip))

# Create ed freqs for each of the three ED fields in v8_ed
# 561 records
v9_origed_freq <- v9_ed %>%
  group_by(statefip, OrigED) %>%
  summarise(freq = n())

# 550 records
v9_ipumsed_freq <- v9_ed %>%
  group_by(statefip, IPUMSED) %>%
  summarise(freq = n())

# 572 records
v9_enumdist_freq <- v9_ed %>%
  group_by(statefip, enum_dist) %>%
  summarise(freq = n())

#### Testing out some joins ####
# IPUMSED and enum_dist are similar to one another; OrigED is very, very different!
# Left join ipumsed on to enumdist 
lj_ipumsed_onto_enumdist <- left_join(v9_enumdist_freq, v9_ipumsed_freq, by = c("enum_dist" = "IPUMSED", "statefip" = "statefip"))

# How many lj_ipumsed_onto_enumdist have different freqs? 
# - only 3 eds have totally different freqs, not including NAs for ipumsed freq
# -- 1-68-51, 1-68-52, and 40-24-172
# For the 40-24-172, there is no such value in IPUMSED (there is an IPUMSED 170 that isn't in enum_dist)
lj_ipumsed_onto_enumdist_diff_freqs <- lj_ipumsed_onto_enumdist %>%
  filter(freq.x != freq.y)

# How many lj_ipumsed_onto_enumdist have an NA value for freq.y (IPUMSED count)?
# - 45 records meet this selection criterion
# - Looks like lots will be 1/2 subs for A/B, but some will be new EDs that we missed first time around 
# (e.g. fixed the Jacksonville Durkeeville nhood; added the one ED to the Milwaukee dev;
#  added some extra EDs to other devs)
lj_ipumsed_onto_enumdist_isna_freqy <- lj_ipumsed_onto_enumdist %>%
  filter(is.na(freq.y))

#### Create enum_dist freqs by project (using the dummy vars) #### 
# Get names of v8 df 
v9_names <- names(v9)

# keep only dev names from v8_names
dev_names <- v9_names[183:248]

# create empty df to put results into
df <- data.frame(statefip = as.numeric(),
                 countyicp = as.numeric(),
                 enum_dist = as.character(),
                 dev = as.character(),
                 ph_merge = as.numeric(),
                 freq = as.numeric(), stringsAsFactors = FALSE)

# loop over vars in dev_names, computing freqs by enum_dist and ph_merge, and storing results in df
for(i in dev_names){
  x <- v9 %>%
    filter(get(i) == 1) %>%
    group_by(statefip, countyicp, enum_dist, ph_merge) %>%
    summarise(freq = n()) %>%
    mutate(dev = i)
  
  df <- bind_rows(df, x)
}

# create a wide version of df 
df_wide <- df %>%
  pivot_wider(id_cols = statefip:ph_merge, names_from = ph_merge, values_from = freq, names_prefix = "ph_")

# write out ED list to CSV
write_csv(df_wide, "data/ph_ed_freqs_20200818_v9.csv")

# create empty df to put results into - generate a crosswalk between development name and 
# catalina short hand
df <- data.frame(
                 dev = as.character(),
                 development = as.character(),
                 ph_merge = as.numeric(),
                 freq = as.numeric(), stringsAsFactors = FALSE)

# loop over vars in dev_names, computing freqs by enum_dist and ph_merge, and storing results in df
for(i in dev_names){
  x <- v9 %>%
    filter(get(i) == 1) %>%
    group_by(development, ph_merge) %>%
    summarise(freq = n()) %>%
    mutate(dev = i)
  
  df <- bind_rows(df, x)
}

# create a wide version of df 
df_wide <- df %>%
  pivot_wider(id_cols = dev:ph_merge, names_from = ph_merge, values_from = freq, names_prefix = "ph_") %>%
  filter(development != "")

# write out ED list to CSV
write_csv(df_wide, "data/ph_devshorthand_freqs_20200824_v9.csv")