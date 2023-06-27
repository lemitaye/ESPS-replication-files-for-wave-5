
# A script for producing figures for a presentation

# created on: February 7, 2022

# load libraries:
library(tidyverse)
library(haven)
library(ggpubr)

# depends on: figs_hh.R, figs_ea.R

source("dynamics_presentation/helpers/ggplot_theme_Publication-2.R")

esps_dna_path <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/ESS5_DNA_Data/ESPS_DNA"


# read psnp data:
psnp_hh <- read_csv("dynamics_presentation/data/psnp_hh.csv")

psnp_ea_rural <- read_csv("dynamics_presentation/data/psnp_ea_rural.csv")

dna_means_hh <- read_csv("dynamics_presentation/data/dna_means_hh.csv")

dna_means_ea <- read_csv("dynamics_presentation/data/dna_means_ea.csv")

append_seed_source <- read_dta(file.path(esps_dna_path, "tmp/03_3_append_seed_source.dta")) %>%
  mutate_if(is.labelled, as_factor)

adopt_rates_panel_hh <- read_csv("dynamics_presentation/data/adopt_rates_panel_hh.csv")

innov_ea_panel <- read_csv("dynamics_presentation/data/innov_ea_panel.csv")


nat_adpt_panel <- bind_rows(
  filter(adopt_rates_panel_hh, region == "National") %>% 
    mutate(level = "Household", sample = "Panel"),
  filter(innov_ea_panel, region == "National") %>% 
    mutate(level = "Village", sample = "Panel"),
  filter(psnp_hh, sample == "Panel", locality == "Rural", 
         region == "National") %>% 
    mutate(level = "Household", sample = "Panel"),
  filter(psnp_ea_rural, sample == "Panel", locality == "Rural", 
         region == "National") %>% 
    mutate(level = "Village", sample = "Panel")
) %>%
  dplyr::select(-locality) %>% 
  mutate(wave = recode(wave, "Wave 4" = "2018/19", "Wave 5" = "2021/22"))

# plot function:

plot_dyn_nat <- function(tbl, title = "Add title") {
  
  tbl %>% 
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
         title = title,
         fill = "",
         caption = "Only panel sample used. Percent at the household level are weighted sample means using panel weights.") +
    scale_fill_Publication() + 
    theme_Publication() +
    theme(
      legend.position = "top",
      legend.margin = margin(t = -0.4, unit = "cm"),
      axis.title = element_text(size = 12.5),
      plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
    )
  
}


# Animal agriculture: ---------

animal_agri <- nat_adpt_panel %>%  
  filter(variable %in% c(
    "hhd_cross_largerum", "hhd_cross_poultry", 
    "ead_cross_largerum", "ead_cross_poultry",
    "hhd_grass", "ead_grass", "ead_livIA", "hhd_livIA"
  )) %>% 
  mutate(
    label = recode(
      label,
      "Ai On Any Livestock Type - Both Public & Private" = "Artificial Insemination use", 
      "Feed And Forages: Elephant Grass, Sesbaniya, & Alfalfa" = "Forages"             
    )) %>% 
  mutate(label = fct_reorder(label, mean))

animal_dyn_plt <- animal_agri %>% 
  # mutate(label = str_to_sentence(label)) %>% 
  plot_dyn_nat(title = "Animal agriculture")
  

ggsave(
  filename = "../tmp/figures/animal_dyn_plt.png",
  plot = animal_dyn_plt,
  # device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = 1.2#,
  # units = "mm"
) 






# CA and constituent practices ---------

cons_agri <- bind_rows(
  mutate(national_hh_panel, level = "Household-level (only panel)"),
  mutate(national_ea_panel, level = "EA-level (only panel)")
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
       Percent at the household level are weighted sample means using panel weights.") +
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
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean_kabuli, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean_kabuli*100, 1) ) ),
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
       caption = "Only panel sample used. Percent are weighted sample means at the household level.") +
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



# any chickpea variety:

chickpea_dyn_plt <- kabuli_bind %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean_chickpea, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean_chickpea*100, 1) ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 3) +
  facet_wrap(~ level, scales = "free") +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .08) +
  theme(legend.position = "top") +
  labs(x = "", y = "Percent",
       title = "Adoption rate of any chickpea variety in waves 3 and 5",
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
  filename = "LSMS_W5/tmp/figures/chickpea_dyn_plt.pdf",
  plot = chickpea_dyn_plt,
  device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = .8,
  # units = "mm"
) 


# Afforestation and SWC (HH and EA level)

