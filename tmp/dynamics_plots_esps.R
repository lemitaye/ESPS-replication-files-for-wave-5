


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

animal_dynamics <- animal_agri %>% 
  mutate(label = str_to_sentence(label)) %>% 
  ggplot(aes(label, mean, fill = wave)) +
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
       title = "Adoption of crossbred animals in waves 4 and 5",
       fill = "",
       caption = "Percent are weighted sample means.
       Number of observations in parenthesis")


ggsave(
  filename = ,
  plot = animal_dynamics,
  
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

cons_agri %>% 
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
       title = "Adoption of crossbred animals in waves 4 and 5",
       fill = "",
       caption = "Percent are weighted sample means.
       Number of observations in parenthesis")




















