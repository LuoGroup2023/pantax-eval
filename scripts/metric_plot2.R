library(ggplot2)
library(tidyr)
library(ggpattern)
library(ggpubr)
library(gridExtra)

setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts")
tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")

generate_plot <- function(file_path, plot_label) {
  data <- read.csv(file_path, sep = "\t")

  if ("sample_id" %in% colnames(data)) {
    colnames(data)[1] <- "Tools"
    colnames(data)[5] <- "precision"
    colnames(data)[6] <- "recall"
    colnames(data)[7] <- "f1_score"
    colnames(data)[8] <- "AUPR"
    colnames(data)[9] <- "l2_dist"
    colnames(data)[10] <- "AFE"
    colnames(data)[11] <- "RFE"
    colnames(data)[12] <- "l1_dist"
    colnames(data)[13] <- "bc_dist"
    
    filter_data <- data[, c(1, 5, 6)]
  } else {
    data <- data %>%
      mutate(sample_id = ifelse("sample_id" %in% colnames(.), sample_id, "NGS")) 
    colnames(data)[1] <- "Tools"
    colnames(data)[3] <- "precision"
    colnames(data)[4] <- "recall"
    colnames(data)[5] <- "f1_score"
    colnames(data)[6] <- "AUPR"
    colnames(data)[7] <- "l2_dist"
    colnames(data)[8] <- "AFE"
    colnames(data)[9] <- "RFE"
    colnames(data)[10] <- "l1_dist"
    colnames(data)[11] <- "bc_dist"
    
    filter_data <- data[, c(1, 3, 4)]    
  }
  
  filter_data$Tools <- factor(filter_data$Tools, levels = c("PanTax", "PanTax(fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))

  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(x == "-")), ]

  data_long <- pivot_longer(filter_data, cols = c(precision, recall), names_to = "Metrics", values_to = "value")
  data_long$value <- as.numeric(data_long$value)

  data_long$value <- ifelse(data_long$Metrics == "precision", -data_long$value, data_long$value)
  
  data_long$Tools <- factor(data_long$Tools, levels = c("PanTax", "PanTax(fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))
  # 绘制条形图
  p <- ggplot(data_long, aes(x = Tools, y = value, fill = Tools, pattern = Metrics)) +
    geom_bar_pattern(stat = "identity", position = "stack", pattern_density = 0.01, pattern_angle = 45) +  # 调整position参数为stack
    coord_flip() + 
    scale_pattern_manual(values = c(precision = NA, recall = "stripe")) +
    scale_fill_manual(values = tool_colors) +  
    labs(x = "Tools", y = "Score", fill = "Tools") +
    theme_minimal() +
    scale_y_continuous(labels = abs) +    # 确保y轴从0开始，负值显示为正值
    theme(
  #    legend.position = "right",
  #    axis.text.x = element_blank(),  # 隐藏x轴文本
  #   axis.text.y = element_blank(),   # 隐藏y轴文本
      axis.text.x = element_text(color = "black", face = "bold"),  
      axis.text.y = element_text(color = "black", face = "bold"),
      legend.position = "none"         # 隐藏图例
    ) +
    guides(pattern = "none")
  
  # 添加文本标签
  p_with_label <- grid.arrange(p, bottom = text_grob(plot_label, size = 12, face = "bold", hjust = 0.2))
  
  if (ncol(data) == 12) {
    filter_data <- data[, c(1, 11)]
  } else {
    filter_data <- data[, c(1, 13)]
  }  
  
  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(grepl("-", x)) | any(is.na(x))), ]    
  filter_data$bc_dist <- as.numeric(filter_data$bc_dist)
  filter_data$Tools <- factor(filter_data$Tools, levels = c("PanTax", "PanTax(fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))
  p <- ggplot(filter_data, aes(x = Tools, y = bc_dist, fill = Tools)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = sprintf("%.3f", bc_dist)), vjust = -0.5, color = "black", size = 3) +  
    scale_fill_manual(values = tool_colors) +  
    labs(x = "Tools", y = "BC distance") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold"),  
      axis.text.y = element_text(color = "black", face = "bold"),
      legend.position = "none"
    ) +
    scale_y_continuous(limits = c(0, 1))
  p_bc <-  grid.arrange(p, bottom = text_grob(plot_label, size = 12, face = "bold"))
  return(list(p_with_label, p_bc))
}


