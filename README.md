# paavodata
Get Statistics Finland Paavo-demographics and put them into a data frame

## Paavo data is described here
https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html

## Fetching and averaging Paavo data

`createPaavodata.R` collects data from all years and stores them into a list of data frames and stores the 
results into local directory.

## Results
a list consisting of data frames

### 

  - pono.level (2,3, or 5) indicates the aggreation level
  -  vuosi (year) the year of Paavo data. Note that the actual statistics is older - the year (statistics is from the end of year) is found in Statistics Finland documentation (and also in paavo.vars)

### counts

three summed / averaged version of the data ofr each year
 original areas (5 digits)
 areas based on 3 first and 2 first digits of the zip code

(Note the data frame contains also a few continuous variables such as average age or income, these are averaged not summed)
 
### proportions

The counts in `.$counts` normalised into proportions. The normalising variable is indicated in `.$paavo.var`.

(Note the data frame contains also a few continuous variables such as average age or income, these are averaged not summed)

### paavo.vars

## Plotting a zip code map

There is an example for plotting a map (using any of the aggregation levels) by `map_fi_zipcodeareas.R`

## Datafiles 

`pono_polygons_by_Duukkis_CCBY4.0_20150102.rds` (under Creative Commons CC BY 4.0) contains the zip code polygons from Duukkis http://www.palomaki.info/apps/pnro/ converted into a data frame that can be used by ggplot2 function `geom_polygon`. Cons: It lacks some of the newer zipcodes. Pros: the polygons are  reducted compared to the Statistics Finlans polygons that contain too detailed map of archipelago / lake area and makes rendering slow. 


