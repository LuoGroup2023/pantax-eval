

library(ggradar)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(cowplot)
library(patchwork)
file_path <- "report/simlow/ngs.tsv"

radar_plot <- function(file_path, plot_label, output_file_path) {
  data <- read.csv(file_path, sep = "\t")
  
  if ("sample_id" %in% colnames(data)) {
    colnames(data)[1] <- "Tools"
    colnames(data)[5] <- "Precision"
    colnames(data)[6] <- "Recall"
    colnames(data)[7] <- "F1"
    colnames(data)[8] <- "AUPR"
    colnames(data)[9] <- "L2 distance"
    colnames(data)[10] <- "AFE"
    colnames(data)[11] <- "RFE"
    colnames(data)[12] <- "1-L1"
    colnames(data)[13] <- "1-BC"
    
    filter_data <- data[, c(1, 5:8, 12:13)]
  } else {
    data <- data %>%
      mutate(sample_id = ifelse("sample_id" %in% colnames(.), sample_id, "NGS"))
    colnames(data)[1] <- "Tools"
    colnames(data)[3] <- "Precision"
    colnames(data)[4] <- "Recall"
    colnames(data)[5] <- "F1 score"
    colnames(data)[6] <- "AUPR"
    colnames(data)[7] <- "L2 distance"
    colnames(data)[8] <- "AFE"
    colnames(data)[9] <- "RFE"
    colnames(data)[10] <- "L1 distance"
    colnames(data)[11] <- "BC distance"
    
    filter_data <- data[, c(1, 3:11)]
  }
  
  filter_data <- filter_data[filter_data$Tools != "Centrifuge", ]
  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(grepl("-", x)) | any(is.na(x))), ]
  
  # filter_data[, 2:7] <- lapply(filter_data[, 2:7], as.numeric)
  
  filter_data[,-1] <- sapply(filter_data[,-1],as.numeric)
  filter_data[, c("1-L1", "1-BC")] <- 1 - filter_data[, c("1-L1", "1-BC")]
  max_value <- max(filter_data[, -1], na.rm = TRUE)
  min_value <- min(filter_data[, -1], na.rm = TRUE)
  if (max_value < 1) {
    max_value = 1
  }
  if (min_value > 0) {
    min_value = 0
  }
  print(max_value)
  
  tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                  "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                  "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")
  filter_data$Tools <- factor(filter_data$Tools, levels = c("KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst", "PanTax(fast)", "PanTax"))
  p <- ggradar(
    filter_data,
    grid.min = min_value,
    grid.mid = 0.5,
    grid.max = max_value,
    values.radar = seq(0, 1, by = 0.5),
    group.colours = tool_colors,
    group.line.width = 0.8,
    group.point.size = 4,
    line.alpha = 0.3,
    legend.position = "None"
  ) + ggtitle(plot_label) +
    theme(plot.title = element_text(hjust = 0.5, size = 20, color = "black", face = "bold"),
          # plot.background = element_rect(color = "blue", size = 2)
          )
  
  ggsave(paste0(output_file_path, "_radar_ori.pdf"), plot = p, dpi = 300)
  return(p)
}

# file_paths_base <- c("report/simlow/ngs.tsv", "report/simhigh/ngs.tsv", "report/simlow/hifi.tsv", 
#                      "report/simhigh/hifi.tsv", "report/simlow/clr.tsv", "report/simhigh/clr.tsv",
#                      "report/simlow/ontR9.tsv", "report/simhigh/ontR9.tsv", "report/simlow/ontR10.tsv",
#                      "report/simhigh/ontR10.tsv")
# plot_labels <- c("sim-low NGS", "sim-high NGS", "sim-low PacBio HiFi", "sim-high PacBio HiFi",
#                  "sim-low PacBio CLR", "sim-high PacBio CLR", "sim-low ONT R9.4.1", "sim-high ONT R9.4.1", 
#                  "sim-low ONT R10.4", "sim-high ONT R10.4")
file_paths_base <- c("report/simlow/ngs.tsv", "report/simlow/hifi.tsv", "report/simlow/clr.tsv", 
                     "report/simlow/ontR9.tsv", "report/simlow/ontR10.tsv", 
                     "report/simhigh/ngs.tsv", "report/simhigh/hifi.tsv", "report/simhigh/clr.tsv",
                      "report/simhigh/ontR9.tsv", "report/simhigh/ontR10.tsv")
