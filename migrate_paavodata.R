source(here::here("utilities.R"))

# Paavo-data (Zip code demographics data)
Data <- bind_rows(get_geo("postialue:pno_tilasto_2019", get_geometry = FALSE),
                  get_geo("postialue:pno_tilasto_2018", get_geometry = FALSE), 
                  get_geo("postialue:pno_tilasto_2017", get_geometry = FALSE),
                  get_geo("postialue:pno_tilasto_2016", get_geometry = FALSE),
                  get_geo("postialue:pno_tilasto_2015", get_geometry = FALSE)) %>%
  select(-namn, 
         -objectid) %>% 
  rename(pono = posti_alue, 
         kuntano = kunta) %>% 
  mutate_if(is.numeric, function(x) ifelse(x == -1, NA, x))

# Variable names etc. for Paavo-data
# paavo.koodit.txt is in Finnish (fileEncodin = "MAC")
paavo_vars <- read.csv(file = here::here("map_and_names", "paavo.codes.txt"), 
                       sep=";",
                       fileEncoding = "UTF-8",
                       stringsAsFactors = FALSE) %>% 
  mutate(paavo.vuosi.offset=as.numeric(paavo.vuosi.offset))


# Weighted mean (eg. by numer of people)
wmean <- function(x, y) 
  weighted.mean(x, ifelse(is.na(y), 0, y), na.rm=T) %>%
  ifelse(!is.finite(.), NA, .)
  
# Sum which is NA if everythin is non-finite (inc. NaN and NA): deafult is 0
sum_finite <- function(x) ifelse(all(!is.finite(x)), NA, sum(x, na.rm=TRUE))

# Aggregate by zip according to paavo_vars
paavo_aggr <- function(d, i, vars = paavo_vars)
  group_by(d, vuosi, pono = str_sub(pono, 1, i)) %>% 
  select(pono, vuosi, one_of(filter(vars, aggr == "sum")$koodi)) %>% 
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
                        pono_level = i,
                        nimi = NA
                        ),
            by=c("vuosi", "pono")) 

paavo <- list()
### Let's compute averages and sums for different aggregation levels (original 5, 3 and 2 numbers)

paavo$counts <- bind_rows(mutate(Data, pono_level = 5),
                      paavo_aggr(Data, 3),
                      paavo_aggr(Data, 2)) %>% 
  ungroup

# Define calculating proportions here 
# PT variables seem to have changed 2019 

paavo$proportions <- paavo$counts %>%
  mutate(he_naiset = he_naiset / he_vakiy,
         he_miehet = he_miehet / he_vakiy) %>%
  mutate_at(vars(matches("he_[0-9]")), funs(. / he_vakiy)) %>% 
  mutate_at(vars(starts_with("ko_"), -ko_ika18y), funs(. / ko_ika18y)) %>%
  mutate_at(vars(hr_pi_tul, hr_ke_tul, hr_hy_tul, hr_ovy), funs(. / hr_tuy)) %>%
  mutate_at(vars(starts_with("pt_"), -pt_vakiy), funs(. / pt_vakiy)) %>%
  mutate_at(vars(starts_with("tp_"), -tp_tyopy), funs(. / tp_tyopy)) %>%
  mutate_at(vars(starts_with("te_"), -te_taly, -te_takk, -te_as_valj), funs(. / te_taly)) %>%
  mutate_at(vars(starts_with("tr_"), -tr_kuty, -tr_ktu, -tr_mtu), funs(. / tr_kuty)) %>%
  mutate_at(vars(one_of("ra_pt_as", "ra_kt_as")), funs(. / ra_asunn)) %>% 
  mutate_at(vars(one_of("ra_muut", "ra_asrak")), funs(. / ra_raky)) %>%
  mutate_at(vars(one_of("ra_ke")), funs(. / (ra_ke+ra_raky))) %>%
  ungroup 

# Variables 
paavo$vars <- paavo_vars

# If base count is zero, variables which are not counts (like average age etc.) are set to zero instead of NA at older data (2015, 2016)
# This is not meaningful.  Let's set these to NA for consistency

cc <- filter(paavo$vars, aggr == "mean")[c("weight", "koodi")]
cc$i <- seq(1, dim(cc)[1])

for (i in cc$i) 
  paavo$counts[, cc[cc$i == i, "koodi"]] <- 
  ifelse(paavo$counts[, cc[cc$i == i, "weight"]] == 0, 
         NA, 
         paavo$counts[, cc[cc$i == i, "koodi"]])


saveRDS(paavo, file=here::here("paavodata.rds"))
