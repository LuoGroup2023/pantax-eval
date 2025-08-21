library(tidyverse)
library(stringr)
library(ggplot2)
library(viridis)
library(cowplot)
library(patchwork)

output_dir <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots"

datasets <- c("simlow", "simhigh")
seq_types <- c("ngs", "hifi")
plot_mode <- 2
all_plots <- list()
for (dst in datasets) {
  for (type in seq_types) {
    data_dir <- file.path("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis/strain_level", dst, type, "low_eval")
    
    # fr is fstrain, fc is dstrain
    report_files <- list.files(path = data_dir, pattern = "pantax_fr.*_fc.*_low_evaluation_report\\.txt", full.names = TRUE)
    
    results <- data.frame()
    selected_metrics <- c("strain_recall")
    new_selected_metrics <- c("Recall")
    
    for (file in report_files) {
      filename <- basename(file)
      matches <- str_match(filename, "fr([0-9.]+)_fc([0-9.]+)_low_evaluation_report\\.txt")
      if (any(is.na(matches))) next
      
      fr_str <- matches[2]
      fc_str <- matches[3]
      fr <- as.numeric(fr_str)
      fc <- as.numeric(fc_str)
      
      data_precision <- ifelse(
        nchar(str_split_fixed(fr_str, "\\.", 2)[,2]) > 1 ||
          nchar(str_split_fixed(fc_str, "\\.", 2)[,2]) > 1,
        "fine", "coarse"
      )
      
      lines <- readLines(file)
      if (length(lines) < 2) next
      
      headers <- str_split(lines[1], "\\s+")[[1]]
      values <- str_split(lines[2], "\\s*&\\s*")[[1]] %>% as.numeric()
      
      if (length(headers) != length(values)) next
      
      metric <- setNames(values, headers)
      metric_filtered <- setNames(metric[selected_metrics], new_selected_metrics)
      
      row <- data.frame(fstrain = fr, dstrain = fc, data_precision = data_precision, as.list(metric_filtered), check.names = FALSE)
      results <- bind_rows(results, row)
    }
    
    selected_metrics <- new_selected_metrics
    
    if (nrow(results) == 0) stop("No report files were successfully read")
    
    get_text_color <- function(values) {
      if (all(is.na(values))) {
        return(rep("gray", length(values))) 
      }
      threshold <- (min(values, na.rm = TRUE) + max(values, na.rm = TRUE)) / 2
      ifelse(values > threshold, "black", "white")
    }

    if (dst == "simlow") {
      dst_label = "sim-low"
    } else if (dst == "simhigh") {
      dst_label = "sim-high"
    }

    if (type == "ngs") {
      type_label = "NGS"
    } else if (type == "hifi") {
      type_label = "PacBio HiFi"
    }
        
    plot_and_save_combined <- function(data, data_precision_level, output_dir) {
      data_subset <- data %>% filter(data_precision == data_precision_level,fstrain != 1)
      
      data_long <- data_subset %>%
        pivot_longer(cols = all_of(selected_metrics), names_to = "metric", values_to = "value") %>%
        group_by(metric) %>%
        mutate(text_color = get_text_color(value)) %>%
        ungroup()
      
      
      for (m in selected_metrics) {
        df_m <- data_long %>% filter(metric == m)
        plot_label <- paste(dst_label, type_label, m)
        p <- ggplot(df_m, aes(x = fstrain, y = dstrain, fill = value)) +
          geom_tile(color = "white", linewidth = 0.3) +
          geom_text(aes(label = sprintf("%.3f", value), color = text_color), size = 3) +
          scale_fill_viridis_c(option = "plasma", name = m) +
          scale_color_identity() +
          scale_x_continuous(labels = function(x) ifelse(x == 1, "", x))+
          labs(title = plot_label, x = "fstrain", y = "dstrain") +
          theme_minimal(base_size = 16) +
          theme(
            plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
            axis.text = element_text(color = "black", size = 14),
            axis.title = element_text(face = "bold", size = 15),
            panel.grid = element_blank(),
            legend.position = "right",
            plot.margin = if (data_precision_level == "fine") margin(1, 1, 1, 1) else margin(3, 3, 3, 3),
            panel.spacing = if (data_precision_level == "fine") unit(0.1, "lines") else unit(0.5, "lines")
          ) +
          theme(aspect.ratio = 1)
        
        
      }
      
      if (plot_mode == 1) {
        pdf_file <- file.path(output_dir, sprintf("sensitity_fstrain_dstrain_low_%s_%s_%s.pdf", dst, type, data_precision_level))
        ggsave(pdf_file, p, width = if (data_precision_level == "fine") 25 else 6, height = if (data_precision_level == "fine") 25 else 6)
        message("save plots", pdf_file)        
      } else {
        return(p)
      }

    }
    
    if (plot_mode == 1){
      plot_and_save_combined(results, "coarse", output_dir)
    } else if (plot_mode == 2) {
      all_plots[[paste(dst, type, sep = "_")]] <- plot_and_save_combined(results, "coarse", output_dir)
    }
    
    
  }
}

if (plot_mode == 2) {
  
  final_plot <- wrap_plots(all_plots, ncol = 2) + plot_annotation(tag_levels = "A")
  
  ggsave(file.path(output_dir, "low_sensitivity_fstrain_dstrain_all.pdf"), final_plot, width = 12, height = 12)
  ggsave(file.path(output_dir, "low_sensitivity_fstrain_dstrain_all.png"), final_plot, width = 12, height = 12, bg = "white")
}
