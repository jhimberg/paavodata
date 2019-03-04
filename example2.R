
# Create first Paavo-data 
# source("migrate_paavodata".R") 

# Initialise graph functions 
source("utilities.R")

paavo <- readRDS(here::here("paavodata.rds"))

#### Example 2: Helsinki, "duukkkis" polygons (2015), viridis colorscale + labels

#### Set some variables #### 
# Paavo year is the "version" of Paavo data. The actual statistical year varies depending on the attribute
paavo_year <- 2015
zip_digits <- 5

# paavo$vars contains info on the columns in data (have name variable_code)
variable_code <- "tr_ktu"
variable_name <- filter(paavo$vars, koodi == variable_code)$nimi

# Actual statistical year
variable_year <- paavo_year + filter(paavo$vars, koodi == variable_code)$paavo.vuosi.offset

# For "duukkis" map the 
# approximate lat - long centerpoints for zip code areas (pono) (for labelling) are computed from map since
# it has different coord. system

latlong <- group_by(postinumero_map, pono) %>% 
  summarise(long = mean(long), lat = mean(lat))

df <- filter(paavo$counts, grepl("^00", pono) & pono_level == zip_digits & vuosi == paavo_year) %>%
  select_("pono", variable_code, "nimi") %>%
  left_join(., latlong, by = "pono")

select_(df, "pono", variable_code) %>%
  map_fi_zipcode(.,
                 title_label = paste(variable_year, variable_name, "(areas by zip codes)"),
                 map="duukkis", 
                 colorscale = scale_fill_distiller,
                 type = "seq", 
                 palette = "YlOrRd",
                 direction = 1) + 
  geom_text(data = df, aes(x = long, y = lat, label = nimi), 
            size = 3, 
            color = "grey50", 
            angle = 10)

