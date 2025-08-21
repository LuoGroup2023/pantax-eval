
library(ggplot2)
library(tidyr)
library(ggpattern)
library(ggpubr)
library(gridExtra)

tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")



get_only_legend <- function(plot) {
  plot_table <- ggplot_gtable(ggplot_build(plot))
  legend_plot <- which(sapply(plot_table$grobs, function(x) x$name) == "guide-box")
  legend <- plot_table$grobs[[legend_plot]]
  return(legend)
}

generate_legend <- function(data, pos) {
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
  filter_data$Tools <- factor(filter_data$Tools, levels = c("PanTax", "PanTax(fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))
  
  legend_plot <- ggplot(filter_data, aes(x = Tools, y = bc_dist, fill = Tools)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = sprintf("%.3f", bc_dist)), vjust = -0.5, color = "black", size = 3) +  
    scale_fill_manual(values = tool_colors) +  
    labs(x = "Tools", y = "BC distance") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold"),  
      axis.text.y = element_text(color = "black", face = "bold"),
      legend.position = pos,
      legend.text = element_text(face = "bold"),
      legend.title = element_text(face = "bold")
    ) +
    scale_y_continuous(limits = c(0, 1))
  legend <- get_only_legend(legend_plot) 
  return(legend)
}



generate_plot_base <- function(file_path, dataset_label, output_file_path) {
  
  
  data <- do.call(rbind, lapply(file_path, read.csv, sep="\t"))
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
    
    filter_data <- data[, c(1, 3, 4, 5, 6)]
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
    
    filter_data <- data[, c(1, 2, 3, 4, 12)]    
  }
  
  if (length(grep("zymo1", output_file_path)) > 0) {
    filter_data <- filter_data %>%
      mutate(sample_id = recode(sample_id,
                                "ngs" = "NGS", "clr" = "PacBio CLR", "ontR941" = "ONT R941", "ontR104" = "ONT R104",
                                "hifi" = "Pacbio HiFi", "ontR9" = "ONT R941", "ontR10" = "ONT R10"))     
  } else {
    filter_data <- filter_data %>%
      mutate(sample_id = recode(sample_id,
                                "ngs" = "NGS", "clr" = "PacBio CLR", "ontR941" = "ONT R941", "ontR104" = "ONT R104",
                                "hifi" = "Pacbio HiFi", "ontR9" = "ONT R941", "ontR10" = "ONT R104"))    
  }

  filter_data <- filter_data %>%
    mutate(dataset = recode(dataset,
                            "spiked_in_eight_species666_large_pangenome" = "Spiked-in",
                            "3strains" = "3 strains", "5strains" = "5 strains", "10strains" = "10 strains",
                            "simlow" = "sim-low", "simhigh" = "sim-high",
                            "simhigh-gtdb" = "sim-high-gtdb", 
                            "zymo1" = "Zymo1"))
  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(x == "-")), ]
  
  data_long <- pivot_longer(filter_data, cols = c(precision, recall), names_to = "Metrics", values_to = "value")
  data_long$value <- as.numeric(data_long$value)
  
  data_long$value <- ifelse(data_long$Metrics == "precision", data_long$value, -data_long$value)
  
  data_long$Tools <- factor(data_long$Tools, levels = c("PanTax", "PanTax(fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))
  data_long$sample_id <- factor(data_long$sample_id, levels = c("NGS", "Pacbio HiFi", "PacBio CLR", "ONT R941", "ONT R104", "ONT R10"))
  data_long$dataset <- factor(data_long$dataset, levels = dataset_label)

  
  if (length(grep("single_species", output_file_path)) > 0){
    geom_text_size = 2.8
  } else if (length(grep("zymo1", output_file_path)) > 0) {
    geom_text_size = 2.5
  } else {
    geom_text_size = 2.2
  }  
  
  if (length(grep("single_species", output_file_path)) > 0) {
    p <- ggplot(data_long, aes(x = Tools, y = value, fill = Tools, pattern = Metrics)) +
      geom_bar_pattern(stat = "identity", position = "stack", pattern_density = 0.001, pattern_angle = 45, width = 0.95, pattern_alpha=0.5) +  # 调整position参数为stack
      # coord_flip() + 
      facet_grid(sample_id ~ dataset, scales = "free_x") +
      scale_pattern_manual(values = c(precision = NA, recall = "stripe")) +
      # scale_pattern_color_manual(values = c(precision = NA, recall = "lightgray"),guide = "none") +
      scale_fill_manual(values = tool_colors) +  
      labs(x = "Tools", y = "Score", fill = "Tools") +
      # theme_minimal() +
      scale_y_continuous(labels = abs) +    
      theme(
        axis.text.x = element_text(color = "black", face = "bold", angle = 45, hjust = 1),  
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        strip.text = element_text(size = 12, face = "bold", color = "black"),
        legend.position = "none",
        panel.spacing = unit(0.5, "cm"),
        axis.ticks.y = element_line(color = "black"),
        
      ) +
      geom_hline(yintercept = 0, linewidth = 0.5, color = "white") + 
      guides(pattern = "none") +
      geom_text(aes(label = sprintf("%.3f", abs(value))), position = position_stack(vjust = 1.1),
                data = subset(data_long, value > 0),
                color = "black", fontface = "bold", size = geom_text_size) +
      
      # 下方条形（负值）：数值放在条形底部
      geom_text(aes(label = sprintf("%.3f", abs(value))), position = position_stack(vjust = -0.1),
                data = subset(data_long, value < 0),
                color = "black", fontface = "bold", size = geom_text_size)
  } else if (length(grep("zymo1", output_file_path)) > 0) {
    p <- ggplot(data_long, aes(x = Tools, y = value, fill = Tools, pattern = Metrics)) +
      geom_bar_pattern(stat = "identity", position = "stack", pattern_density = 0.001, pattern_angle = 45, width = 0.95, pattern_alpha=0.5) +  # 调整position参数为stack
      # coord_flip() + 
      facet_grid(dataset ~ sample_id, scales = "free_x") +
      scale_pattern_manual(values = c(precision = NA, recall = "stripe")) +
      # scale_pattern_color_manual(values = c(precision = NA, recall = "lightgray"),guide = "none") +
      scale_fill_manual(values = tool_colors) +  
      labs(x = "Tools", y = "Score", fill = "Tools") +
      # theme_minimal() +
      scale_y_continuous(labels = abs) +    
      theme(
        axis.text.x = element_text(color = "black", face = "bold", angle = 45, hjust = 1),  
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        strip.text = element_text(size = 12, face = "bold", color = "black"),
        legend.position = "none",
        panel.spacing = unit(0.5, "cm"),
        axis.ticks.y = element_line(color = "black"),
        
      ) +
      geom_hline(yintercept = 0, linewidth = 0.5, color = "white") + 
      guides(pattern = "none") +
      geom_text(aes(label = sprintf("%.3f", abs(value))), position = position_stack(vjust = 1.1),
                data = subset(data_long, value > 0),
                color = "black", fontface = "bold", size = geom_text_size) +
      
      # 下方条形（负值）：数值放在条形底部
      geom_text(aes(label = sprintf("%.3f", abs(value))), position = position_stack(vjust = -0.1),
                data = subset(data_long, value < 0),
                color = "black", fontface = "bold", size = geom_text_size)
  } else {
    p <- ggplot(data_long, aes(x = Tools, y = value, fill = Tools, pattern = Metrics)) +
      geom_bar_pattern(stat = "identity", position = "stack", pattern_density = 0.001, pattern_angle = 45, width = 0.95, pattern_alpha=0.5) +  # 调整position参数为stack
      # coord_flip() + 
      facet_grid(dataset ~ sample_id, scales = "free_x") +
      scale_pattern_manual(values = c(precision = NA, recall = "stripe")) +
      # scale_pattern_color_manual(values = c(precision = NA, recall = "lightgray"),guide = "none") +
      scale_fill_manual(values = tool_colors) +  
      labs(x = "Tools", y = "Score", fill = "Tools") +
      # theme_minimal() +
      scale_y_continuous(labels = abs) +    
      theme(
        axis.text.x = element_text(color = "black", face = "bold", angle = 45, hjust = 1),  
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.title = element_text(size = 16, face = "bold"),
        strip.text = element_text(size = 14, face = "bold", color = "black"),
        legend.position = "none",
        panel.spacing = unit(0.5, "cm"),
        axis.ticks.y = element_line(color = "black"),
        
      ) +
      geom_hline(yintercept = 0, linewidth = 0.5, color = "white") + 
      guides(pattern = "none") +
      geom_text(aes(label = sprintf("%.3f", abs(value))), position = position_stack(vjust = 1.1),
                data = subset(data_long, value > 0),
                color = "black", fontface = "bold", size = geom_text_size) +
      
      # 下方条形（负值）：数值放在条形底部
      geom_text(aes(label = sprintf("%.3f", abs(value))), position = position_stack(vjust = -0.1),
                data = subset(data_long, value < 0),
                color = "black", fontface = "bold", size = geom_text_size)
  }

  
  tools <- unlist(lapply(file_path, function(file) {
    # Read the first column from the file
    data <- read.csv(file, sep = "\t")
    filter_data <- data[!apply(data, 1, function(x) any(x == "-")), ]
    # Extract the first column
    return(filter_data[, 1])
  }))
  unique_tools <- unique(tools)
  data <- read.csv("report/example_all_tools.tsv", sep = "\t")
  
  # Filter rows where the tool in the first column is in unique_tools
  filtered_data <- subset(data, data[, 1] %in% unique_tools)
  
  
  if (length(grep("base", output_file_path)) > 0){
    legend <- generate_legend(filtered_data, "bottom")
    p_with_legend <- grid.arrange(p, legend, nrow = 2, heights = c(20, 2))
    ggsave(paste0(output_file_path, "_base_facet.pdf"), plot = p_with_legend, dpi = 300, width = 12, height = 8)
  } else if (length(grep("simhigh_gtdb", output_file_path)) > 0 | length(grep("spiked_in", output_file_path)) > 0) {
    legend <- generate_legend(filtered_data, "bottom")
    p_with_legend <- grid.arrange(p, legend, nrow = 2, heights = c(12, 2))
    ggsave(paste0(output_file_path, "_base_facet.pdf"), plot = p_with_legend, dpi = 300, width = 10, height = 4.5)
  } else if (length(grep("single_species", output_file_path)) > 0) {
    legend <- generate_legend(filtered_data, "left")
    p_with_legend <- grid.arrange(p, legend, ncol = 2, widths = c(8, 2))
    ggsave(paste0(output_file_path, "_base_facet.pdf"), plot = p_with_legend, dpi = 300, width = 7, height = 3.5)
  } else if (length(grep("zymo1", output_file_path)) > 0) {
    legend <- generate_legend(filtered_data, "left")
    p_with_legend <- grid.arrange(p, legend, ncol = 2, widths = c(10, 2))
    ggsave(paste0(output_file_path, "_base_facet.pdf"), plot = p_with_legend, dpi = 300, width = 10, height = 4.5)
  }
  
}


# file_paths_gtdb <- c("report/simlow-gtdb/ngs.tsv", "report/simhigh-gtdb/ngs.tsv", "report/simlow-gtdb/hifi.tsv", 
#                "report/simhigh-gtdb/hifi.tsv", "report/simlow-gtdb/clr.tsv", "report/simhigh-gtdb/clr.tsv",
#                "report/simlow-gtdb/ontR9.tsv", "report/simhigh-gtdb/ontR9.tsv", "report/simlow-gtdb/ontR10.tsv",
#                "report/simhigh-gtdb/ontR10.tsv")
# dataset_label_gtdb <- c("simlow-gtdb", "simhigh-gtdb")
# output_file_path <- "report/plots/gtdb"
# generate_plot_base(file_paths_gtdb, dataset_label_gtdb, output_file_path)

file_paths_gtdb <- c("report/simhigh-gtdb/ngs.tsv",
               "report/simhigh-gtdb/hifi.tsv", "report/simhigh-gtdb/clr.tsv",
               "report/simhigh-gtdb/ontR9.tsv", "report/simhigh-gtdb/ontR10.tsv")
dataset_label_gtdb <- c("sim-high-gtdb")
output_file_path <- "report/plots/simhigh_gtdb"
generate_plot_base(file_paths_gtdb, dataset_label_gtdb, output_file_path)

file_paths_base <- c("report/simlow/ngs.tsv", "report/simhigh/ngs.tsv", "report/simlow/hifi.tsv", 
                     "report/simhigh/hifi.tsv", "report/simlow/clr.tsv", "report/simhigh/clr.tsv",
                     "report/simlow/ontR9.tsv", "report/simhigh/ontR9.tsv", "report/simlow/ontR10.tsv",
                     "report/simhigh/ontR10.tsv")
dataset_label_base <- c("sim-low", "sim-high")
output_file_path <- "report/plots/base"
generate_plot_base(file_paths_base, dataset_label_base, output_file_path) 

file_paths_spiked_in_eight <- c("report/spiked_in_eight_species666_large_pangenome/ngs.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/hifi.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/clr.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/ontR9.tsv", 
                                "report/spiked_in_eight_species666_large_pangenome/ontR10.tsv")
dataset_label_spiked_in <- c("Spiked-in")
output_file_path <- "report/plots/spiked_in"
generate_plot_base(file_paths_spiked_in_eight, dataset_label_spiked_in, output_file_path)

file_paths_zymo1 <- c("report/zymo1/ngs.tsv", "report/zymo1/ontR9.tsv", "report/zymo1/ontR10.tsv")
dataset_label_zymo1 <- c("Zymo1")
output_file_path <- "report/plots/zymo1"
generate_plot_base(file_paths_zymo1, dataset_label_zymo1, output_file_path)


file_paths_single_species_multi_strains <- c("report/3strains/3strains.tsv", 
                                             "report/5strains/5strains.tsv", 
                                             "report/10strains/10strains.tsv")
dataset_label_single_species_multi_strains <- c("3 strains", "5 strains", "10 strains")
output_file_path <- "report/plots/single_species_multi_strains"
generate_plot_base(file_paths_single_species_multi_strains, dataset_label_single_species_multi_strains, output_file_path)