nrm_policy <- nat_adpt_panel %>% 
  filter(variable %in% c(
    "hhd_swc", "ead_swc", "hhd_consag1", "ead_consag1", "hhd_affor", "ead_affor",
    # "ead_motorpump", "hhd_motorpump", "ead_rdisp", "hhd_rdisp", 
    "hhd_psnp_any", "ead_psnp_any"
    )) %>% 
  mutate(label = fct_reorder(label, mean)) %>%
  mutate(
    label = recode(
      label,
      "Afforestation" = " Afforestation",
      "Soil Water Conservation Practices" = "Soil & Water Conserv. Practices",
      "Conservation Agriculture - Using Minimum Tillage" = "Conserv. Agriculture - using Minimum Tillage"
    ))


nrm_policy_dyn_plt <- nrm_policy %>% 
  # mutate(label = str_to_sentence(label)) %>% 
  plot_dyn_nat(title = "Natural resource management and policy innovations")

ggsave(
  filename = "../tmp/figures/nrm_policy_dyn_plt.png",
  plot = nrm_policy_dyn_plt,
  # device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = 1.2#,
  # units = "mm"
) 


# Agro-forestry: Mango, Papaya, and Avocado

agroforest <- bind_rows(
  mutate(national_hh_panel, level = "Household-level (only panel)"),
  mutate(national_ea_panel, level = "EA-level (only panel)")
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
       caption = "Percent at the household level are weighted sample means using panel weights") +
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


# Maize DNA germplasm ----------

## DTMZ & CG-germplasm ------

dna_means <- bind_rows(
  dna_means_hh, dna_means_ea
) %>% 
  mutate(
    sample = recode(
      sample, 
      "All households/EA" = "All",
      "Panel households/EA" = "Panel"),
    level = recode(
      level, "EA" = "Village"
    ),
    label = str_replace(label, "\\(DNA data\\)", "")
  ) %>% 
  filter(region == "National", sample == "Panel") %>% 
  mutate(wave = recode(wave, "Wave 4" = "2018/19", "Wave 5" = "2021/22"))

dna_dyn_plt <- dna_means %>% 
  plot_dyn_nat(title = "Maize DNA")

ggsave(
  filename = "../tmp/figures/dna_dyn_plt.png",
  plot = dna_dyn_plt,
  # device = cairo_pdf,
  width = 8,
  height = 5#,
  # scale = 1.2#,
  # units = "mm"
)

## Purity -----

append_seed_source <- append_seed_source %>% 
  mutate(wave = recode(wave, "Wave 4" = "2018/19", "Wave 5" = "2021/22"))

tit_lab <- "Sample only includes panel households with DNAFP and CG-germplasm."

# Boxplots:
append_seed_source %>%
  filter(cg_source == "Yes", hh_status == "3. Matched") %>%
  ggboxplot(
    y = "purity_percent", x = "wave", fill = "wave"
  ) +
  labs(
    x = "", y = "Genetic purity (%)", fill = "", 
    caption = tit_lab
  )

ggsave(
  filename = "../tmp/figures/purity_box_I.png",
  width = 7,
  height = 5
)

append_seed_source %>%
  filter(!is.na(source), cg_source == "Yes", hh_status == "3. Matched") %>%
  ggboxplot(
    y = "purity_percent", x = "source", fill = "wave"
  ) +
  labs(
    x = "Source of seed", y = "Genetic purity (%)", fill = "", 
    caption = tit_lab
  )

ggsave(
  filename = "../tmp/figures/purity_box_II.png",
  width = 7,
  height = 5
)

append_seed_source %>%
  filter(cg_source == "Yes", hh_status == "3. Matched") %>%
  ggboxplot(
    y = "purity_percent", x = "wave", fill = "wave"
  ) +
  facet_wrap(~type) +
  labs(
    x = "", y = "Genetic purity (%)", fill = "", 
    caption = tit_lab
  )

ggsave(
  filename = "../tmp/figures/purity_box_III.png",
  width = 7,
  height = 5
)


# Density plots:
append_seed_source %>%
  filter(cg_source == "Yes", hh_status == "3. Matched") %>%
  ggdensity(
    x = "purity_percent", rug = TRUE, color = "wave", size = .8
  ) +
  geom_vline(aes(xintercept = 95), linetype = "dashed") +
  labs(
    y = "Density", x = "Genetic purity (%)", color = "", 
    caption = tit_lab
  )

ggsave(
  filename = "../tmp/figures/purity_density_I.png",
  width = 8,
  height = 5
)

