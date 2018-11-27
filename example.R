

# Create first Paavo-data 
# source("createPaavodata.R") 

# Initialise graph functions 
source("utilities.R")

paavo <- readRDS(here::here("paavodata.rds"))

## Set some variables 

# Paavo year is the "version" of Paavo data. The actual statistical year varies depending on the attribute
paavo_year <- 2018

# paavo$vars contains info on the columns in data (have name variable_code)
variable_code <- "tr_ktu"
variable_name <- filter(paavo$vars, koodi == variable_code)$nimi

# Actual statistical year
variable_year <- paavo_year + filter(paavo$vars, koodi == variable_code)$paavo.vuosi.offset

# Approximate lat-long centerpoints for zip code areas (pono) (for labelling)
# the Paavo data contains coords on a different coordinate system
latlong <- group_by(postinumero_map, pono) %>% summarise(long=mean(long), lat=mean(lat))

#### Example 1: Helsinki, viridis colorscale (paavo$counts => counts try also paavo$proportions)

df <- filter(paavo$counts, grepl("^00", pono) & pono_level == 5 & vuosi == paavo_year) %>%

map_fi_postinumero(df,
                   title_label = paste(variable_year, variable_name, "(areas by zip codes)"),
                   option = "B",
                   na.value = "white") + 
 
#### Example 2: Helsinki, viridis colorscale + labels

df <- filter(paavo$counts, grepl("^00", pono) & pono_level == 5 & vuosi == paavo_year) %>%
  select_("pono", variable_code, "nimi") %>%
  left_join(., latlong, by = "pono")

select_(df, "pono", variable_code) %>%
  map_fi_postinumero(.,
                     title_label = paste(variable_year, variable_name, "(areas by zip codes)"),
                     option = "B",
                     na.value = "white") + 
  geom_text(data=df, aes(x = long, y = lat, label = nimi), 
            size=3, 
            color="grey50", 
            angle=10)

#### Example 3: capital region, brewer colorscale

# Let's create the tooltip text for the selected variable
df <- filter(paavo$counts, grepl("^00|^01|^02", pono) & pono_level == 5 & vuosi == paavo_year) %>% 
  select_("pono", "nimi", variable_code)
df$tooltip = paste0(df$pono, " (", df$nimi, ") \nvalue = ", as.character(df[[variable_code]])) 
df <- select_(df, "pono", "tooltip", variable_code)

map_fi_postinumero_interactive(df, 
                                 title_label = paste(variable_year, variable_name, "(areas by zip codes)"),
                                 colorscale = scale_fill_distiller, 
                                 type="seq", 
                                 palette="YlOrRd",
                                 direction = 1) %>% 
  girafe(ggobj = .) %>% 
  girafe_options(x=., opts_zoom(min=.5, max=5))




