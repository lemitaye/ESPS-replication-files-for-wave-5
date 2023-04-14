

# read data ----
adopt_rates_all_hh <- read_csv("data/adopt_rates_all_hh.csv")

adopt_rates_panel_hh <- read_csv("data/adopt_rates_panel_hh.csv")

adopt_rates_all_ea <- read_csv("data/adopt_rates_all_ea.csv")

adopt_rates_panel_ea <- read_csv("data/adopt_rates_panel_ea.csv")


# cleaning ----

adoption_rates <- bind_rows(
  adopt_rates_all_hh %>% 
    mutate(sample = "All households/EA", level = "Household"),
  adopt_rates_panel_hh %>% 
    mutate(sample = "Panel households/EA", level = "Household"),
  adopt_rates_all_ea %>% 
    mutate(sample = "All households/EA", level = "EA"),
  adopt_rates_panel_ea %>% 
    mutate(sample = "Panel households/EA", level = "EA")
) %>% 
  mutate(
    region = fct_relevel(region, 
                         "Amhara", "Oromia", "SNNP", "Other regions", "National"),
    level = fct_rev(level)
  ) %>% 
  filter(region != "Tigray") %>% 
  mutate(
    label = recode(
      label,
      "AI on any livestock type - both public & private" = "Artificial insemination use", 
      "Livestock AI - both public & private" = "Artificial insemination use", 
      "Large ruminants crossbred" = "Crossbred LARGE RUMINANTS",
      "Small ruminants crossbred" = "Crossbred SMALL RUMINANTS",
      "Poultry crossbred" = "Crossbred POULTRY",
      "Feed and forages: Elephant grass, Sesbaniya, & Alfalfa" = "Forages",
      "River dispersion" = "River diversion",
      "Motor pump used for irrigation" = "Motorized pumps",
      "Motor pump" = "Motorized pumps",
      "Conservation Agriculture - using Minimum tillage" = "Conservation Agriculture - using minimum tillage",
      "Conservation Agriculture - using Zero tillage" = "Conservation Agriculture - using zero tillage",
      "At least 1 hh benefitting from PSNP" = "At least 1 member/hh benefitting from PSNP",
      "At least 1 member benefitting from PSNP" = "At least 1 member/hh benefitting from PSNP"
    ))

labels_vec <- unique(adoption_rates$label)

labels_choices <- labels_vec[! labels_vec %in% c(
  "Feed and Forage: Elephant Grass", "Community Irrigation Scheme"
  )]