append_seed_source %>%
  filter(!is.na(source), cg_source == "Yes", hh_status == "3. Matched") %>%
  ggdensity(
    x = "purity_percent", rug = TRUE, color = "wave", size = .8
  ) +
  geom_vline(aes(xintercept = 95), linetype = "dashed") +
  facet_wrap(~source) +
  labs(
    y = "Density", x = "Genetic purity (%)", color = "", 
    caption = tit_lab
  )

ggsave(
  filename = "../tmp/figures/purity_density_II.png",
  width = 8,
  height = 5
)

append_seed_source %>%
  filter(cg_source == "Yes") %>%
  ggdensity(
    x = "purity_percent", rug = TRUE, color = "wave", size = .8
  ) +
  geom_vline(aes(xintercept = 95), linetype = "dashed") +
  facet_wrap(~type) +
  labs(
    y = "Density", x = "Genetic purity (%)", color = "", 
    caption = tit_lab
  )

ggsave(
  filename = "../tmp/figures/purity_density_III.png",
  width = 8,
  height = 5
)



# Comparing joint adoption rates: ---------


nrm_joint <- joint_rate_tbl %>% 
  # filter(str_detect(label, "NRM")) %>% 
  filter(variable %in% c("nrm_ca", "nrm_tree", "nrm_animal", "nrm_breed",
                         "nrm_psnp")) 

ca_joint <- joint_rate_tbl %>% 
  # filter(str_detect(label, "CA")) %>% 
  filter(variable %in% c("ca_tree", "ca_animal", "ca_breed", "ca_psnp", "ca_maize")) 

agrfrst_joint <- joint_rate_tbl %>% 
  # filter(str_detect(label, "Trees|Breeding")) %>% 
  filter(variable %in% c("tree_animal", "tree_breed", "tree_psnp", "breed_psnp")) 


maize_joint <- joint_rate_tbl %>% 
  # filter(str_detect(label, "Maize")) %>% 
  filter(variable %in% c("nrm_maize", "tree_maize", "animal_maize",
                         "breed_maize", "psnp_maize"))


plot_joint <- function(tbl) {
  
  tbl %>% 
    ggplot(aes(label, joint_rate, fill = wave)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = paste0( round(joint_rate*100, 1) ) ),
              position = position_dodge(width = 1),
              vjust = -.35, size = 3) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
    scale_y_continuous(labels = percent_format()) +
    labs(x = "", y = "Percent",
         title = "Comparing joint adoption rates across waves",
         subtitle = "Data at the household level",
         fill = "") +
    scale_fill_Publication() + 
    theme_Publication() +
    theme(
      legend.position = "top",
      # legend.margin = margin(t = -0.1, unit = "cm"),
      # plot.caption = element_text(hjust = 0),
      axis.title = element_text(size = 12.5),
      plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
    )
  
}


nrm_joint_plt <- plot_joint(nrm_joint) +
  labs(
    caption = "NRM = AWM + SWC practices; CA = Conservation agriculture. 
    Trees = Agroforestry (mango, papaya, & avocado); Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights."
  )

ca_joint_plt <- plot_joint(ca_joint) +
  labs(
    caption = "CA = Conservation agriculture; Trees = Agroforestry (mango, papaya, & avocado); 
    Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights"
    )

agrfrst_joint_plt <- plot_joint(agrfrst_joint) +
  labs(
    caption = "Trees = Agroforestry (mango, papaya, & avocado); Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights"
  )

maize_joint_plt <- plot_joint(maize_joint) +
  labs(
    caption = "NRM = AWM + SWC practices; CA = Conservation agriculture. 
    Trees = Agroforestry (mango, papaya, & avocado); Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights."
  )


joint_plots <- list(nrm_joint_plt, ca_joint_plt, agrfrst_joint_plt, maize_joint_plt)

names(joint_plots) <- c("nrm_joint_plt", "ca_joint_plt", "agrfrst_joint_plt", "maize_joint_plt")

for (i in seq_along(joint_plots)) {
  
  file <- paste0("LSMS_W5/tmp/figures/", names(joint_plots)[[i]], ".pdf")
  
  print(paste("saving to", file))
  
  ggsave(
    filename = file,
    plot = joint_plots[[i]],
    device = cairo_pdf,
    width = 6.5,
    height = 5.2#,
    # scale = 1.2#,
    # units = "mm"
  )
}


# only for panel households

nrm_joint_pnl <- joint_rate_tbl_panel %>% 
  # filter(str_detect(label, "NRM")) %>% 
  filter(variable %in% c("nrm_ca", "nrm_tree", "nrm_animal", "nrm_breed",
                         "nrm_psnp")) 