get_only_legend <- function(plot) {
  plot_table <- ggplot_gtable(ggplot_build(plot))
  legend_plot <- which(sapply(plot_table$grobs, function(x) x$name) == "guide-box")
  legend <- plot_table$grobs[[legend_plot]]
  return(legend)
}

generate_legend <- function(data) {
  # data <- read.csv(file_path, sep = "\t")
  
  if ("sample_id" %in% colnames(data)) {
    colnames(data)[1] <- "Tools"
    colnames(data)[5] <- "precision"
    colnames(data)[6] <- "recall"
    colnames(data)[7] <- "f1_score"
    colnames(data)[8] <- "AUPR"
    colnames(data)[9] <- "l2_dist"
    colnames(data)[10] <- "AFE"
    colnames(data)[11] <- "RFE"
    colnames(data)[12] <- "l1_dist"
    colnames(data)[13] <- "bc_dist"
    
    filter_data <- data[, c(1, 13)]
  } else {
    data <- data %>%
      mutate(sample_id = ifelse("sample_id" %in% colnames(.), sample_id, "NGS")) 
    colnames(data)[1] <- "Tools"
    colnames(data)[3] <- "precision"
    colnames(data)[4] <- "recall"
    colnames(data)[5] <- "f1_score"
    colnames(data)[6] <- "AUPR"
    colnames(data)[7] <- "l2_dist"
    colnames(data)[8] <- "AFE"
    colnames(data)[9] <- "RFE"
    colnames(data)[10] <- "l1_dist"
    colnames(data)[11] <- "bc_dist"
    
    filter_data <- data[, c(1, 11)]    
  }
  
  
  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(grepl("-", x)) | any(is.na(x))), ]    
  filter_data$bc_dist <- as.numeric(filter_data$bc_dist)
  
 
  legend_plot <- ggplot(filter_data, aes(x = Tools, y = bc_dist, fill = Tools)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = sprintf("%.3f", bc_dist)), vjust = -0.5, color = "black", size = 3) +  
    scale_fill_manual(values = tool_colors) +  
    labs(x = "Tools", y = "BC distance") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold"),  
      axis.text.y = element_text(color = "black", face = "bold"),
      legend.position = "bottom"
    ) +
    scale_y_continuous(limits = c(0, 1))
  legend <- get_only_legend(legend_plot) 
  return(legend)
}




generate_merge_plot <- function(file_paths, plot_labels, output_file_path){
  plot_list_base <- list()
  plot_bc <- list()
  
  for (i in 1:length(file_paths)) {
    pl <- generate_plot(file_paths[i], plot_labels[i])
    plot_list_base[i] <- pl[1]
    plot_bc[i] <- pl[2]
  }
  n_plots_base <- length(plot_list_base)
  n_plots_bc <- length(plot_bc)
  
  ncol_base <- ifelse(n_plots_base == 10, 2, ifelse(n_plots_base == 3, 3, 1))
  nrow_base <- ifelse(n_plots_base == 3, 1, 5)
  
  ncol_bc <- ifelse(n_plots_bc == 10, 2, ifelse(n_plots_bc == 3, 3, 1))
  nrow_bc <- ifelse(n_plots_bc == 3, 1, 5)
  
  # 生成图
  final_plot_base <- plot_grid(
    plotlist = plot_list_base, ncol = ncol_base, nrow = nrow_base,
    rel_heights = rep(1, nrow_base)  
  )
  
  final_plot_bc <- plot_grid(
    plotlist = plot_bc, ncol = ncol_bc, nrow = nrow_bc,
    rel_heights = rep(1, nrow_bc)
  )
  # get legend
  tools <- unlist(lapply(file_paths, function(file) {
    # Read the first column from the file
    data <- read.csv(file, sep = "\t")
    # Extract the first column
    return(data[, 1])
  }))
  
  # Get unique tool names
  unique_tools <- unique(tools)
  data <- read.csv("report/example_all_tools.tsv", sep = "\t")
  
  # Filter rows where the tool in the first column is in unique_tools
  filtered_data <- subset(data, data[, 1] %in% unique_tools)
  legend <- generate_legend(filtered_data)
  # Combine the plots with the legend
  
  # final_plot_base_with_legend <- grid.arrange(final_plot_base, legend, nrow = 2, heights = c(20, 1))  
  final_plot_bc_with_legend <- grid.arrange(final_plot_bc, legend, nrow = 2, heights = c(20, 1))
  if (length(grep("single_species", output_file_path)) == 0){
    ggsave(paste0(output_file_path, "_base_merge.pdf"), plot = final_plot_base, dpi = 300, width = 10, height = 15)
    ggsave(paste0(output_file_path, "_bc_merge.pdf"), plot = final_plot_bc_with_legend, dpi = 300, width = 10, height = 15)
  } else {
    ggsave(paste0(output_file_path, "_base_merge.pdf"), plot = final_plot_base, dpi = 300, width = 8, height = 2)
    ggsave(paste0(output_file_path, "_bc_merge.pdf"), plot = final_plot_bc_with_legend, dpi = 300, width = 10, height = 5)   
  }

}


