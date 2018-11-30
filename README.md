# paavodata
Get Statistics Finland Paavo-demographics into a data frame. Aggregates to larger geographical areas (2 and 3 first digits) and computes proportions from the counts.

Data: https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html

## Fetching and averaging Paavo data

`createPaavodata.R` collects data from Statistics Finland and stores them into a list of data frames and stores the 
results into local directory as a list consisting of data frames. Collects now data for 2015-2018. Adding new year is easy (see code) if the data format stays the same. 

  - original Paavo-data attributes are documented by Statistics Finland https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html
  - Additional attributes
    - Column `pono.level` (2,3, or 5) indicates the aggreation level
    -  `vuosi` (year) the year of Paavo data. Note that the actual statistics is older - the year (statistics is from the end of year) is found in Statistics Finland documentation (and also in paavo.vars)

Aggregation is weighted. The weighting attribute (usually total number of people) is found in `.$paavo.vars`.

Note: *Paavo data 2015-2016 have some variables like "average age" or "average income" =zero on zip code areas with no people.* Averaging (should) go right because of the weighting, but the value itself on 5 digit areas is of course, wrong, should be NA. 

## Result Data frame fields

Output `paavo` contains the following fields
 - `.$counts`
   - original data for `pono.level == 5`
   - three aggregates version of the data for each year (use with caution!)
 - `.$proportions` contains `.$counts` divided by total sum into proportions. The denominator is indicated in `.$paavo.vars`. 
 Note: `ra_ke` is divided by `ra_ke`+`ra_raky`. Use with caution!
 - `.$paavo.var` information on variables, normalisation and offset between the year (=version) of Paavo-data and the *actual year of data collection* for the variable.

Note: the data frame contains also a few continuous variables such as average age or income, these are averaged, not summed.

## Some additional configuration files 

### Variable explanations

The offsets, variable explanations, and attribute names are in `map_and_names/paavo.koodit.txt`. This is an attempt to collect the information in https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html . Note that this partly configures the computation of the sums and averages, partly that is done hard-wired in the code. 

### Map

There are example functions in `utilities.R` for plotting a map using any of the aggregation levels. They use polygons in `map_and_names/pono_polygons_by_Duukkis_CCBY4.0_20150102.rds` (under Creative Commons CC BY 4.0). The zip code polygons from Duukkis http://www.palomaki.info/apps/pnro/ have been converted into a data frame that can be used by ggplot2 function `geom_polygon`. 

  - Cons: It lacks some of the newer zipcodes. 
  - Pros: the polygons are reducted compared to the polygons that comes with Paavo-data: they contain a detailed map of archipelago / lake area and make rendering slow. 
  
### Commune/city numbers 

The number to name encoding of the communes and cities is in `map_and_names/kuntanumeromap2018.rds`.

## Examples

Take a look and run `example.R` to see some plotting examples.
  


