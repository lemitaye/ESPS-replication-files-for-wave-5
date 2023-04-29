

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


# Define a plot function:

plot_waves <- function(tbl) {
  
  tbl %>% 
    ggplot(aes(region, mean, fill = wave)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
              position = position_dodge(width = 1),
              vjust = -.35, size = 3) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
    scale_y_continuous(labels = percent_format()) +
    # expand_limits(y = maxGrid + .15) +
    # facet_wrap(~ level, nrow=2, scales = "free") +
    scale_fill_Publication() + 
    theme_Publication() +
    theme(
      legend.position = "top",
      legend.margin = margin(t = -0.4, unit = "cm"),
      axis.title = element_text(size = 12.5),
      plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
    ) +
    labs(
      x = "", y = "Percent",
      # title = input$var,
      fill = "",
      caption = "Percent at the household level are weighted sample means.
             Number of observations in parenthesis."
    )
  
}





















