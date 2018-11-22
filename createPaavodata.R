library(here)
library(dplyr)
library(tidyr)
library(stringr)

## Function gets Paavo data from statistics Finland
## This data contains also the polygons needed for drawing the polygons but it's not used here

get.geo <-function(data.name = "tilastointialueet:kunta4500k_2017", name.ext = ".shp") {
  data.file = paste(tempdir(), "/", str_split_fixed(data.name, pattern=":", n = 2)[2], sep = "")
  url.head <- "http://geo.stat.fi/geoserver/wfs?service=WFS&version=1.0.0&request=GetFeature&typeName="
  url.tail <- "&outputFormat=SHAPE-ZIP"
  zip.file <- paste(tempdir(), "/", "shape.zip", sep = "")
  curl::curl_download(paste(url.head, data.name, url.tail, sep = ""), zip.file)
  unzip(zip.file, exdir = tempdir())  
  geodata <- sf::st_read(paste(tempdir(), "/", str_split_fixed(data.name, pattern=":",n=2)[2], name.ext, sep=""), 
                         quiet=TRUE, 
                         stringsAsFactors=FALSE) %>% 
    as.data.frame(., stringsAsFactors=FALSE) %>% 
    mutate_if(is.character, function(x) iconv(x, from = "latin1", to="UTF-8")) %>%
    select(-geometry) 
  return(geodata)
}

# Paavo-data (Zip code demographics data)
Data <- bind_rows(get.geo("postialue:pno_tilasto_2018"), 
                  get.geo("postialue:pno_tilasto_2017"),
                  get.geo("postialue:pno_tilasto_2016"),
                  get.geo("postialue:pno_tilasto_2015")) %>%
  select(-namn, 
         -objectid) %>% 
  rename(pono = posti_alue, 
         kuntano = kunta) %>% 
  mutate_if(is.numeric, function(x) ifelse(x == -1, NA, x))

# Variable names etc. for Paavo-data
paavo.vars <- read.csv(file = "paavo.koodit.txt", 
                       sep=";",
                       fileEncoding = "MAC",
                       stringsAsFactors = FALSE)  


# Weighted mean (eg. by numer of people)
wmean <- function(x, y) 
  weighted.mean(x, ifelse(is.na(y), 0, y), na.rm=T) %>%
  ifelse(!is.finite(.), NA, .)
  
# Sum which is NA if everythin is non-finite (inc. NaN and NA): deafult is 0
sum_finite <- function(x) ifelse(all(!is.finite(x)), NA, sum(x, na.rm=TRUE))


# Aggregate by zip according to paavo.vars
paavo.aggr <- function(d, i, vars = paavo.vars)
  group_by(d, vuosi, pono = str_sub(pono, 1, i)) %>% 
  select(pono, vuosi, one_of(filter(vars, aggr=="sum")$koodi)) %>% 
  summarise_all(sum_finite) %>% 
  left_join(.,
            group_by(d, vuosi, pono=str_sub(pono, 1, i)) %>% 
              summarise(he_kika = wmean(he_kika, he_vakiy),
                        hr_ktu = wmean(hr_ktu, hr_tuy),
                        hr_mtu = wmean(hr_mtu, hr_tuy),
                        te_takk = wmean(te_takk, te_taly),
                        te_as_valj = wmean(te_as_valj, te_taly),
                        tr_ktu = wmean(tr_ktu, tr_kuty),
                        tr_mtu = wmean(tr_mtu, tr_kuty),
                        ra_as_kpa = wmean(ra_as_kpa, ra_asunn),
                        euref_x = wmean(euref_x, pinta_ala),
                        euref_y = wmean(euref_y, pinta_ala),
                        kuntano = NA,
                        pono.level = i,
                        nimi = NA
                        ),
            by=c("vuosi", "pono")) 

# Aggregate by municipality + zip code combination (not used now)
paavo.aggr.kunta.pono <- function(d, i, vars = paavo.vars)
  group_by(d, vuosi, pono = str_sub(pono, 1, i), kuntano) %>% 
  select(pono, 
         vuosi, 
         one_of(filter(vars, aggr == "sum")$koodi), 
         kuntano) %>% 
  summarise_all(sum_finite) %>% 
  left_join(.,
            group_by(d, vuosi, pono = str_sub(pono, 1, i), kuntano) %>% 
              summarise(he_kika = wmean(he_kika, he_vakiy),
                        hr_ktu = wmean(hr_ktu, hr_tuy),
                        hr_mtu = wmean(hr_mtu, hr_tuy),
                        te_takk = wmean(te_takk, te_taly),
                        te_as_valj = wmean(te_as_valj, te_taly),
                        tr_ktu = wmean(tr_ktu, tr_kuty),
                        tr_mtu = wmean(tr_mtu, tr_kuty),
                        ra_as_kpa = wmean(ra_as_kpa, ra_asunn),
                        euref_x = wmean(euref_x, pinta_ala),
                        euref_y = wmean(euref_y, pinta_ala),
                        pono.level =i*10+i,
                        nimi = NA
              ),
            by=c("vuosi","pono", "kuntano")) 

paavo <- list()
### Let's compute averages and sums for different aggregation levels (original 5, 3 and 2 numbers)

paavo$counts <- bind_rows(mutate(Data, pono.level=5),
                      paavo.aggr(Data, 3),
                      paavo.aggr(Data, 2)) %>% 
  ungroup


# Counts to shares (counts normalised by sum)

paavo$proportions <- paavo$counts %>%
  select(-nimi, -kuntano) %>%
  mutate(he_naiset = he_naiset / he_vakiy,
         he_miehet = he_miehet / he_vakiy) %>%
  mutate_at(vars(matches("he_[0-9]")), funs(. / he_vakiy)) %>% 
  mutate_at(vars(starts_with("ko_"), -ko_ika18y), funs(. / ko_ika18y)) %>%
  mutate_at(vars(hr_pi_tul, hr_ke_tul, hr_hy_tul, hr_ovy), funs(. / hr_tuy)) %>%
  mutate_at(vars(starts_with("pt_"), -pt_vakiy), funs(. / pt_vakiy)) %>%
  mutate_at(vars(starts_with("tp_"), -tp_tyopy), funs(. / tp_tyopy)) %>%
  mutate_at(vars(starts_with("te_"), -te_taly, -te_takk, -te_as_valj),
            funs(. / te_taly)) %>%
  mutate_at(vars(starts_with("tr_"), -tr_kuty, -tr_ktu, -tr_mtu),
            funs(. / tr_kuty)) %>%
  mutate_at(vars(starts_with("ra_"), -ra_raky, -ra_as_kpa), funs(. / ra_raky)) %>% 
  ungroup

# Variables 
paavo$vars <- paavo.vars

saveRDS(paavo, file=here::here("paavodata.rds"))
