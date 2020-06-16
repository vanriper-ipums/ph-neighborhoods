# public_housing_population_hh_per_project.r
# Author: David Van Riper
# Date: 2020-06-16
# 
# This script generates a table with the population and HH count per public housing project. It uses
# FINAL_DATA_V8.dta to generate the counts

library(tidyverse)
library(haven)

#### Load data ####
df <- read_dta("/pkg/ancestryprojects/immigrant_public_housing/neighborhood/Catalina/A-NewData/FINAL_DATA_V8.dta")

#### Notes on variables #### 
# ph_merge - flag for living in public housing (3) or living in neighborhood (1)
flag_vars <- c("smith",                      "patterson",                 "riverside",                  "fairfield",                  "langston",                  "brentwood",                  "durke",                      "edison",                    "liberty",                    "jordan",                     "techwood",                  "unihomes",                   "cherry",                     "olmstead",                  "jane",                       "julia",                      "trumbull",                  "lincoln",                    "lockerfield",                "bowman",                    "bluegrass",                  "ccourt",                     "LaSalle",                   "maryellen",                  "newtowne",                  "parkside",                  "brewster",                   "sumner",                     "sterrace",                  "logan",                      "ssholmes",                   "westfield",                 "pennington",                 "adcourts",                   "kenfield",                  "lakeview",                   "baker",                      "svillage",                  "pioneer",                    "williamsburg",               "rhook",                     "queen",                      "hrhouses",                   "fhouses",                   "laurel",                     "whitlock",                   "charles",                   "lterrace",                   "cedar",                      "owaite",                    "terrace",                    "willrogers",                 "hhomes",                    "hcreek",                     "mmanor",                     "rmanor",                    "uterrace",                   "ajcourts",                   "cheatham",                  "dixie",                      "lauderdale",                 "chalmers",                  "rosewood",                   "santa",                      "cedarspring",               "parklawn")
