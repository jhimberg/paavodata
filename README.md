# paavodata
Get Statistics Finland Paavo-demographics into a data frame. Aggregates to larger geographical areas (2 and 3 first digits) and computes proportions from the counts.

Data: https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html

## Fetching and averaging Paavo data

`createPaavodata.R` collects data from all years and stores them into a list of data frames and stores the 
results into local directory as a list consisting of data frames. 

  - original Paavo-data attributes are documented by Statistics Finland https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html
  - Additional attributes
    - Column `pono.level` (2,3, or 5) indicates the aggreation level
    -  `vuosi` (year) the year of Paavo data. Note that the actual statistics is older - the year (statistics is from the end of year) is found in Statistics Finland documentation (and also in paavo.vars)

Aggredation is weighted. The weighting attribute (usually total number of people) is found in `.$paavo.vars`.

### Result Data frame fields

Output contains the following fields
 - `.$counts`
   - original data for `pono.level == 5`
   - three aggredates version of the data for each year
 - `.$proportions` contains `.$counts` normalised into proportions. The normalising variable is indicated in `.$paavo.vars`  
 - `.$paavo.var` information on variables, normalisation and offset between the year (=version) of Paavo-data and the *actual year of data collection* for the variable

Note: the data frame contains also a few continuous variables such as average age or income, these are averaged not summed

## Map

There is an example (`utilities.R`) for plotting a map (using any of the aggregation levels) by `map_fi_zipcodeareas.R` using polygons in `pono_polygons_by_Duukkis_CCBY4.0_20150102.rds` (under Creative Commons CC BY 4.0). The zip code polygons from Duukkis http://www.palomaki.info/apps/pnro/ have been converted into a data frame that can be used by ggplot2 function `geom_polygon`. 

  - Cons: It lacks some of the newer zipcodes. 
  - Pros: the polygons are reducted compared to the polygons that comes with Paavo-data: they contain a detailed map of archipelago / lake area and make rendering slow. 


