
## PSNP plots ----

psnp_all_agg %>% 
  filter(region != "Tigray", variable == "hhd_psnp_dir") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .35) +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - all households in each wave")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_all.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 127,
  units = "mm"
)  


psnp_all_local %>% 
  filter(region != "Tigray", variable == "hhd_psnp_dir") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .4) +
  facet_wrap(~ locality, nrow = 2, scales = "free_y") +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - all households in each wave by locality")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_all_local.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 200,
  units = "mm"
)  


psnp_panel_agg %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .35) +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - only panel households")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_all_panel.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 127,
  units = "mm"
)  



psnp_panel_local %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .4) +
  facet_wrap(~ locality, nrow = 2, scales = "free_y") +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - panel households by locality")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_local_panel.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 200,
  units = "mm"
)  


comm_psnp_all_agg %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .35) +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "Community PSNP - all EAs (Urban and Rural)")


ggsave(
  filename = file.path(root, "tmp/figures/comm_psnp_all.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 127,
  units = "mm"
)  



comm_psnp_all_local %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = 1.2) +
  facet_wrap(~ locality, nrow = 2, scales = "free") +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "Community PSNP by locality")


ggsave(
  filename = file.path(root, "tmp/figures/comm_psnp_local.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 200,
  units = "mm"
)  



comm_psnp_panel_agg %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = 1.2) +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "Community PSNP - panel EAs (Urban and Rural)")


ggsave(
  filename = file.path(root, "tmp/figures/comm_psnp_all_panel.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 127,
  units = "mm"
)  


comm_psnp_panel_local %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = 1.2) +
  facet_wrap(~ locality, nrow = 2, scales = "free") +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "Community PSNP by locality - panel EAs")


ggsave(
  filename = file.path(root, "tmp/figures/comm_psnp_local_panel.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 200,
  units = "mm"
) 