ca_joint_pnl <- joint_rate_tbl_panel %>% 
  # filter(str_detect(label, "CA")) %>% 
  filter(variable %in% c("ca_tree", "ca_animal", "ca_breed", "ca_psnp", "ca_maize")) 

agrfrst_joint_pnl <- joint_rate_tbl_panel %>% 
  # filter(str_detect(label, "Trees|Breeding")) %>% 
  filter(variable %in% c("tree_animal", "tree_breed", "tree_psnp", "breed_psnp")) 


maize_joint_pnl <- joint_rate_tbl_panel %>% 
  # filter(str_detect(label, "Maize")) %>% 
  filter(variable %in% c("nrm_maize", "tree_maize", "animal_maize",
                         "breed_maize", "psnp_maize"))




nrm_joint_plt_pnl <- plot_joint(nrm_joint_pnl) +
  labs(
    subtitle = "Data at the household level (only panel)",
    caption = "NRM = AWM + SWC practices; CA = Conservation agriculture. 
    Trees = Agroforestry (mango, papaya, & avocado); Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights."
  )

ca_joint_plt_pnl <- plot_joint(ca_joint_pnl) +
  labs(
    subtitle = "Data at the household level (only panel)",
    caption = "CA = Conservation agriculture; Trees = Agroforestry (mango, papaya, & avocado); 
    Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights"
  )

agrfrst_joint_plt_pnl <- plot_joint(agrfrst_joint_pnl) +
  labs(
    subtitle = "Data at the household level (only panel)",
    caption = "Trees = Agroforestry (mango, papaya, & avocado); Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights"
  )

maize_joint_plt_pnl <- plot_joint(maize_joint_pnl) +
  labs(
    subtitle = "Data at the household level (only panel)",
    caption = "NRM = AWM + SWC practices; CA = Conservation agriculture. 
    Trees = Agroforestry (mango, papaya, & avocado); Breeding = Animal crossbreeds.
    Percent are weighted sample means using each wave's respective weights."
  )


joint_plots_pnl <- list(nrm_joint_plt_pnl, ca_joint_plt_pnl, agrfrst_joint_plt_pnl, maize_joint_plt_pnl)

names(joint_plots_pnl) <- c("nrm_joint_plt_pnl", "ca_joint_plt_pnl", "agrfrst_joint_plt_pnl", "maize_joint_plt_pnl")

for (i in seq_along(joint_plots_pnl)) {
  
  file <- paste0("LSMS_W5/tmp/figures/", names(joint_plots_pnl)[[i]], ".pdf")
  
  print(paste("saving to", file))
  
  ggsave(
    filename = file,
    plot = joint_plots_pnl[[i]],
    device = cairo_pdf,
    width = 6.5,
    height = 5.2#,
    # scale = 1.2#,
    # units = "mm"
  )
}


# Choropleth map (Karen's request; May 08, 2023) ----

library(tmap)
library(sp)
library(sf)
library(RColorBrewer)
library(colorspace)


adopt_rates_panel_hh <- read_csv("dynamics_presentation/data/adopt_rates_panel_hh.csv")

eth_regions <- st_read(
  dsn = "./gadm41_ETH_shp",
  layer = "gadm41_ETH_1"
)

eth_contour <- st_read(
  dsn = "./ContourLines-Interval500m",
  layer = "etnaaloscont500m"
)

forages_panel <- adopt_rates_panel_hh %>% 
  filter(variable == "hhd_grass", region != "National") %>% 
  mutate(mean = mean * 100) %>% 
  dplyr::select(wave, region, mean) %>% 
  bind_rows(
    expand_grid(wave = c("Wave 4", "Wave 5"), 
                region = c("Addis Ababa", "Tigray"))
  ) %>% 
  mutate(wave = recode(wave, "Wave 4" = "2018/19", "Wave 5" = "2021/22"))

reg_rename <- eth_regions %>% 
  dplyr::select(region = NAME_1) %>% 
  mutate(region = case_match(
    region, 
    "Addis Abeba" ~ "Addis Ababa",
    "Benshangul-Gumaz" ~ "Benishangul Gumuz",
    "Gambela Peoples" ~ "Gambela",
    "Harari People" ~ "Harar",
    "Southern Nations, Nationalities" ~ "SNNP",
    .default = region
  )) 

region_centroids <- reg_rename %>% 
  st_point_on_surface() %>% 
  st_coordinates() %>% 
  as_tibble() %>% 
  mutate(name = reg_rename$region) %>% 
  rename(x = X, y = Y)

