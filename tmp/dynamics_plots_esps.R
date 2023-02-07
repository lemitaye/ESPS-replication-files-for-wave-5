
# A script for producing figures for a presentation

# created on: February 7, 2022

# depends on: figs_hh.R, figs_ea.R

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
  geom_text(aes(label = paste0( round(mean*100, 1), "%" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 1.3) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  # expand_limits(y = .6) +
  theme(legend.position = "top") +
  facet_wrap(~level, nrow = 1, scales = "free_y") +
  labs(x = "", y = "Percent",
       title = "Adoption of animal agriculture innovations in waves 4 and 5",
       fill = "",
       caption = "Percent at the household level are weighted sample means (using wave 5 weights)")


ggsave(
  filename = "LSMS_W5/tmp/figures/animal_dyn_plt.pdf",
  plot = animal_dyn_plt,
  device = cairo_pdf,
  width = 6,
  height = 4#,
  # scale = .8,
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
  geom_text(aes(label = paste0( round(mean*100, 1), "%" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  # expand_limits(y = .6) +
  theme(legend.position = "top") +
  facet_wrap(~level, nrow = 1, scales = "free_y") +
  labs(x = "", y = "Percent",
       title = "Conservation agriculture (CA) and constitutent parts in waves 4 and 5",
       fill = "",
       caption = "MT = Minimum tillage; ZT = Zero tillage; CRC = Crop residue cover (visual aids); CR = Crop rotation;
CA/MT = Conservation agriculture with minimum tillage; CA/ZT = Conservation agriculture with zero tillage.
       Percent at the household level are weighted sample means (using wave 5 weights).")




















