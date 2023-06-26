
# Figure 9 (in v.1 report): Totals ---------------------

# Depends on: 10_4_adopt_reach_table.R


source("dynamics_presentation/helpers/ggplot_theme_Publication-2.R")

## Figure 9 for ESS5 -----------

var_labs <- as_tibble_col(
  c(
    "hhd_livIA", "hhd_avocado", "hhd_kabuli", "hhd_consag1", 
    "hhd_consag2", "hhd_cross_largerum", "hhd_cross_poultry", "hhd_cross_smallrum", 
    "hhd_grass", "hhd_mango", "hhd_motorpump", "hhd_papaya", "hhd_rdisp", 
    "hhd_swc", "hhd_awassa83", "hhd_ofsp", "hhd_treadle", "hhd_maize_cg",
    "barley_cg", "sorghum_cg"
  ),
  column_name = "variable" 
) %>% 
  mutate(
    # labels of innovations
    label = case_match(
      variable,
      "hhd_livIA"          ~ "Artificial insemination delivery",
      "hhd_avocado"        ~ "Avocado trees",
      "hhd_kabuli"         ~ "Chickpea Kabuli varieties",
      "hhd_consag1"        ~ "Conservation Agriculture / MT*",
      "hhd_consag2"        ~ "Conservation Agriculture / ZT*",
      "hhd_cross_largerum" ~ "Large ruminants crossbreeds", 
      "hhd_cross_poultry"  ~ "Poultry crossbreeds",
      "hhd_cross_smallrum" ~ "Small ruminants crossbreeds",
      "hhd_grass"          ~ "Forage grasses",
      "hhd_mango"          ~ "Mango trees",
      "hhd_motorpump"      ~ "Motorized pumps",
      "hhd_papaya"         ~ "Papaya trees", 
      "hhd_rdisp"          ~ "River dispersion", 
      "hhd_swc"            ~ "Soil & Water Conservation practices",
      "hhd_awassa83"       ~ "Sweet potato Awassa-83 variety",
      "hhd_ofsp"           ~ "Sweet potato OFSP varieties", 
      "hhd_treadle"        ~ "Treadle pumps",
      "hhd_maize_cg"       ~ "Maize varieties",
      "barley_cg"          ~ "Barley varieties",
      "sorghum_cg"         ~ "Sorghum varieties"
    ),
    
    # categories of innovations
    type = case_when(
      
      str_detect(variable, "hhd_cross_|hhd_livIA|hhd_grass") ~ "Animal agriculture",
      
      variable %in% c(
        "hhd_maize_cg", "hhd_kabuli", "hhd_ofsp", "hhd_awassa83", "barley_cg", "sorghum_cg"
      ) ~ "Crop germplasm improvement",
      
      variable %in% c(
        "hhd_rdisp", "hhd_treadle", "hhd_motorpump", "hhd_swc", "hhd_consag1", 
        "hhd_consag2", "hhd_affor", "hhd_mango", "hhd_papaya", "hhd_avocado"
      ) ~ "Natural resource management"
      
    ),
    
    variable_w4 = case_match(
      variable,
      "hhd_maize_cg" ~ "maize_cg",
      .default = variable
    )
  )



ess5_totals <- bind_rows(
  mutate(make_sheet(ess5_cs)$df, sample = "all"), 
  mutate(make_sheet(ess5_pnl)$df, sample = "panel")
) %>% 
  select(sample, label, total = Total) %>% 
  left_join(
    bind_rows(adopt_rates_w5_hh, adopt_rate_dna_w5) %>% 
      distinct(variable, label), 
    by = "label",
    multiple = "all"
  ) %>% 
  select(-label) %>% 
  inner_join(var_labs, by = "variable") %>% 
  select(sample, variable, label, type, total)


# theme_set(theme_light())

ess5_totals %>% 
  filter(sample == "all") %>% 
  mutate(label = fct_reorder(label, total)) %>% 
  ggplot(aes(label, total, fill = type)) +
  geom_col() +
  scale_y_continuous(labels = unit_format(unit = "", scale = 1e-6)) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(
    axis.text.x = element_text(
      angle = 90,
      size = 10,
      hjust = 1,
      vjust = .4
    ),
    axis.title.y = element_text(size = 11),
    legend.position = "top"
  ) +
  labs(
    y = "Number of rural households (millions)",
    x = "",
    fill = "",
    title = "Number of rural households adopting each CGIAR-related innovation in\nEthiopia, ESS5 (2021/22) - All households"
  )

ggsave(
  filename = "../tmp/figures/fig09_all_w5.png",
  width = 300,
  height = 160,
  units = "mm"
)

ess5_totals %>% 
  filter(sample == "panel") %>% 
  mutate(label = fct_reorder(label, total)) %>% 
  ggplot(aes(label, total, fill = type)) +
  geom_col() +
  scale_y_continuous(labels = unit_format(unit = "", scale = 1e-6)) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(
    axis.text.x = element_text(
      angle = 90,
      size = 10,
      hjust = 1,
      vjust = .4
    ),
    axis.title.y = element_text(size = 11),
    legend.position = "top"
  ) +
  labs(
    y = "Number of rural households (millions)",
    x = "",
    fill = "",
    title = "Number of rural households adopting each CGIAR-related innovation\nin Ethiopia, ESS5 (2021/22) - Panel households"
  )

