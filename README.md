# paavodata

Get Statistics Finland "Paavo" demographics (https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html) and visualise them. There are migration scripts for getting data into a data frame, aggregation of data to larger geographical areas (2 and 3 first digits), and computing weighted proportions / averages for the counts.  

There are examples how to visualise the data by `ggplot` and preloaded maps (polygons) for zip code areas.

## Fetching and averaging Paavo data

`migrate_paavodata.R` collects data from Statistics Finland and stores them into a list of data frames and stores the results into local directory as a list consisting of data frames. Collects now data for 2015-2019. Adding new year is easy (see code) if the data format stays the same. 

  - original Paavo-data attributes are [!documented by Statistics Finland| https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html]
  - Additional attributes
    - Column `pono.level` (2,3, or 5) indicates the aggreation level
    -  `vuosi` (year) the year of Paavo data. Note that the actual statistics is older - the year (statistics is from the end of year) is found in Statistics Finland documentation (and also in paavo.vars)

Aggregation is weighted. The weighting attribute (usually total number of people) is found in `.$paavo.vars`.

Note: *Paavo data 2015-2016 have some variables like "average age" or "average income" =zero on zip code areas with no people.* Averaging (should) go right because of the weighting, but the value itself on 5 digit areas is of course, wrong, should be NA. *Paavo data 2019* lacks some attrbiutes in category PT (empolyment) that are present in 2015-208.

## Result Data frame fields

Output `paavo` contains the following fields
 - `.$data`
   - `pono_level == 5` is the original data
   - three aggregates version of the data for each year (experimental - use with caution!)
   - fields ending to `_osuus` contains original data divided by relevant total sum. The denominator is indicated in `.$vars` (experimental - use with caution!)
 Note: `ra_ke` is divided by `ra_ke`+`ra_raky`
 - `.$var` information on variables, normalisation and offset between the year (=version) of Paavo-data and the *actual year of data collection* for the variable.

Note: the data frame contains also a few continuous variables such as average age or income, these are averaged, not summed.

## Configuration files 

`map_and_names` contains some configuration and maps. 

### Variable explanations

The offsets, variable explanations, and attribute names are in `map_and_names/paavo.codes.txt` (EN) and in `map_and_names/paavo_koodit` (FI) This is an attempt to collect the information in https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html. Note that this partly configures the computation of the sums and averages, partly that is done hard-wired in the code. 

### Maps

`map_and_names` contains data frames that for drawing map of Finland divided into zip code areas.

*Postal code area boundaries, Statistics Finland The material was downloaded from Statistics Finland's interface service on Mar 3 2019, with the licence CC BY 4.0.*

In addition to data loading functions, `functions.R` contain example map plotting functions. They use polygons in `map_and_names/statfi_reduced_ziparea_map_20??.rds`. These are originally from the same source as the Paavo data (http://geo.stat.fi). The original shape files have been transformed into so reduced by resolution - and smallest island have been removed (see `map_and_names/statfi_reduced_ziparea_map_20??.rds`). The remaining polygons have been rewritten as a data frame that can be printed by `ggplot2::geom_polygon`. (The original shapefiles can be plotted using `geom_sf` which suits better for map data, however, at least with ggplot2 3.1.0 in OSX it has been considerably slower) 

`map_and_names/pono_polygons_by_Duukkis_CCBY4.0_20150102.rds` (under Creative Commons CC BY 4.0) are zip code polygons from Duukkis http://www.palomaki.info/apps/pnro/ that have been converted into a data frame that can be used by `ggplot2` function `geom_polygon`. 
  - Cons: It is inconsistent with some of the newer zipcode areas
  - Pros: the polygons are better reduced compared to the polygons that are in `statfi_reduced_ziparea_map_2015.rds`
  
### Commune/city numbers 

The number to name encoding of the communes and cities is in `map_and_names/kuntanumeromap2018.rds`.

## Examples

Take a look and run `example1.R`, `example2.R`, `example3.R`, and `example4.R` to see some plotting examples.
  


