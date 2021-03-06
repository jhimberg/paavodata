
# Create first Paavo-data if not done yet

if (!file.exists("paavodata.rds")) 
  source("migrate_paavodata.R") 

# Make graph and other functions 
source("functions.R")

paavo <- readRDS(here::here("paavodata.rds"))

#### Example 1: Helsinki, viridis colorscale 

#### Set some variables #### 

# Paavo year is the "version" of Paavo data. The actual statistical year varies depending on the attribute
paavo_year <- 2019
zip_digits <- 5

# paavo$vars contains info on the columns in data (have name variable_code)

variable_code <- "ko_yl_kork_osuus"
variable_name <- filter(paavo$vars, koodi == variable_code)$name

# Actual statistical year
variable_year <- paavo_year + filter(paavo$vars, koodi == variable_code)$paavo.vuosi.offset

# Get the selected varibale for selected year - and coordinates for labels 

df <- filter(paavo$data, 
             grepl("^00", pono) & 
               pono_level == zip_digits & 
               vuosi == paavo_year) %>%
  select(one_of(c("pono", variable_code, "nimi", "euref_x", "euref_y")))

df_data <- select(df, -nimi, -euref_x, -euref_y)

p <- map_fi_zipcode(df_data, title_label = paste(variable_year, variable_name, "(areas by zip codes)")) 
 
# Add names

p + geom_text(data=df, aes(x = euref_x, y = euref_y, label = nimi),
              size = 3, 
              color = "grey50")

