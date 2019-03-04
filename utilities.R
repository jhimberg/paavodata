library(here)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(ggiraph)

# kuntano is the official number of the city/commune (kunta)
# this function maps it to the name (valid on 2018)

fi_commune_number2name <- function(kuntano) {
  if (!exists("kuntano2name")) 
    kuntano2name <<- readRDS(file=here::here("map_and_names", "kuntanumeromap2018.rds"))
  
  plyr::mapvalues(as.integer(kuntano), 
                  as.integer(kuntano2name$kuntano.old), 
                  kuntano2name$kunta, 
                  warn_missing = FALSE) %>% 
    iconv(.,to="UTF-8") %>% return
}

# produces names for aggregated areas 
collapse_names <- function(digits = 3, df = paavo$counts) 
  filter(df, pono_level == 5) %>% 
  select(pono, kuntano, vuosi, nimi) %>% 
  mutate(kunta = fi_commune_number2name(kuntano), 
         pono = str_sub(pono, 1, digits)) %>% 
  group_by(pono, vuosi) %>% 
  summarise(kunta = paste(sort(unique(kunta)), collapse = ", "), 
            nimi = paste(sort(unique(nimi)), collapse = ", "))

zip_code_map <- function(map_name = "2019") {
# Load the zip code area map polygon files to a list of dataframes and return a dataframe 

  if (!(map_name %in% c("2015", "2016", "2017", "2018", "2019", "duukkis"))) stop("Map does not exist.")
  
  if (!exists("zipcode_maps")) {
    zipcode_maps <<- list()
    zipcode_maps[["duukkis"]] <<- readRDS(file=here::here("map_and_names", "pono_polygons_by_Duukkis_CC_BY4.0_20150102.rds"))
    zipcode_maps[["2015"]] <<- readRDS(file=here::here("map_and_names", "statfi_reduced_ziparea_map_2015.rds"))
    zipcode_maps[["2016"]] <<- readRDS(file=here::here("map_and_names", "statfi_reduced_ziparea_map_2016.rds"))
    zipcode_maps[["2017"]] <<- readRDS(file=here::here("map_and_names", "statfi_reduced_ziparea_map_2017.rds"))
    zipcode_maps[["2018"]] <<- readRDS(file=here::here("map_and_names", "statfi_reduced_ziparea_map_2018.rds"))
    zipcode_maps[["2019"]] <<- readRDS(file=here::here("map_and_names", "statfi_reduced_ziparea_map_2019.rds"))
  }
  
  zipcode_maps[[map_name]]
}
  
map_fi_zipcode <- 
  function(df, title_label = NA, map = "2019", colorscale = scale_fill_viridis_c, ...) {
    # df: two columns from Paavo-data: pono and some data columns
    # title_label: string, deafault(NA) sets the variable name   
    # map: "duukkis", "2015", "2016", "2017", "2018", or "2019" (default) or a polygon data frame 
    # colorscale: colorscale function, default: scale_fill_viridis_c
    " ...: options for the colorscale"
    
    # Get a map 
    if (class(map) == "character") {
      if (map == "duukkis") lat_long_ratio <- 2.1 else lat_long_ratio <- 1.0 
      map <- zip_code_map(map) }
    else
      if (class(map) == "data.frame") 
        lat_long_ratio <- 1.0
      else
        stop("Must be a string or a (polygon) data frame") 
    
    
    if(dim(df)[2] != 2) stop("df must have two columns.")
    
    attr_to_plot <- setdiff(names(df), "pono") 
    if (!any(names(df) == "pono")) stop("There must be a field name 'pono': Finnish zipcodes. (2, 3, or all 5 numbers from the start.")
    
    df <- filter(df, !is.finite(pono))
    
    if (length(df$pono) != dim(df)[1]) stop("Zipcodes in 'pono' must be unique.")
    
    if(is.na(title_label)) title_label <- attr_to_plot
    
    N_digits_pono <- stringr::str_length(df$pono[1])
    
    pono_map <- 
      left_join(df, mutate(map, pono = stringr::str_sub(pono, 1, N_digits_pono)), 
                by = c("pono"))
    
    p <- ggplot(data = pono_map, aes(x = long, y = lat)) + 
      geom_polygon(aes_string(fill = attr_to_plot, group = "group"), colour = NA) + 
      theme_void() +
      theme(legend.title = element_blank()) + 
      ggtitle(title_label)
    
    p <- p + colorscale(...)
    
    p <- p + coord_equal(ratio = lat_long_ratio) 
    return(p)
  }

map_fi_zipcode_interactive <- 
  function(df, title_label = NA, map = "2019", colorscale = scale_fill_viridis_c, ...) {
    # df: two columns from Paavo-data: 'pono' and some data column
    # title.label: string, deafault(NA) sets the variable name     
    # colorscale: colorscale function, default: scale_fill_viridis_c
    " ...: options for the colorscale"
    
    # Get a map 
    if (class(map) == "character") {
      if (map == "duukkis") lat_long_ratio <- 2.1 else lat_long_ratio <- 1.0 
      map <- zip_code_map(map) }
    else
      if (class(map) == "data.frame") 
        lat_long_ratio <- 1.0
      else
        stop("Must be a string or a (polygon) data frame") 
      
    if(dim(df)[2] != 3) stop("df must have three columns.")
    
    attr_to_plot <- setdiff(names(df), c("pono", "tooltip")) 
    if (!any(names(df) == "pono")) stop("There must be a field name 'pono': Finnish zipcodes. (2, 3, or all 5 numbers from the start.")
    if (!any(names(df) == "tooltip")) stop("There must be a field name 'tooltip': tootip text for each  zipcodes (2, 3, or all 5 numbers from the start.")
    
    df <- filter(df, !is.finite(pono))
    
    if (length(df$pono) != dim(df)[1]) stop("Zipcodes in 'pono' must be unique.")
    
    if(is.na(title_label)) title_label <- attr_to_plot
    
    N_digits_pono <- stringr::str_length(df$pono[1])
    
    pono_map <- 
      left_join(df, mutate(map, pono = stringr::str_sub(pono, 1, N_digits_pono)), 
                by = c("pono"))
    
    p <- ggplot(data = pono_map, aes(x = long, y = lat)) + 
      geom_polygon_interactive(aes_string(fill = attr_to_plot, group = "group", tooltip="tooltip"), colour = NA) + 
      theme_void() +
      theme(legend.title = element_blank()) + 
      ggtitle(title_label)
    
    p <- p + colorscale(...)
    
    p <- p + coord_equal(ratio = lat_long_ratio) 
    return(p)
  }


