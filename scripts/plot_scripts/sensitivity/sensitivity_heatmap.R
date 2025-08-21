library(tidyverse)
library(stringr)
library(ggplot2)
library(viridis)
library(patchwork)
library(cowplot)

output_dir <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots"
wd <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/sensitivity_analysis/strain_level"
datasets <- c("simlow", "simhigh", "zymo1")
seq_types <- c("ngs", "hifi", "ontR10")

# datasets <- c("simlow")
# seq_types <- c("ngs")
plot_mode <- 2

all_plots <- list()
i <- 1
for (dst in datasets) {
  for (type in seq_types) {
    if ((dst == "simlow" | dst == "simhigh") & type == "ontR10") {
      next
    } 
    if (dst == "zymo1" & type == "hifi") {
      next
    }     
    
    
    data_dir <- file.path(wd, dst, type)
    
    # fr is fstrain, fc is dstrain
    report_files <- list.files(path = data_dir, pattern = "pantax_fr.*_fc.*_evaluation_report\\.txt", full.names = TRUE)
    
    results <- data.frame()
    selected_metrics <- c("strain_precision", "strain_recall", "f1_score", "bc_dist")
    new_selected_metrics <- c("Precision", "Recall", "F1 score", "BC distance")
    
    for (file in report_files) {
      filename <- basename(file)
      matches <- str_match(filename, "fr([0-9.]+)_fc([0-9.]+)_evaluation_report\\.txt")
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
      threshold <- (min(values, na.rm = TRUE) + max(values, na.rm = TRUE)) / 2
      ifelse(values > threshold, "black", "white")
    }

    if (dst == "simlow") {
      dst_label = "sim-low"
    } else if (dst == "simhigh") {
      dst_label = "sim-high"
    } else if (dst == "zymo1") {
      dst_label = "Zymo1"
    }
    
    if (type == "ngs") {
      type_label = "NGS"
    } else if (type == "hifi") {
      type_label = "PacBio HiFi"
    } else if (type == "ontR10") {
      type_label = "ONT R10"
    }
        
    plot_and_save_combined <- function(data, data_precision_level, output_dir) {
      data_subset <- data %>% filter(data_precision == data_precision_level,fstrain != 1)
      
      data_long <- data_subset %>%
        pivot_longer(cols = all_of(selected_metrics), names_to = "metric", values_to = "value") %>%
        group_by(metric) %>%
        mutate(text_color = get_text_color(value)) %>%
        ungroup()
      
      plot_list <- list()
      
      for (m in selected_metrics) {
        df_m <- data_long %>% filter(metric == m)
        plot_label <- paste(dst_label, type_label, m)
        p <- ggplot(df_m, aes(x = fstrain, y = dstrain, fill = value)) +
          geom_tile(color = "white", linewidth = 0.3) +
          geom_text(aes(label = sprintf("%.3f", value), color = text_color), size = 4) +
          scale_fill_viridis_c(option = "plasma", name = m) +
          scale_color_identity() +
          scale_x_continuous(labels = function(x) ifelse(x == 1, "", x))+
          labs(title = plot_label, x = "fstrain", y = "dstrain") +
          theme_minimal(base_size = 16) +
          theme(
            plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
            axis.text = element_text(color = "black", size = 14),
            axis.title = element_text(face = "bold", size = 15),
            panel.grid = element_blank(),
            legend.position = "right",
            plot.margin = if (data_precision_level == "fine") margin(1, 1, 1, 1) else margin(3, 3, 3, 3),
            panel.spacing = if (data_precision_level == "fine") unit(0.1, "lines") else unit(0.5, "lines")
          ) +
          theme(aspect.ratio = 1)
        
        
        plot_list[[m]] <- p
      }
      
      pdf_file <- file.path(output_dir, sprintf("sensitity_fstrain_dstrain_%s_%s_%s.pdf", dst, type, data_precision_level))
      
      if (plot_mode == 0) {
        combined_plot <- (plot_list[[1]] | plot_list[[2]]) / (plot_list[[3]] | plot_list[[4]])
        ggsave(pdf_file, combined_plot, width = if (data_precision_level == "fine") 25 else 16, height = if (data_precision_level == "fine") 25 else 16)
        message("save plots", pdf_file)
      } else if (plot_mode == 1) {
        combined_plot <- plot_list[[1]] | plot_list[[2]] | plot_list[[3]] | plot_list[[4]]
        ggsave(pdf_file, combined_plot, width = 30, height = 6)
        message("save plots", pdf_file)
      } else if (plot_mode == 2) {
        # combined_plot <- (plot_list[[1]] | plot_list[[2]] | plot_list[[3]] | plot_list[[4]])
        row_plot <- plot_grid(plot_list[[1]], plot_list[[2]], plot_list[[3]], plot_list[[4]],
                              ncol = 4, align = "hv")
        
        combined_plot <- ggdraw(row_plot) +
          draw_plot_label(label = LETTERS[i], x = 0, y = 1, hjust = 0, vjust = 1, size = 20)
        i <<- i+1
        return(combined_plot)
      }
      
      
    }
    
    if (plot_mode %in% c(0, 1)) {
      plot_and_save_combined(results, "coarse", output_dir)
      # plot_and_save_combined(results, "fine", output_dir)      
    } else if (plot_mode == 2) {
      all_plots[[paste(dst, type, sep = "_")]] <- plot_and_save_combined(results, "coarse", output_dir)
    }


  }
}

if (plot_mode == 2) {
  
  final_plot <- plot_grid(plotlist = all_plots, ncol = 1, scale = 0.98)

  ggsave(file.path(output_dir, "sensitivity_fstrain_dstrain_all.pdf"), final_plot, width = 30, height = 36)
  
  ggsave(file.path(output_dir, "sensitivity_fstrain_dstrain_all.pdf"), final_plot, width = 32, height = 38)
  }


