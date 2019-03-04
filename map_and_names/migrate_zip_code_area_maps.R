
source("utilities.R")


# This has already been run in order to creted files 
# statfi_reduced_zipareamap_*.rds
#
# Load maps from Statistics Finland:
# simplify polygons & remove small island. Convert to polygons
# Save as RDS files

get_geo_sf <-function(data_name = "tilastointialueet:kunta4500k_2017", name_ext = ".shp") {
  
  data_file <- paste0(tempdir(), "/", str_split_fixed(data_name, pattern=":", n = 2)[2])
  url_head <- "http://geo.stat.fi/geoserver/wfs?service=WFS&version=1.0.0&request=GetFeature&typeName="
  url_tail <- "&outputFormat=SHAPE-ZIP"
  zip_file <- paste(tempdir(), "/", "shape.zip", sep = "")
  curl::curl_download(paste(url_head, data_name, url_tail, sep = ""), zip_file)
  unzip(zip_file, exdir = tempdir())  
  
  sf::st_read(paste(tempdir(), "/", str_split_fixed(data_name, pattern = ":", n = 2)[2], name_ext, sep = ""), 
              quiet = TRUE, 
              stringsAsFactors = FALSE) 
}

for (i in seq(2015, 2019)) {
  Q <- get_geo_sf(paste0("postialue:pno_tilasto_", i)) 
  Q2 <- rmapshaper::ms_filter_islands(select(Q, pono=posti_alue, geometry), min_area = 90000)
  Q2 <- rmapshaper::ms_simplify(Q2, keep = 0.15)
  P <- as(Q2, "Spatial")
  P <- cleangeo::clgeo_Clean(P)
  df <- gisfin::sp2df(P) 
  saveRDS(df, file = here::here("map_and_names", paste0("statfi_reduced_ziparea_map_", i,".rds"))) 
}

# Example plot
ggplot(data = df, aes(x = long, y=lat)) + geom_polygon(aes(group = group), color = 1, fill = NA)

