
plot_dna <- function(tbl, ylim) {
  tbl %>% 
    filter(region != "Tigray") %>% 
    ggplot(aes(region, mean, fill = wave)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = paste0( round(mean*100, 2), "%", "\n(", nobs, ")" ) ),
              position = position_dodge(width = 1),
              vjust = -.35, size = 2.5) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
    scale_y_continuous(labels = percent_format()) +
    expand_limits(y = ylim) +
    labs(x = "", y = "Percent", fill = "")
}

maize_plot <- dna_means %>% 
  filter(improvment == "hhd_maize_cg") %>% 
  plot_dna(ylim = 1) +
  labs(title = "Maize - CG germplasm")

dtmz_plot <- dna_means %>% 
  filter(improvment == "hhd_dtmz") %>% 
  plot_dna(ylim = .6) +
  labs(title = "Drought tolerant maize",
       caption = "Percent are weighted sample means.
       Number of responding households in parenthesis")


maize_dna <- ggarrange(
  maize_plot, dtmz_plot, 
  nrow = 2,
  common.legend = TRUE
) 

ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/maize_dna_plot.pdf"),
  plot = maize_dna,
  device = cairo_pdf,
  width = 185,
  height = 285,
  scale = .8,
  units = "mm"
) 