forages_sf <- full_join(
  forages_panel, reg_rename, by = "region"
) %>% 
  st_as_sf()


forage_map <- ggplot(forages_sf) +
  geom_sf(aes(fill = mean)) +
  geom_text(
    data = region_centroids, 
    aes(x, y, label = str_wrap(name, width = 10)),
    size = 3, color = "red"
    ) +
  facet_wrap(~ wave) +
  # theme_void() +
  scale_fill_continuous_sequential(palette = "YlGnBu") +
  theme(
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.line = element_blank(),
    panel.border = element_blank(),
    panel.grid = element_line(color = "transparent"),
    panel.background = element_blank(),
    plot.background = element_rect(fill = "transparent", color = "transparent"),
    strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
    strip.text = element_text(face="bold"),
    legend.position = "bottom",
    legend.key.height = unit(0.3, "cm"),
    legend.key.width = unit(1, "cm"),
    plot.margin = unit(c(0, 0, 0, 0), units = "line"), # top, right, bottom, & left
    legend.margin = margin(b = -0.4, unit = "cm")
    # legend.text = element_text(size = 12, family = "Times"),
    # legend.title = element_text(size = 12, family = "Times")
  ) +
  guides(fill = guide_colorbar(title.position = "top")) +
  labs(fill = "Percent of households adopting", x = "", y = ""
       )


#--- dpi = 320 ---#
ggsave("../tmp/figures/forage_map.png", forage_map, height = 5, width = 10, dpi = 400)


## Topographical map of Ethiopia:

# install and load necessary packages
library(raster)
library(rnaturalearth)

# get country boundaries for Ethiopia
ethiopia <- ne_countries(country = "Ethiopia", returnclass = "sf")

# get topography data for Ethiopia
topo_eth <- getData("alt", country = "ETH")

# plot topography map of Ethiopia
plot(topo_eth, col = terrain.colors(100), main = "Topographical Map of Ethiopia")

# add country boundaries
plot(ethiopia, add = TRUE, border = "red", lwd = 1)


topo_eth_df <- as.data.frame(topo_eth, xy = TRUE) %>% 
  na.omit() %>% 
  as_tibble() %>% 
  mutate(alt = as.numeric(ETH_msk_alt))


topo_map_eth <- ggplot(topo_eth_df) +
  geom_raster(aes(x = x, y = y, fill = alt)) +
  geom_text(
    data = region_centroids, 
    aes(x, y, label = str_wrap(name, width = 10)),
    size = 3, color = "blue"
  ) +
  scale_fill_distiller(palette = "Spectral", direction = 1) +
  geom_sf(data = reg_rename, fill = NA, size = 2) +
  theme(
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.line = element_blank(),
    panel.border = element_blank(),
    panel.grid = element_line(color = "transparent"),
    panel.background = element_blank(),
    plot.background = element_rect(fill = "transparent", color = "transparent"),
    strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
    strip.text = element_text(face="bold"),
    legend.position = "right",
    legend.key.height = unit(.8, "cm"),
    legend.key.width = unit(.5, "cm")#,
    # legend.text = element_text(size = 12, family = "Times"),
    # legend.title = element_text(size = 12, family = "Times")
  ) +
  guides(fill = guide_colorbar(title.position = "top")) +
  labs(fill = "Altitude (m)", x = "", y = "")

ggsave("../tmp/figures/topo_map_eth.png", topo_map_eth, height = 6, width = 8, dpi = 400)




# from Solomon's file:
turnover_year <- tibble(
  title = c(
    "Shift to a newer released improved (most recent one) vs. early or  the same year",
    "Shift to an older released improved vs. newer or  the same year",
    "Shift to the same year released vs. early or later year"
  ),
  value = c(0.3609467, 0.183432, 0.4556213)
)

age_variety <- tibble(
  year = c("2")
)


turnover_year %>% 
  mutate(title = fct_reorder(title, value)) %>% 
  ggplot(aes(value, title, fill = title)) +
  geom_col() +
  geom_text(aes(label = paste0( round(value*100, 1), "%" ) ),
            position = position_dodge(width = 1),
            hjust = -.25, size = 3) +
  expand_limits(x = .5) +
  scale_y_discrete(labels = function(x) str_wrap(x, width = 30)) +
  scale_x_continuous(labels = percent_format()) +
  theme_Publication() +
  theme(legend.position = "none") +
  labs(x = "Percent", y = "", title = "",
       caption = "Sample only includes households shifting from improved to improved varieties.")

ggsave(
  "../tmp/figures/shift_year.png", 
  height = 5, 
  width = 7
)

















