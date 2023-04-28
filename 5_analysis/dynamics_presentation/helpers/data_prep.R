

# read data ----
adopt_rates_all_hh <- read_csv("data/adopt_rates_all_hh.csv")

adopt_rates_panel_hh <- read_csv("data/adopt_rates_panel_hh.csv")

adopt_rates_all_ea <- read_csv("data/innov_ea_all.csv")

adopt_rates_panel_ea <- read_csv("data/innov_ea_panel.csv")

dna_means_hh <- read_csv("data/dna_means_hh.csv")

dna_means_ea <- read_csv("data/dna_means_ea.csv")



# cleaning ----

adoption_rates <- bind_rows(
  adopt_rates_all_hh %>% 
    mutate(sample = "All households/EA", level = "Household"),
  adopt_rates_panel_hh %>% 
    mutate(sample = "Panel households/EA", level = "Household"),
  adopt_rates_all_ea %>% 
    mutate(sample = "All households/EA", level = "EA"),
  adopt_rates_panel_ea %>% 
    mutate(sample = "Panel households/EA", level = "EA"),
  dna_means_hh,
  dna_means_ea
) %>% 
  filter(region != "Tigray") %>% 
  mutate(
    region = fct_relevel(
      region, 
      "Afar", "Amhara", "Oromia", "Somali", "Benishangul Gumuz", "SNNP", "Gambela", "Harar", "Dire Dawa", "National"),
    level = fct_rev(level)
  ) #%>% 
  # mutate(
  #   label = recode(
  #     label,
  #     "AI on any livestock type - both public & private" = "Artificial insemination use", 
  #     "Livestock AI - both public & private" = "Artificial insemination use", 
  #     "Large ruminants crossbred" = "Crossbred LARGE RUMINANTS",
  #     "Small ruminants crossbred" = "Crossbred SMALL RUMINANTS",
  #     "Poultry crossbred" = "Crossbred POULTRY",
  #     "Feed and forages: Elephant grass, Sesbaniya, & Alfalfa" = "Forages",
  #     "River dispersion" = "River diversion",
  #     "Motor pump used for irrigation" = "Motorized pumps",
  #     "Motor pump" = "Motorized pumps",
  #     "Conservation Agriculture - using Minimum tillage" = "Conservation Agriculture - using minimum tillage",
  #     "Conservation Agriculture - using Zero tillage" = "Conservation Agriculture - using zero tillage",
  #     "At least 1 hh benefitting from PSNP" = "At least 1 member/hh benefitting from PSNP",
  #     "At least 1 member benefitting from PSNP" = "At least 1 member/hh benefitting from PSNP"
  #   ))

labels_vec <- unique(adoption_rates$label)

labels_choices <- sort(labels_vec)

