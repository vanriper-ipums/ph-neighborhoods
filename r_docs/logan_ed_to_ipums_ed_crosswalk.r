# logan_ed_to_ipums_ed_crosswalk.r
# Author: David Van Riper
# Created: 2020-09-17
# 
# This script generates a crosswalk between Logan's ED values and IPUMS ED values

require(tidyverse)
require(sf)
require(lwgeom)

#### Dir paths ####
data_path <- "data/"

#### File names ####
first_order_ed_file <- "data/ph_ed_freqs_20200818_v9.csv"
dev_development_xwalk_file <- "data/dev_development_xwalk.csv"

#### Load CSVs #### 
first_order_ed_list <- read_csv(first_order_ed_file)
dev_development <- read_csv(dev_development_xwalk_file)

#### Load in the quarter mile 25% and half mile 50% EDs identified in ed_buffer_overlap.r ####
ed_quarter <- read_sf("data/shps/quarter_mile_25percent_eds.shp")
ed_half <- read_sf("data/shps/half_mile_50percent_eds.shp")

#### Join dev_development to first_order_ed_list #### 
first_order_ed_list <- first_order_ed_list %>%
  left_join(dev_development, by = c("dev" = "dev_names"))

#### Join (full join) between first_order_ed_list and ed_quarter #### 
ed_quarter_fj <- full_join(ed_quarter, first_order_ed_list, by = c("site_name"))

#### Remove records with no ph_site_id value #### 
# This gives me a list of all EDs that have 25% of their area in the quarter mile buffer, 
# and I can use this to create a crosswalk between Logan ED codes and IPUMS codes
ed_quarter_fj <- ed_quarter_fj %>%
  filter(!is.na(ph_site_id))

#### Convert ed_quarter_fj to a tbl #### 
ed_quarter_fj_tbl <- as_tibble(ed_quarter_fj)

#### Keep needed fields from tbl #### 
ed_quarter_fj_tbl <- ed_quarter_fj_tbl %>%
  select(-BUFF_DIST, -ORIG_FID, -ed_area, -isct_area, -p_over, -p_over_n, -geometry, -x, -y, -ID)

#### Convert Logan alpha chars to num and concatenate 0 #### 
ed_quarter_fj_tbl <- ed_quarter_fj_tbl %>%
  mutate(alpha_flag = case_when(grepl("[[:alpha:]]", ED_num) ~ 1,
                                TRUE ~ 0),
         ED_num_convert_char_to_num = ED_num,
         ED_num_convert_char_to_num = case_when(grepl("a", ED_num) ~ str_replace(ED_num_convert_char_to_num, "a", "1"),
                                                grepl("b", ED_num) ~ str_replace(ED_num_convert_char_to_num, "b", "2"),
                                                grepl("c", ED_num) ~ str_replace(ED_num_convert_char_to_num, "c", "3"),
                                                grepl("d", ED_num) ~ str_replace(ED_num_convert_char_to_num, "d", "4"),
                                                grepl("e", ED_num) ~ str_replace(ED_num_convert_char_to_num, "e", "5"),
                                                grepl("f", ED_num) ~ str_replace(ED_num_convert_char_to_num, "f", "6"),
                                                grepl("g", ED_num) ~ str_replace(ED_num_convert_char_to_num, "g", "7"),
                                                grepl("h", ED_num) ~ str_replace(ED_num_convert_char_to_num, "h", "8"),
                                                grepl("i", ED_num) ~ str_replace(ED_num_convert_char_to_num, "i", "9"),
                                                TRUE ~ ED_num_convert_char_to_num),
         ED_num_convert_char_to_num = case_when(alpha_flag == 0 ~ paste0(ED_num_convert_char_to_num, "0"),
                                                TRUE ~ ED_num_convert_char_to_num))

#### Flag records that use underscores in ED numbers #### 
ed_quarter_fj_tbl <- ed_quarter_fj_tbl %>%
  mutate(underscore_flag = case_when(grepl("_", enum_dist) ~ 1,
                                     TRUE ~ 0))

#### Split tbl into two parts based on underscore_flag ####
ed_quarter_fj_tbl_underscore <- ed_quarter_fj_tbl %>%
  filter(underscore_flag == 1)

ed_quarter_fj_tbl_dash <- ed_quarter_fj_tbl %>%
  filter(underscore_flag == 0)

#### Separate enum_dist into three parts #### 
# sup dist, separator, and ed value 
ed_quarter_fj_tbl_underscore <- ed_quarter_fj_tbl_underscore %>%
  separate(enum_dist, into = c("sup", "ed"), sep = "_", remove = FALSE)

ed_quarter_fj_tbl_dash <- ed_quarter_fj_tbl_dash %>%
  separate(enum_dist, into = c("sup", "ed"), sep = "-", remove = FALSE)

#### Compute new version of Logan ED #### 
ed_quarter_fj_tbl_underscore <- ed_quarter_fj_tbl_underscore %>%
  mutate(new_logan_ed = paste0(sup, "_", ED_num_convert_char_to_num))

ed_quarter_fj_tbl_dash <- ed_quarter_fj_tbl_dash %>%
  mutate(new_logan_ed = paste0(sup, "-", ED_num_convert_char_to_num))

#### Bind underscore and dash together ### 
ed_quarter_crosswalk <- bind_rows(ed_quarter_fj_tbl_dash, ed_quarter_fj_tbl_underscore)

#### Keep unique values of ph_site_id, msa_str, site_name, ED_num, statefip, countyicp, and new_logan_ed #### 
# This is what we will use to pull data from IPUMS complete-count 1940 data 
# Three developments have dupes in the unique crosswalk:
#  - Techwood has five dupes because of the underscore vs. dash issue
#  - Parklawn has three dupes because of the first order ED that is outside the city limits
#  - Liberty Square has one dupe because of the first order ED that is outside the city limits
#  * None of these would match with records in the microdata because of there are no records in the 
#    data with those ED numbers
ed_quarter_crosswalk_unique <- ed_quarter_crosswalk %>%
  distinct(ph_site_id, msa_str, site_name, ED_num, statefip, countyicp, new_logan_ed)

#### Keep records where enum_dist == new_logan_ed #### 
ed_quarter_crosswalk <- ed_quarter_crosswalk %>%
  filter(enum_dist == new_logan_ed) %>%
  select(-alpha_flag, -ED_num_convert_char_to_num, -underscore_flag, -sup, -ed)



