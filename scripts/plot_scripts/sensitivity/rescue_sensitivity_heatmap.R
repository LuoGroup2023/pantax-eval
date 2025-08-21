

library(tidyverse)
library(stringr)
library(ggplot2)
library(viridis)
library(patchwork)
library(dplyr)

output_dir <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots"

datasets <- c("simlow", "simhigh")
seq_types <- c("ngs", "hifi")

results <- data.frame()
for (dst in datasets) {
  for (type in seq_types) {
    data_dir <- file.path("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis/strain_level", dst, type, "rescue_sensitivity")
    
    # fr is fstrain, fc is dstrain
    report_files <- list.files(path = data_dir, pattern = "pantax_fr.*_fc.*_rescue.*_evaluation_report\\.txt", full.names = TRUE)
    
    selected_metrics <- c("strain_precision", "strain_recall", "f1_score", "bc_dist")
    new_selected_metrics <- c("Precision", "Recall", "F1 score", "BC distance")
    
    for (file in report_files) {
      filename <- basename(file)
      matches <- str_match(filename, "fr([0-9.]+)_fc([0-9.]+)_rescue([0-9.]+)_evaluation_report\\.txt")
      if (any(is.na(matches))) next
      
      fr_str <- matches[2]
      fc_str <- matches[3]
      rescue_str <- matches[4]
      fr <- as.numeric(fr_str)
      fc <- as.numeric(fc_str)
      rescue <- as.numeric(rescue_str)
      
      lines <- readLines(file)
      if (length(lines) < 2) next
      
      headers <- str_split(lines[1], "\\s+")[[1]]
      values <- str_split(lines[2], "\\s*&\\s*")[[1]] %>% as.numeric()
      
      if (length(headers) != length(values)) next
      
      metric <- setNames(values, headers)
      metric_filtered <- setNames(metric[selected_metrics], new_selected_metrics)
      
      row <- data.frame(sample = paste0(dst, "_", type), rescue = rescue, as.list(metric_filtered), check.names = FALSE)
      results <- bind_rows(results, row)
    }
    
    if (nrow(results) == 0) stop("No report files were successfully read")
  }
}

# results <- results %>%
#   separate("sample", into = c("dataset", "sample_id"), sep = "_") %>%
#   mutate(sample_id = recode(sample_id, "ngs" = "NGS", "hifi" = "Pacbio HiFi")) %>%
#   mutate(dataset = recode(dataset, "simlow" = "sim-low", "simhigh" = "sim-high"))

results <- results %>%
  mutate(sample = str_replace_all(sample, c("ngs" = "NGS", "hifi" = "Pacbio HiFi"))) %>%
  mutate(sample = str_replace_all(sample, c("simlow" = "sim-low", "simhigh" = "sim-high"))) %>%
  mutate(sample = str_replace_all(sample, c("_" = " ")))

get_text_color <- function(values) {
  if (all(is.na(values))) {
    return(rep("gray", length(values))) 
  }
  threshold <- (min(values, na.rm = TRUE) + max(values, na.rm = TRUE)) / 2
  ifelse(values > threshold, "black", "white")
}

selected_metrics <- c("Precision", "Recall", "F1 score", "BC distance")
data_long <- results %>%
  pivot_longer(cols = all_of(selected_metrics), names_to = "metric", values_to = "value") %>%
  group_by(metric) %>%
  mutate(text_color = get_text_color(value)) %>%
  ungroup()

plot_list <- list()

for (m in selected_metrics) {
  df_m <- data_long %>% filter(metric == m)
  
  p <- ggplot(df_m, aes(x = rescue, y = sample, fill = value)) +
    geom_tile(color = "white", linewidth = 0.3) +
    geom_text(aes(label = sprintf("%.3f", value), color = text_color), size = 2) +
    scale_fill_viridis_c(option = "plasma", name = m) +
    scale_color_identity() +
    scale_x_continuous(labels = function(x) ifelse(x == 1, "", x))+
    labs(title = m, x = "rstrain", y = "Datasets") +
    theme_minimal(base_size = 16) +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      axis.text = element_text(color = "black", size = 14),
      axis.title = element_text(face = "bold", size = 15),
      panel.grid = element_blank(),
      legend.position = "right",
      plot.margin = margin(1, 1, 3, 3),
      panel.spacing = unit(1, "lines")
    ) +
    theme(aspect.ratio = 1)
  
  
  plot_list[[m]] <- p
}

combined_plot <- (plot_list[[1]] | plot_list[[2]]) / (plot_list[[3]] | plot_list[[4]])
pdf_file <- file.path(output_dir, "rescue_sensitivity.pdf")
ggsave(pdf_file, combined_plot, width = 16, height = 8)
ggsave(file.path(output_dir, "rescue_sensitivity.png"), combined_plot, width = 16, height = 8)
message("save plots", pdf_file)
