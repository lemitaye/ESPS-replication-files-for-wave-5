
###############################################################################*
# Comparison for Chickpea Kabuli only (against wave 3) ####
###############################################################################*

wave3_hh <- read_dta(file.path(root, w4_dir, "wave3_hh.dta"))
wave3_ea <- read_dta(file.path(root, w4_dir, "wave3_ea.dta"))

wave5_ea_new <- read_dta(file.path(root, w5_dir, "wave5_ea_new.dta"))


chickpea_tbl <- function(tbl, kab_var, desi_var, pw, hh = TRUE) {
  
  if (hh) {
    bind_rows(
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        group_by(region) %>% 
        summarise(
          mean_kabuli = weighted.mean({{kab_var}}, w = {{pw}}, na.rm = TRUE),
          mean_desi = weighted.mean({{desi_var}}, w = {{pw}}, na.rm = TRUE),
          mean_chickpea = weighted.mean(chickpea, w = {{pw}}, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ),
      
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        summarise(
          mean_kabuli = weighted.mean({{kab_var}}, w = {{pw}}, na.rm = TRUE),
          mean_desi = weighted.mean({{desi_var}}, w = {{pw}}, na.rm = TRUE),
          mean_chickpea = weighted.mean(chickpea, w = {{pw}}, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ) %>% 
        mutate(region = "National")
    )
  } else {
    bind_rows(
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        group_by(region) %>% 
        summarise(
          mean_kabuli = mean({{kab_var}}, na.rm = TRUE),
          mean_desi = mean({{desi_var}}, na.rm = TRUE),
          mean_chickpea = mean(chickpea, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ),
      
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        summarise(
          mean_kabuli = mean({{kab_var}}, na.rm = TRUE),
          mean_desi = mean({{desi_var}}, na.rm = TRUE),
          mean_chickpea = mean(chickpea, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ) %>% 
        mutate(region = "National")
    )
  }
  
}




mean_kabuli_w3_hh <- wave3_hh %>% 
  recode_region() %>% 
  chickpea_tbl(hhd_kabuli_r, hhd_desi_r, pw_w3) %>% 
  mutate(across(c(mean_kabuli, mean_desi, mean_chickpea), ~ . / 100 ) ) %>%
  mutate(wave = "Wave 3", level = "Household-level")

mean_kabuli_w3_ea <- wave3_ea %>% 
  recode_region() %>% 
  chickpea_tbl(ead_kabuli_r, ead_desi_r, hh = FALSE) %>% 
  mutate(across(c(mean_kabuli, mean_desi, mean_chickpea), ~ . / 100 ) ) %>%
  mutate(wave = "Wave 3", level = "EA-level")

mean_kabuli_w5_hh <- wave5_hh_new %>% 
  recode_region() %>% 
  chickpea_tbl(hhd_kabuli, hhd_desi, pw_w5) %>% 
  mutate(wave = "Wave 5", level = "Household-level")

mean_kabuli_w5_ea <- wave5_ea_new %>% 
  recode_region() %>% 
  chickpea_tbl(ead_kabuli, ead_desi, hh = FALSE) %>% 
  mutate(wave = "Wave 5", level = "EA-level")


kabuli_bind <- bind_rows(
  mean_kabuli_w3_hh,
  mean_kabuli_w3_ea,
  mean_kabuli_w5_hh,
  mean_kabuli_w5_ea
) %>% 
  mutate(region = fct_relevel(region, "Amhara", "Oromia", "SNNP", "Other regions", "National")) 


kabuli_plot <- kabuli_bind %>% 
  filter(level == "Household-level", region != "Tigray") %>% 
  ggplot(aes(region, mean_chickpea, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean_chickpea*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  facet_wrap(~ level, scales = "free") +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .15) +
  theme(legend.position = "top") +
  labs(x = "", y = "Percent",
       title = "Comparision of Adoption of Chickpea Kabuli Variety b/n Waves 3 and 5",
       fill = "",
       caption = "Percent are weighted sample means.
       Number of responding households in parenthesis")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/kabuli_plot.pdf"),
  plot = kabuli_plot,
  device = cairo_pdf,
  width = 180,
  height = 135,
  units = "mm"
)
