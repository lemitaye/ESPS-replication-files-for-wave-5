

# map of geo-spatial variables

library(tmap)
library(sp)
library(sf)
library(RColorBrewer)
library(colorspace)
library(haven)

theme_set(theme_light())

root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"

# read data ----
hh_geo_w5 <- read_dta(
  file.path(root, "2_raw_data/data/HH/Pub_ETH_HouseholdGeovariables_Y5.dta")
  )

ess5_weights_hh <- read_dta(file.path(root, "2_raw_data/data/HH/ESS5_weights_hh.dta"))

eth_regions <- st_read(
  dsn = "./gadm41_ETH_shp",
  layer = "gadm41_ETH_1"
)

# wrangle ----

hh_geo_slctd <- hh_geo_w5 %>% 
  select(
    household_id, h2021_tot, af_bio_12_x, wetQ_avg, af_bio_16_x, eviarea_avg,
    lat_dd_mod, lon_dd_mod
  ) %>% 
  left_join(
    ess5_weights_hh %>% 
      select(-interview__key),
    by = "household_id"
  )

write_csv(hh_geo_slctd, "hh_geo_slctd.csv")

hh_geo_slctd_sf <- hh_geo_slctd %>% 
  filter(!is.na(lon_dd_mod), !is.na(lat_dd_mod)) %>% 
  st_as_sf(coords = c("lon_dd_mod", "lat_dd_mod"), crs = st_crs(4326))

ggplot() +
  geom_sf(data = eth_regions) +
  geom_sf(data = hh_geo_slctd_sf, aes(size = h2021_tot), alpha = .5)


hh_geo_slctd %>% 
  ggplot(aes(h2021_tot)) +
  geom_histogram() 

hh_geo_slctd %>% 
  ggplot(aes(h2021_tot)) +
  geom_density() 

hh_geo_slctd %>% 
  ggplot(aes(h2021_tot)) +
  geom_histogram() +
  facet_wrap(~ region, scales = "free")

hh_geo_slctd %>% 
  ggplot(aes(af_bio_12_x)) +
  geom_histogram() +
  facet_wrap(~ region, scales = "free")


hh_geo_slctd %>% 
  ggplot(aes(af_bio_12_x)) +
  geom_boxplot() + 
  facet_wrap(~ rururb) +
  coord_flip()

hh_geo_slctd %>% 
  ggplot(aes(af_bio_12_x)) +
  geom_boxplot() +
  facet_wrap(~ region, scales = "free") +
  coord_flip()

hh_geo_slctd %>% 
  mutate(region = fct_reorder(region, af_bio_12_x)) %>% 
  ggplot(aes(af_bio_12_x, region, fill = rururb)) +
  geom_boxplot() +
  facet_wrap(~rururb, scales = "free_x")


hh_geo_slctd %>% 
  count(rururb)




