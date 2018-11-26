library(ggplot2)
library(dplyr)
library(ggiraph)


map_fi_postinumero <- 
  function(df, title_label = NA, colorscale = scale_fill_viridis_c, ...) {
    # df: two columns from Paavo-data: pono and some data columns
    # title.label: string, deafault(NA) sets the variable name     
    # colorscale: colorscale function, default: scale_fill_viridis_c
    " ...: options for the colorscale"
    
   
    if (!exists("postinumero_map")) 
      postinumero_map <<- readRDS(file=here::here("pono_polygons_by_Duukkis_CC_BY4.0_20150102.rds"))
    
    if(dim(df)[2] != 2) stop("df must have two columns.")
    
    attr_to_plot <- setdiff(names(df), "pono") 
    if (!any(names(df) == "pono")) stop("There must be a field name 'pono': Finnish zipcodes. (2, 3, or all 5 numbers from the start.")
    
    df <- filter(df, !is.finite(pono))
    
    if (length(df$pono) != dim(df)[1]) stop("Zipcodes in 'pono' must be unique.")
    
    if(is.na(title_label)) title_label <- attr_to_plot
    
    N_digits_pono <- stringr::str_length(df$pono[1])
    
    pono_map <- 
      left_join(df, mutate(postinumero_map, pono = stringr::str_sub(pono, 1, N_digits_pono)), 
                by = c("pono"))
    
    p <- ggplot(data = arrange(pono_map, order), aes(x = long, y = lat)) + 
      geom_polygon(aes_string(fill = attr_to_plot, group = "group"), colour = NA) + 
      theme_void() +
      theme(legend.title = element_blank()) + 
      ggtitle(title_label)
    
    p <- p + colorscale(...)
    
    p <- p + coord_equal(ratio=2.1) 
    return(p)
  }


map_fi_postinumero_interactive <- 
  function(df, title_label = NA,  colorscale = scale_fill_viridis_c, ...) {
    # df: two columns from Paavo-data: 'pono' and some data column
    # title.label: string, deafault(NA) sets the variable name     
    # colorscale: colorscale function, default: scale_fill_viridis_c
    " ...: options for the colorscale"
    
    if (!exists("postinumero_map")) 
      postinumero_map <<- readRDS(file=here::here("pono_polygons_by_Duukkis_CC_BY4.0_20150102.rds"))
    
    if(dim(df)[2] != 3) stop("df must have three columns.")
    
    attr_to_plot <- setdiff(names(df), c("pono", "tooltip")) 
    if (!any(names(df) == "pono")) stop("There must be a field name 'pono': Finnish zipcodes. (2, 3, or all 5 numbers from the start.")
    if (!any(names(df) == "tooltip")) stop("There must be a field name 'tooltip': tootip text for each  zipcodes (2, 3, or all 5 numbers from the start.")
    
    df <- filter(df, !is.finite(pono))
    
    if (length(df$pono) != dim(df)[1]) stop("Zipcodes in 'pono' must be unique.")
    
    if(is.na(title_label)) title_label <- attr_to_plot
    
    N_digits_pono <- stringr::str_length(df$pono[1])
    
    pono_map <- 
      left_join(df, mutate(postinumero_map, pono = stringr::str_sub(pono, 1, N_digits_pono)), 
                by = c("pono"))
    
    p <- ggplot(data = arrange(pono_map, order), aes(x = long, y = lat)) + 
      geom_polygon_interactive(aes_string(fill = attr_to_plot, group = "group", tooltip="tooltip"), colour = NA) + 
      theme_void() +
      theme(legend.title = element_blank()) + 
      ggtitle(title_label)
    
    p <- p + colorscale(...)
    
    p <- p + coord_equal(ratio=2.1) 
    return(p)
  }


paavo_diff <- function(paavo_df, years = c(2018, 2015)) {
  # paavo.df is a Paavo data frame from createPaavodata
  # The function returns difference between years: default is 2018-2015
  # vuosi variable will contain the years from which differences are computed 
  # eg. 2018-2015

  diff_attributes <- setdiff(paavo$vars$koodi, c("nimi", "pono", "vuosi", "euref_x", "euref_y", "kuntano")) 
  
  paavo <- paavo.df %>%
    group_by(pono, pono.level) %>%
    arrange(vuosi) %>%
    filter(vuosi %in% years) %>%
    mutate_at(vars(diff_attributes), funs(. - lag(.))) %>%
    mutate(diff = paste0(vuosi, "-", lag(vuosi))) %>%
    filter(vuosi > min(years)) %>%
    ungroup
  
  return(paavo)
}