file_paths <- c("report/simlow-gtdb/ngs.tsv", "report/simhigh-gtdb/ngs.tsv", "report/simlow-gtdb/hifi.tsv", 
                "report/simhigh-gtdb/hifi.tsv", "report/simlow-gtdb/clr.tsv", "report/simhigh-gtdb/clr.tsv",
                "report/simlow-gtdb/ontR9.tsv", "report/simhigh-gtdb/ontR9.tsv", "report/simlow-gtdb/ontR10.tsv",
                "report/simhigh-gtdb/ontR10.tsv")
plot_labels <- c("simlow-gtdb-NGS", "simhigh-gtdb-NGS", "simlow-gtdb-PacBio HiFi", "simhigh-gtdb-PacBio HiFi",
                 "simlow-gtdb-PacBio CLR", "simhigh-gtdb-PacBio CLR", "simlow-gtdb-ONT R941", "simhigh-gtdb-ONT R941",
                 "simlow-gtdb-ONT R104", "simhigh-gtdb-ONT R104")
output_file_path <- "report/plots/gtdb"
generate_merge_plot(file_paths, plot_labels, output_file_path)

file_paths_base <- c("report/simlow/ngs.tsv", "report/simhigh/ngs.tsv", "report/simlow/hifi.tsv", 
                     "report/simhigh/hifi.tsv", "report/simlow/clr.tsv", "report/simhigh/clr.tsv",
                     "report/simlow/ontR9.tsv", "report/simhigh/ontR9.tsv", "report/simlow/ontR10.tsv",
                     "report/simhigh/ontR10.tsv")

plot_labels <- c("simlow-NGS", "simhigh-NGS", "simlow-PacBio HiFi", "simhigh-PacBio HiFi",
                 "simlow-PacBio CLR", "simhigh-PacBio CLR", "simlow-ONT R941", "simhigh-ONT R941",
                 "simlow-ONT R104", "simhigh-ONT R104")
output_file_path <- "report/plots/base"
generate_merge_plot(file_paths_base, plot_labels, output_file_path)

file_paths_spiked_in_eight <- c("report/spiked_in_eight_species666_large_pangenome/ngs.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/hifi.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/clr.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/ontR9.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/ontR10.tsv")
plot_labels <- c("spiked in-NGS", "spiked in-NGS", "spiked in-PacBio HiFi", "spiked in-PacBio HiFi",
                 "spiked in-PacBio CLR")
output_file_path <- "report/plots/spiked_in"
generate_merge_plot(file_paths_spiked_in_eight, plot_labels, output_file_path)

file_paths_single_species_multi_strains <- c("report/3strains/3strains.tsv", 
                                             "report/5strains/5strains.tsv", 
                                             "report/10strains/10strains.tsv")
dataset_label_single_species_multi_strains <- c("3 strains", "5 strains", "10 strains")
output_file_path <- "report/plots/single_species_multi_strains"
generate_merge_plot(file_paths_single_species_multi_strains, dataset_label_single_species_multi_strains, output_file_path)




 


