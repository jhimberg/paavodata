

# source("createPaavodata") get Paavo-data (should be in project directory anyway)
# 
# Initialise graph functions 
source("utilities.R")

## Set some variables 
paavo_year <- 2015
variable_code <- "he_kika"
variable_name <- filter(paavo$vars, koodi == variable_code)$nimi
variable_year <- paavo_year + filter(paavo$vars, koodi == variable_code)$paavo.vuosi.offset

# Example 1: Helsinki, viridis colorscale
select_(filter(paavo$counts, grepl("^00",pono) & pono_level == 5 & vuosi == paavo_year), "pono", variable_code) %>% 
  map_fi_postinumero(., title_label = paste(variable_year, variable_name, "(areas by zip codes)"), 
                     limits = c(10000, 65000), 
                     option="E")

# Example 2: Finland, a brewer colorscale, automatic limits 

select_(filter(paavo$counts, pono_level == 3 & vuosi == paavo_year), "pono", variable_code) %>% 
  map_fi_postinumero(., title_label = paste(variable_year, variable_name, "(areas by three first digits of the zipcodes)"),
                     colorscale = scale_fill_distiller, 
                     type="seq", 
                     palette="YlGnBu", 
                     direction = 1) 

# Example 3: as 1 but using ggirpah (interactice + tootips)

# Let's create the tooltip text for the selected variable
df <- filter(paavo$counts, grepl("^0", pono) & pono_level == 5 & vuosi == paavo_year) %>% 
  select_("pono", "nimi", variable_code)
df$tooltip = paste0(df$pono, " (", df$nimi, ") \nvalue = ", as.character(df[[variable_code]])) 
df <- select_(df, "pono", "tooltip", variable_code)

map_fi_postinumero_interactive(df, 
                                 title_label = paste(variable_year, variable_name, "(areas by zip codes)"),
                                 colorscale = scale_fill_distiller, 
                                 type="seq", 
                                 palette="YlGnBu",
                                 direction = -1) %>% 
  girafe(ggobj = .) %>% 
  girafe_options(x=., opts_zoom(min=.5, max=5))


