library(tidyverse)
library(stringr)
library(ggplot2)

dir_path <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis/strain_level/simhigh/ontR10"
report_files <- list.files(path = dir_path, pattern = "pantax_fr.*_fc.*_evaluation_report\\.txt", full.names = TRUE)

results <- data.frame()

selected_metrics <- c("f1_score", "strain_precision", "strain_recall", "bc_dist")

for (file in report_files) {
  filename <- basename(file)
  matches <- str_match(filename, "fr([0-9.]+)_fc([0-9.]+)_evaluation_report\\.txt")
  fr_str <- matches[2]
  fc_str <- matches[3]
  
  fr <- as.numeric(fr_str)
  fc <- as.numeric(fc_str)
  
  # 判断粒度类型
  precision <- ifelse(nchar(str_split_fixed(fr_str, "\\.", 2)[,2]) > 1 || 
                        nchar(str_split_fixed(fc_str, "\\.", 2)[,2]) > 1, 
                      "fine", "coarse")
  
  lines <- readLines(file)
  if (length(lines) < 2) {
    row <- data.frame(fr = fr, fc = fc, precision = precision)
    for (metric in selected_metrics) {
      row[[metric]] <- NA 
    }
    results <- bind_rows(results, row)
    next
  }
  
  headers <- str_split(lines[1], "\\s+")[[1]]
  values  <- str_split(lines[2], "\\s*&\\s*")[[1]] %>% as.numeric()
  
  if (length(headers) != length(values)) next
  
  metric <- setNames(values, headers)
  metric_filtered <- metric[selected_metrics]
  
  row <- data.frame(fr = fr, fc = fc, precision = precision, as.list(metric_filtered))
  results <- bind_rows(results, row)
}

# 创建总输出目录
output_dir <- file.path(dir_path, "plots")
dir.create(output_dir, showWarnings = FALSE)

# 遍历 coarse / fine 两种粒度
for (precision_type in c("coarse", "fine")) {
  results_sub <- results %>% filter(precision == precision_type, fr != 1)
  if (nrow(results_sub) == 0) {
    message("Skipping：", precision_type, "\tNo data.")
    next
  }
  
  results_long <- results_sub %>%
    pivot_longer(cols = -c(fr, fc, precision), names_to = "metric", values_to = "value")
  
  sub_output_dir <- file.path(output_dir, precision_type)
  dir.create(sub_output_dir, showWarnings = FALSE)
  
  for (m in unique(results_long$metric)) {
    df_metric <- results_long %>% filter(metric == m)
    
    p <- ggplot(df_metric, aes(x = fr, y = fc, fill = value)) +
      geom_tile(color = "white") +
      geom_text(aes(label = sprintf("%.3f", value)), size = 1.5) +
      scale_fill_gradient(
        low = "#7ac7e2", high = "#af8fd0",
        limits = c(min(df_metric$value, na.rm = TRUE), max(df_metric$value, na.rm = TRUE)),
        name = m
      ) +
      labs(title = paste("Heatmap of", m, "(", precision_type, ")"),
           x = "fr", y = "fc") +
      theme_minimal(base_size = 14)
    
    ggsave(filename = file.path(sub_output_dir, paste0("heatmap_", m, ".pdf")),
           plot = p, width = 6, height = 5)
  }
}
