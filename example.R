

# source("createPaavodata") get Paavo-data (should be in project directory anyway)
# 
# Initialise graph functions 
source("utilities.R")

paavo <- readRDS(here::here("paavodata.rds"))

## Set some variables 

paavo_year <- 2018
variable_code <- "tr_ktu"
variable_name <- filter(paavo$vars, koodi == variable_code)$nimi
variable_year <- paavo_year + filter(paavo$vars, koodi == variable_code)$paavo.vuosi.offset

# approximate lat-long centerpoints for zip code areas (pono)
latlong <- group_by(postinumero_map, pono) %>% summarise(long=mean(long), lat=mean(lat))

# Example 1: Helsinki, viridis colorscale (paavo$counts => counts try also paavo$proportions)

df <- filter(paavo$counts, grepl("^00", pono) & pono_level == 5 & vuosi == paavo_year) %>%

map_fi_postinumero(df,
                   title_label = paste(variable_year, variable_name, "(areas by zip codes)"),
                   option = "B",
                   na.value = "white") + 
 
# Example 2: Helsinki, viridis colorscale + labels

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


# Example 3 capital region, PuBu colorscale, with tootip & collapsed area names 

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




