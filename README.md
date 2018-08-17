# paavodata
Get Statistics Finland Paavo-demographics and put them into a data frame

## Paavo data is described here
https://www.stat.fi/tup/paavo/paavon_aineistokuvaukset_en.html

## R code

`creaatePaavodata.R` collects data from all years and stores them into a list of data frames and stores the 
results into local directory.

## Results
a list consisting of data frames
### counts

three summed/ averaged version of the data ofr each year
 original areas (5 digits)
 areas based on 3 first and 2 first digits of the zip code

(Note the data frame contains also a few continuous variables such as average age or income, these are averaged not summed)
 
### proportions

The counts in `$counts` normalised into proportions. The normalising variable is indicated in `$paavo.var`.

(Note the data frame contains also a few continuous variables such as average age or income, these are averaged not summed)