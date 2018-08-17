library(ggplot2)
library(dplyr)

map_fi_postinumero <- 
  function(df, title.label = NA, viridis.option = "E", color.limits = c(NA,NA)) {
    
   if (!exists("postinumero.map")) 
     postinumero.map <<- readRDS(file=here::here("pono_polygons_by_Duukkis_CC_BY4.0_20150102.rds"))
   
   if(dim(df)[2] != 2) stop("df must have two columns.")
   
   attr.to.plot <- setdiff(names(df), "pono") 
   if (!any(names(df) == "pono")) stop("There must be a field 'pono': Finnish zipcodes. (2, 3, or all 5 numbers from the start.")
   
   df <- filter(df, !is.finite(pono))
   
   if (length(df$pono) != dim(df)[1]) stop("'pono' values must be unique.")
   
   if(is.na(title.label)) title.label <- attr.to.plot
   
   N.digits.pono <- stringr::str_length(df$pono[1])
   
   pono.map <- 
     left_join(df, mutate(postinumero.map, pono = stringr::str_sub(pono, 1, N.digits.pono)), 
                          by = c("pono"))
  
   p <- ggplot(data = arrange(pono.map, order), aes(x = long, y = lat)) + 
    geom_polygon(aes_string(fill = attr.to.plot, group = "group"), colour = NA) + 
    theme_void() +
    theme(legend.title = element_blank()) + 
    ggtitle(title.label)
  
  p <- p + scale_fill_viridis_c(option = viridis.option, 
                                values = NULL, 
                                space = "Lab", 
                                na.value = "grey90", 
                                guide = "colourbar", 
                                direction = -1,
                                limits = color.limits)
  
  
  p <- p + coord_equal(ratio=2.1) 
  return(p)
}
