# ph-neighborhoods
This repository contains code used to create plots for the public housing neighborhood paper
that Ryan Allen, Catalina Anampa Castro, Corissa Marson, and I are writing. This paper is 
based on work done during the 2019 MPC Summer Diversity Fellowship and subsequent work
during AY2019-20.

## TODO list
- [ ] Verify the EDs in Atl, Mpls, Manhattan, and Philly relative to PH ed and neighborhood defn
      - [X] dissolve block shapes on aggr-id
      - [X] find the PH point shapefile
      - [X] overlay PH points with EDs
      - [ ] compare Logan EDs with scanned map and our FINAL dataset
        - [X] Mpls Sumner Homes
        - [X] Atl University Homes
        - [ ] Atl Techwood Homes 
            * 115, 112, and 113 are on map, in ED, and in list but not in FINAL dataset
            * 115, 112, and 113 are in Logan's GRF for Atl
        - [X] Phil Hill Creek - we have 1723 because of possible corner touch; Logan has it separated
        - [X] Manhattan Harlem Rivers 
            * we have 1907 and 1937 because of possible corner touches; Logan has it separated
            * Logan and list have 1951 but it's not in FINAL dataset
            * ED 1951 has no population in 1940 (not in GRF)
        - [ ] Manhattan First Houses
            * Logan's EDs look very, very, very different from the scanned map
- [ ] Map of cities in dataset - appendix?
- [ ] Illustrative example of scanned ED map showing ED of PH project and neighboring EDs
- [X] Neighborhood population (for each project) - total pop, white/black - appendix?
- [X] Public housing project population count and HH count - appendix? working on this now
- [ ] Inspect the public housing household counts to make sure they match prior counts (I'm worried about the serial issues)
  - Have issues with Santa Rita and Chalmers St. counts
  - 15 developments have a count difference between 2019 PAA abstract and v8 dataset, often off by 1 or two households, when using pernum == 1 as flag for HH 
  - HH count differences due to some individuals being re-classed as "fragment" in a PH household, but they were actually part of the PH household. These individuals get a pernum==1 in the data, even though they didn't in the past. When I filter by pernum==1, I get that extra "HH" from the fragment. I could change the code to work with unique serial? 
  - Changing to distinct(serial) and removing race1 from the group_by give me good HH counts (counts that match the PAA 2019 abstract)
  - But, there are still some oddities in the PH data (Jordan - same serial with multiple pernum == 1, which is okay for median income because all people with same serial get same household income); Newtowne - different serials for definitely the same household, but even the original data we used for flagging had different serials) - not okay for median income because one of the records has a unique serial with a pernum of 2 and an hhincome of 1250 
  - 5 records have serial_ct == 1 & pernum != to 1, and only one record (Newtown) has HH income
  - 20 records (9 hhs) have single serial number with multiple pernum == 1 values - all serials have same hhincome, so that is fine 
  
- [X] Median HH income plots (by race or region)
