
# A script for producing figures for a presentation

# created on: February 7, 2022

# depends on: figs_hh.R, figs_ea.R

source("LSMS_W5/tmp/ggplot_theme_Publication-2.R")

# Graph comparing animal agriculture innovations:

animal_agri <- bind_rows(
  mutate(national_hh_panel, level = "Household-level (only panel)"),
  mutate(national_ea_level, level = "EA-level")
) %>% 
  select(-variable, -improv) %>% 
  mutate(
    label = recode(label,
                   "AI on any livestock type - both public & private" = "Artificial insemination use", 
                   "Livestock AI - both public & private" = "Artificial insemination use", 
                   "Large ruminants crossbred" = "Crossbred LARGE RUMINANTS",
                   "Small ruminants crossbred" = "Crossbred SMALL RUMINANTS",
                   "Poultry crossbred" = "Crossbred POULTRY"
    )) %>%  
  filter(label %in% c(
    "Crossbred LARGE RUMINANTS",
    "Crossbred SMALL RUMINANTS",
    "Crossbred POULTRY",
    "Artificial insemination use"))

animal_dyn_plt <- animal_agri %>% 
  mutate(label = str_to_sentence(label)) %>% 
  ggplot(aes(label, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1) ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 3) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  # expand_limits(y = .6) +
  facet_wrap(~level, nrow = 1, scales = "free_y") +
  labs(x = "", y = "Percent",
       title = "Adoption of animal agriculture innovations (ESPS)",
       fill = "",
       caption = "Percent at the household level are weighted sample means (using wave 5 weights)") +
  scale_fill_Publication() + 
  theme_Publication() +
  theme(
    legend.position = "top",
    legend.margin = margin(t = -0.4, unit = "cm"),
    axis.title = element_text(size = 12.5),
    plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  )
  


ggsave(
  filename = "LSMS_W5/tmp/figures/animal_dyn_plt.pdf",
  plot = animal_dyn_plt,
  device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = 1.2#,
  # units = "mm"
) 






# Comparing adoption of CA and constitutent practices

cons_agri <- bind_rows(
  mutate(national_hh_panel, level = "Household-level (only panel)"),
  mutate(national_ea_level, level = "EA-level")
) %>% 
  select(-variable, -improv) %>% 
  mutate(label = str_to_sentence(label)) %>%
  filter(label %in% c(
    "Minimum tillage",
    "Zero tillage",
    "Crop residue cover - visual aid",
    "Crop rotation with a legume",
    "Conservation agriculture - using minimum tillage",
    "Conservation agriculture - using zero tillage")) %>% 
  mutate(short_lab = recode(
    label,
    "Minimum tillage" = "MT",
    "Zero tillage" = "ZT",
    "Crop residue cover - visual aid" = "CRC",
    "Crop rotation with a legume" = "CR",
    "Conservation agriculture - using minimum tillage" = "CA/MT",
    "Conservation agriculture - using zero tillage" = "CA/ZT"
  ),
  short_lab = fct_relevel(short_lab, "MT", "ZT", "CRC", "CR", "CA/MT", "CA/ZT"))

ca_dyn_plt <- cons_agri %>% 
  ggplot(aes(short_lab, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1)) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 3) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  # expand_limits(y = .6) +
  theme(legend.position = "top") +
  facet_wrap(~level, nrow = 1, scales = "free_y") +
  labs(x = "", y = "Percent",
       title = "Conservation agriculture (CA) and constitutent parts (ESPS)",
       fill = "",
       caption = "MT = Minimum tillage; ZT = Zero tillage; CRC = Crop residue cover (visual aids); CR = Crop rotation;
CA/MT = Conservation agriculture with minimum tillage; CA/ZT = Conservation agriculture with zero tillage.
       Percent at the household level are weighted sample means (using wave 5 weights).") +
  scale_fill_Publication() + 
  theme_Publication() +
  theme(
    legend.position = "top",
    legend.margin = margin(t = -0.4, unit = "cm"),
    axis.title = element_text(size = 12.5),
    plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  )


ggsave(
  filename = "LSMS_W5/tmp/figures/ca_dyn_plt.pdf",
  plot = ca_dyn_plt,
  device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = .8,
  # units = "mm"
) 


# Chickpea kabuli (waves 3 vs 5)

kabuli_dyn_plt <- kabuli_bind %>% 
  ggplot(aes(region, mean/100, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean, 1) ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 3) +
  facet_wrap(~ level, scales = "free") +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .08) +
  theme(legend.position = "top") +
  labs(x = "", y = "Percent",
       title = "Adoption rate of chickpea Kabuli in waves 3 and 5",
       fill = "",
       caption = "Percent are weighted sample means at the household level.") +
  scale_fill_Publication() + 
  theme_Publication() +
  theme(
    legend.position = "top",
    legend.margin = margin(t = -0.4, unit = "cm"),
    axis.title = element_text(size = 12.5),
    plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  )

ggsave(
  filename = "LSMS_W5/tmp/figures/kabuli_dyn_plt.pdf",
  plot = kabuli_dyn_plt,
  device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = .8,
  # units = "mm"
) 


# Afforestation and SWC (HH and EA level)

swc_affor <- bind_rows(
  mutate(national_hh_panel, level = "Household-level (only panel)"),
  mutate(national_ea_level, level = "EA-level")
) %>% 
  select(-variable, -improv) %>% 
  filter(label %in% c(
    "Soil Water Conservation practices",
    "Afforestation"))


swc_aff_dyn_plt <- swc_affor %>% 
  mutate(label = str_to_sentence(label)) %>% 
  ggplot(aes(label, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1) ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 3) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  # expand_limits(y = .6) +
  facet_wrap(~level, nrow = 1, scales = "free_y") +
  labs(x = "", y = "Percent",
       title = "Natural resource management practices: Afforestation and SWC",
       fill = "",
       caption = "Percent at the household level are weighted sample means (using wave 5 weights)") +
  scale_fill_Publication() + 
  theme_Publication() +
  theme(
    legend.position = "top",
    legend.margin = margin(t = -0.4, unit = "cm"),
    axis.title = element_text(size = 12.5),
    plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  )


ggsave(
  filename = "LSMS_W5/tmp/figures/swc_aff_dyn_plt.pdf",
  plot = swc_aff_dyn_plt,
  device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = 1.2#,
  # units = "mm"
) 


# Agro-forestry: Mango, Papaya, and Avocado

agroforest <- bind_rows(
  mutate(national_hh_panel, level = "Household-level (only panel)"),
  mutate(national_ea_level, level = "EA-level")
) %>% 
  select(-variable, -improv) %>% 
  filter(label %in% c(
    "Mango tree",
    "Avocado tree",
    "Papaya tree"
    ))

agroforest_dyn_plt <- agroforest %>% 
  mutate(label = str_to_sentence(label)) %>% 
  ggplot(aes(label, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1) ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 3) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  # expand_limits(y = .6) +
  facet_wrap(~level, nrow = 1, scales = "free_y") +
  labs(x = "", y = "Percent",
       title = "Natural resource management practices: Agroforestry",
       fill = "",
       caption = "Percent at the household level are weighted sample means (using wave 5 weights)") +
  scale_fill_Publication() + 
  theme_Publication() +
  theme(
    legend.position = "top",
    legend.margin = margin(t = -0.4, unit = "cm"),
    axis.title = element_text(size = 12.5),
    plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  )


ggsave(
  filename = "LSMS_W5/tmp/figures/agroforest_dyn_plt.pdf",
  plot = agroforest_dyn_plt,
  device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = 1.2#,
  # units = "mm"
) 












































