ggsave(
  filename = "../tmp/figures/fig09_panel_w5.png",
  width = 300,
  height = 160,
  units = "mm"
)





## Figure 9 for ESS4 ------------


ess4_totals <- bind_rows(
  mutate(make_sheet(ess4_cs)$df, sample = "all"), 
  mutate(make_sheet(ess4_pnl)$df, sample = "panel")
) %>% 
  select(sample, label, total = Total) %>% 
  left_join(
    bind_rows(adopt_rates_w4_hh, adopt_rate_dna_w4) %>% 
      distinct(variable, label), 
    by = "label",
    multiple = "all"
  ) %>% 
  select(-label) %>% 
  inner_join(var_labs, by = c("variable" = "variable_w4")) %>% 
  select(sample, variable, label, type, total)


ess4_totals %>% 
  filter(sample == "all") %>% 
  mutate(label = fct_reorder(label, total)) %>% 
  ggplot(aes(label, total, fill = type)) +
  geom_col() +
  scale_y_continuous(labels = unit_format(unit = "", scale = 1e-6)) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(
    axis.text.x = element_text(
      angle = 90,
      size = 10,
      hjust = 1,
      vjust = .4
    ),
    axis.title.y = element_text(size = 11),
    legend.position = "top"
  ) +
  labs(
    y = "Number of rural households (millions)",
    x = "",
    fill = "",
    title = "Number of rural households adopting each CGIAR-related innovation in\nEthiopia, ESS4 (2018/19) - All households"
  )

ggsave(
  filename = "../tmp/figures/fig09_all_w4.png",
  width = 300,
  height = 160,
  units = "mm"
)

ess4_totals %>% 
  filter(sample == "panel") %>% 
  mutate(label = fct_reorder(label, total)) %>% 
  ggplot(aes(label, total, fill = type)) +
  geom_col() +
  scale_y_continuous(labels = unit_format(unit = "", scale = 1e-6)) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(
    axis.text.x = element_text(
      angle = 90,
      size = 10,
      hjust = 1,
      vjust = .4
    ),
    axis.title.y = element_text(size = 11),
    legend.position = "top"
  ) +
  labs(
    y = "Number of rural households (millions)",
    x = "",
    fill = "",
    title = "Number of rural households adopting each CGIAR-related innovation\nin Ethiopia, ESS4 (2018/19) - Panel households"
  )

ggsave(
  filename = "../tmp/figures/fig09_panel_w4.png",
  width = 300,
  height = 160,
  units = "mm"
)



# ESS4 & ESS5 on the same figure 

adopt_totals <- bind_rows(
  ess4_totals %>% 
    mutate(year = "2018/19"), 
  ess5_totals %>% 
    mutate(year = "2021/22")
)

ess4_arrng <- ess4_totals %>% 
  filter(sample == "all") %>% 
  arrange(total) %>% 
  pull(label)

# levels <- ess4_arrng %>% union(ess5_totals$label %>% unique())

levels <- c( ess4_arrng[1:12], "Chickpea Kabuli varieties", ess4_arrng[13:length(ess4_arrng)])

## Panel 

adopt_totals %>% 
  filter(sample == "panel") %>% 
  mutate(label = factor(label, levels = levels)) %>% 
  ggplot(aes(label, total, fill = type)) +
  geom_col() +
  facet_wrap(~year, nrow = 2) +m
scale_y_continuous(labels = unit_format(unit = "", scale = 1e-6)) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(
    axis.text.x = element_text(
      angle = 90,
      size = 10,
      hjust = 1,
      vjust = .4
    ),
    axis.title.y = element_text(size = 11),
    legend.position = "top"
  ) +
  labs(
    y = "Number of rural households (millions)",
    x = "",
    fill = "",
    title = "Number of rural households adopting each CGIAR-related innovation\nin Ethiopia, ESS - Panel households"
  )

ggsave(
  filename = "../tmp/figures/fig09_panel.png",
  width = 300,
  height = 297,
  units = "mm"
)


## All

adopt_totals %>% 
  filter(sample == "all") %>% 
  mutate(label = factor(label, levels = levels)) %>%
  ggplot(aes(label, total, fill = type)) +
  geom_col() +
  facet_wrap(~year, nrow = 2) +
  scale_y_continuous(labels = unit_format(unit = "", scale = 1e-6)) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(
    axis.text.x = element_text(
      angle = 90,
      size = 10,
      hjust = 1,
      vjust = .4
    ),
    axis.title.y = element_text(size = 11),
    legend.position = "top"
  ) +
  labs(
    y = "Number of rural households (millions)",
    x = "",
    fill = "",
    title = "Number of rural households adopting each CGIAR-related innovation\nin Ethiopia, ESS - All households"
  )

ggsave(
  filename = "../tmp/figures/fig09_all.png",
  width = 300,
  height = 297,
  units = "mm"
)
