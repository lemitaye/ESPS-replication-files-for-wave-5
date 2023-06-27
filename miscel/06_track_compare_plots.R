



# read data ----
adopt_rates_all_hh <- read_csv("data/adopt_rates_all_hh.csv")

adopt_rates_panel_hh <- read_csv("data/adopt_rates_panel_hh.csv")

adopt_rates_all_ea <- read_csv("data/innov_ea_all.csv")

adopt_rates_panel_ea <- read_csv("data/innov_ea_panel.csv")


plot_compar <- function(tbl, title, xlim = .8) {
  
  tbl %>% 
    mutate(
      improv = case_when(
        str_detect(label, "Improved") ~ 1,
        TRUE ~ 0
      ),
      wave = fct_relevel(wave, "Wave 5", "Wave 4"),
      label = fct_reorder(label, -improv)
    ) %>%
    ggplot(aes(mean, label, fill = wave)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = paste0( round(mean*100, 2), "%", " (", nobs, ")" ) ),
              position = position_dodge(width = 1),
              hjust = -.15, size = 2.5) +
    scale_y_discrete(labels = function(x) str_wrap(x, width = 35)) +
    scale_x_continuous(labels = percent_format()) +
    expand_limits(x = xlim) +
    theme(legend.position = "top") +
    labs(x = "Percent of households", 
         y = "", 
         fill = "",
         title = paste0("Percent of Rural Households Adopting Innovations - ", title),
         caption = "Percent are weighted sample means using panel weights.
         Number of households responding in parenthesis")
  
}


# Plots ----

nat_hh <- national_hh_level %>% 
  plot_compar("National", xlim = .85) +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

amhara_hh <- regions_hh_level %>% 
  filter(region == "Amhara") %>% 
  plot_compar("Amhara", xlim = 1.05) +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

oromia_hh <- regions_hh_level %>% 
  filter(region == "Oromia") %>% 
  plot_compar("Oromia") +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

snnp_hh <- regions_hh_level %>% 
  filter(region == "SNNP") %>% 
  plot_compar("SNNP") +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

other_hh <- regions_hh_level %>% 
  filter(region == "Other regions") %>% 
  plot_compar("Other regions") +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")



nat_panel <- national_hh_panel %>% 
  plot_compar("National") +
  labs(subtitle = "Only panel households included")

amhara_panel <- regions_hh_panel %>% 
  filter(region == "Amhara") %>% 
  plot_compar("Amhara", xlim = 1) +
  labs(subtitle = "Only panel households included")

oromia_panel <- regions_hh_panel %>% 
  filter(region == "Oromia") %>% 
  plot_compar("Oromia") +
  labs(subtitle = "Only panel households included")

snnp_panel <- regions_hh_panel %>% 
  filter(region == "SNNP") %>% 
  plot_compar("SNNP", xlim = .75) +
  labs(subtitle = "Only panel households included")

other_panel <- regions_hh_panel %>% 
  filter(region == "Other regions") %>% 
  plot_compar("Other Regions") +
  labs(subtitle = "Only panel households included")

plots <- list(nat_hh, amhara_hh, oromia_hh, snnp_hh, other_hh,
              nat_panel, amhara_panel, oromia_panel, snnp_panel, other_panel)

names(plots) <- c("nat_hh", "amhara_hh", "oromia_hh", "snnp_hh", "other_hh", "nat_panel", 
                  "amhara_panel", "oromia_panel", "snnp_panel", "other_panel")

for (i in seq_along(plots)) {
  
  file <- paste0(root, "/LSMS_W5/tmp/figures/", names(plots)[[i]], ".pdf")
  
  print(paste("saving to", file))
  
  ggsave(
    filename = file,
    plot = plots[[i]],
    device = cairo_pdf,
    width = 200,
    height = 285,
    units = "mm"
  )
}