plot_labels <- c("sim-low NGS", "sim-low PacBio HiFi", "sim-low PacBio CLR", "sim-low ONT R9.4.1", "sim-low ONT R10.4", 
                 "sim-high NGS", "sim-high PacBio HiFi", "sim-high PacBio CLR", "sim-high ONT R9.4.1", "sim-high ONT R10.4")

output_file_path <- "report/plots/base"

# radar_plot(file_paths_base[10], plot_labels[10], output_file_path)
plots <- list()

for (i in 1:length(file_paths_base)) {
  print(plot_labels[i])
  plots[[i]] <- radar_plot(file_paths_base[i], plot_labels[i], output_file_path)
}
p <- plot_grid(plotlist = plots, ncol = 5, nrow = 2, align = "hv")

# p <- grid.arrange(grobs = plots, ncol = 2, nrow = 5)
# ggsave(paste0(output_file_path, "_radar.pdf"), plot = p, dpi = 300)


radar_plot_legend <- function(file_path, plot_label, output_file_path) {
  data <- read.csv(file_path, sep = "\t")
  
  if ("sample_id" %in% colnames(data)) {
    colnames(data)[1] <- "Tools"
    colnames(data)[5] <- "Precision"
    colnames(data)[6] <- "Recall"
    colnames(data)[7] <- "F1 score"
    colnames(data)[8] <- "AUPR"
    colnames(data)[9] <- "L2 distance"
    colnames(data)[10] <- "AFE"
    colnames(data)[11] <- "RFE"
    colnames(data)[12] <- "1-L1 distance"
    colnames(data)[13] <- "1-BC distance"
    
    filter_data <- data[, c(1, 5:8, 12:13)]
  } else {
    data <- data %>%
      mutate(sample_id = ifelse("sample_id" %in% colnames(.), sample_id, "NGS"))
    colnames(data)[1] <- "Tools"
    colnames(data)[3] <- "Precision"
    colnames(data)[4] <- "Recall"
    colnames(data)[5] <- "F1 score"
    colnames(data)[6] <- "AUPR"
    colnames(data)[7] <- "L2 distance"
    colnames(data)[8] <- "AFE"
    colnames(data)[9] <- "RFE"
    colnames(data)[10] <- "L1 distance"
    colnames(data)[11] <- "BC distance"
    
    filter_data <- data[, c(1, 3:11)]
  }
  filter_data[, c("1-L1 distance", "1-BC distance")] <- 1 - filter_data[, c("1-L1 distance", "1-BC distance")]
  
  filter_data <- filter_data[filter_data$Tools != "Centrifuge", ]
  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(grepl("-", x)) | any(is.na(x))), ]
  
  filter_data[,-1] <- sapply(filter_data[,-1],as.numeric)
  
  max_value <- max(filter_data[, -1], na.rm = TRUE)
  if (max_value < 1) {
    max_value = 1
  }
  print(max_value)
  
  tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                  "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                  "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")
  filter_data$Tools <- factor(filter_data$Tools, levels = c("PanTax(fast)", "PanTax", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))
  p <- ggradar(
    filter_data,
    grid.min = 0,
    grid.mid = 0.5,
    grid.max = max_value,
    values.radar = seq(0, 1, by = 0.5),
    group.colours = tool_colors,
    group.line.width = 0.8,
    group.point.size = 4,
    line.alpha = 0.5,
    legend.position = "bottom"
  ) + ggtitle(plot_label) +
    theme(plot.title = element_text(hjust = 0.5, size = 20, color = "black", face = "bold"))
  
  return(p)
}

get_only_legend <- function(plot) {
  plot_table <- ggplot_gtable(ggplot_build(plot))
  legend_plot <- which(sapply(plot_table$grobs, function(x) x$name) == "guide-box")
  legend <- plot_table$grobs[[legend_plot]]
  return(legend)
}
legend_plot <- radar_plot_legend(file_paths_base[1], plot_labels[1], output_file_path)
legend1 <- get_only_legend(legend_plot) 
# p <- plot_grid(p, legend1, nrow = 2, ncol = 1)
# p <- grid.arrange(p, legend1, nrow = 2, heights = c(20, 1))
# legend1 <- get_legend(legend_plot)
save_plot(paste0(output_file_path, "_radar.pdf"), p,
          ncol = 5, # we're saving a grid plot of 2 columns
          nrow = 2, # and 2 rows
          # each individual subplot should have an aspect ratio of 1.3
          base_asp = 1)
