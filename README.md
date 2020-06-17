# ph-neighborhoods
This repository contains code used to create plots for the public housing neighborhood paper
that Ryan Allen, Catalina Anampa Castro, Corissa Marson, and I are writing. This paper is 
based on work done during the 2019 MPC Summer Diversity Fellowship and subsequent work
during AY2019-20.

## TODO list
- [] Map of cities in dataset - appendix?
- [] Illustrative example of scanned ED map showing ED of PH project and neighboring EDs
- [X] Neighborhood population (for each project) - total pop, white/black - appendix?
- [X] Public housing project population count and HH count - appendix? working on this now
- [] Inspect the public housing household counts to make sure they match prior counts (I'm worried about the serial issues)
  - Have issues with Santa Rita and Chalmers St. counts
  - 15 developments have a count difference between 2019 PAA abstract and v8 dataset, often off by 1 or two households
  - HH count differences due to some individuals being re-classed as "fragment" in a PH household, but they were actually part of the PH household. These individuals get a pernum==1 in the data, even though they didn't in the past. When I filter by pernum==1, I get that extra "HH" from the fragment. I could change the code to work with unique serial? 
  - Changing to distinct(serial) leaves me with 3 of the 15 developments that have mismatches (Lakeview, Red Hook, and Queensbridge). But, I think I've added in mismatches now because of the change.
- [X] Median HH income plots (by race or region)
