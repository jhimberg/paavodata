
# Create first Paavo-data 
# source("migrate_paavodata".R") 

# Initialise graph functions 
#source("utilities.R")

#paavo <- readRDS(here::here("paavodata.rds"))

#### Example 3: capital region, brewer colorscale (interactive)

#### Set some variables #### 
# Paavo year is the "version" of Paavo data. The actual statistical year varies depending on the attribute
paavo_year <- 2015
zip_digits <- 3

# paavo$vars contains info on the columns in data (have name variable_code)
variable_code <- "he_kika"
variable_name <- filter(paavo$vars, koodi == variable_code)$nimi

# Actual statistical year
variable_year <- paavo_year + filter(paavo$vars, koodi == variable_code)$paavo.vuosi.offset

# Pick data 
df <- filter(paavo$counts, 
             grepl("^3", pono) & 
               pono_level == zip_digits & 
               vuosi == paavo_year) %>% 
  select_("pono", variable_code)

# Create the tooltip text for the selected variable
df <- left_join(df, collapse_names(digits = zip_digits), by="pono") %>% 
  mutate(nimi = paste0(toupper(kunta), " \n", nimi))

df$tooltip <- paste0(df$pono, " ", df$nimi, " \nValue = ", as.character(round(df[[variable_code]], 1))) 
df <- select_(df, "pono", "tooltip", variable_code)

# Plot
map_fi_zipcode_interactive(df, 
                           title_label = paste(variable_year, variable_name, "\n (zip code areas:",  zip_digits, " digits)"),
                           map = as.character(paavo_year),
                           colorscale = scale_fill_distiller,
                           type = "seq", 
                           palette = "YlOrRd",
                           direction = 1) %>% 
  girafe(ggobj = .) %>% 
  girafe_options(x=., opts_zoom(min=.5, max=5))

