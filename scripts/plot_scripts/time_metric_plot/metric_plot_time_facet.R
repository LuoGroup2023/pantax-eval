library(ggplot2)
library(tidyr)
library(ggpattern)
library(ggpubr)
library(gridExtra)
library(ggthemes)
library(cowplot)
library(patchwork)
library(ggbreak)

setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts")

tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")



get_only_legend <- function(plot) {
  plot_table <- ggplot_gtable(ggplot_build(plot))
  legend_plot <- which(sapply(plot_table$grobs, function(x) x$name) == "guide-box")
  legend <- plot_table$grobs[[legend_plot]]
  return(legend)
}

generate_legend <- function(file_path, pos) {
  
  # data <- read.csv(file_path, sep = "\t")
  data <- do.call(rbind, lapply(file_path, read.csv, sep="\t"))
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
  data <- subset(data, data[, 1] %in% unique_tools)
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
  # 
  # legend <- generate_legend(filtered_data, "bottom")
 
  
  
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



generate_plot_time <- function(file_path, dataset_label, output_file_path) {
  
  
  data <- do.call(rbind, lapply(file_path, read.csv, sep="\t"))
  colnames(data)[1] <- "Tools"
  colnames(data)[4] <- "CPU time"
  colnames(data)[5] <- "Wall time"
  colnames(data)[6] <- "Memory"
  
  
  
  filter_data <- data[, c(1, 2, 3, 4, 6)]
  if (length(grep("real", output_file_path)) > 0) {
    filter_data <- filter_data %>%
      mutate(sample_id = recode(sample_id,
                                "ngs" = "NGS", "clr" = "PacBio CLR", "ontR941" = "ONT R941", "ontR104" = "ONT R104",
                                "hifi" = "Pacbio HiFi", "ontR9" = "ONT R941", "ontR10" = "ONT R10", "ont" = "ONT")) 
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
                            "zymo1" = "Zymo1",
                            # "PD" = "PD human gut", "rmhost" = "Healthy human gut", "omnivore_gut" = "Omnivorous human gut",
                            "PD" = "real dataset", "rmhost" = "real dataset", "omnivore_gut" = "real dataset"
                            ))
  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(x == "-")), ]
  
  data_long <- pivot_longer(filter_data, cols = c("CPU time", "Memory"), names_to = "Metrics", values_to = "value")
  data_long$value <- as.numeric(data_long$value)
  
  data_long$value <- ifelse(data_long$Metrics == "CPU time", data_long$value, -data_long$value)
  
  data_long$Tools <- factor(data_long$Tools, levels = c("PanTax", "PanTax(fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))
  data_long$sample_id <- factor(data_long$sample_id, levels = c("NGS", "Pacbio HiFi", "PacBio CLR", "ONT R941", "ONT R104", "ONT R10", "ONT"))
  data_long$dataset <- factor(data_long$dataset, levels = dataset_label)
  
  if (length(grep("real", output_file_path)) > 0) {
    geom_text_size = 3.5
  } else {
    geom_text_size = 2.4
  }
   

  p <- ggplot(data_long, aes(x = Tools, y = value, fill = Tools, pattern = Metrics)) +
    geom_bar_pattern(stat = "identity", position = "stack", pattern_density = 0.001, pattern_angle = 45, width = 0.95, pattern_alpha=0.5) +  # 调整position参数为stack
    # coord_flip() + 
    facet_grid(dataset ~ sample_id, scales = "free") +
    scale_pattern_manual(values = c("CPU time" = NA, "Memory" = "stripe")) +
    # scale_pattern_color_manual(values = c(precision = NA, recall = "lightgray"),guide = "none") +
    scale_fill_manual(values = tool_colors) +  
    labs(x = "Tools", y = "Score", fill = "Tools") +
    theme_igray() + 
    scale_x_discrete(expand = expansion(mult = c(0.12, 0.05))) +
    theme(
      axis.text.x = element_text(color = "black", face = "bold", angle = 45, hjust = 1),  
      axis.text.y = element_text(color = "black", face = "bold"),
      axis.title = element_text(size = 16, face = "bold"),
      strip.text = element_text(size = 14, face = "bold", color = "black"),
      legend.position = "none",
      plot.background = element_rect(fill = "white"),
      panel.spacing = unit(1, "cm"),
      axis.ticks.y = element_line(color = "black"),
      axis.ticks.length = unit(-0.1, "cm"),
      axis.line.y = element_line(color = "black", linewidth = 0.8),
      panel.grid.major = element_blank(),  
      # panel.grid.minor = element_blank() 
    ) +
    geom_hline(yintercept = 0, linewidth = 0.5, color = "white") + 
    guides(pattern = "none") +
    geom_text(aes(label = sprintf("%.1f", abs(value))), position = position_stack(vjust = 1.1),
              data = subset(data_long, value > 0),
              color = "black", fontface = "bold", size = geom_text_size) +
    
    # 下方条形（负值）：数值放在条形底部
    geom_text(aes(label = sprintf("%.1f", abs(value))), position = position_stack(vjust = -0.1),
              data = subset(data_long, value < 0),
              color = "black", fontface = "bold", size = geom_text_size)

  if (length(grep("gtdb", output_file_path)) > 0) {
    p <- p + scale_y_continuous(labels = abs, limits = c(-2000, 5500))
  } else {
    p <- p + scale_y_continuous(labels = abs)
  }
  

  # p_with_legend <- grid.arrange(p, legend, nrow = 2, heights = c(20, 2))
  if (length(grep("real", output_file_path)) > 0) {
    ggsave(paste0(output_file_path, "_time_facet.pdf"), plot = p, dpi = 300, width = 10, height = 4)
  } else{
    ggsave(paste0(output_file_path, "_time_facet.pdf"), plot = p, dpi = 300, width = 10, height = 6)
  }
   
  return(p)
  
}

file_paths_simlow <- c("time_report/simlow/simlow_ngs.txt", "time_report/simlow/simlow_tgs.txt")
dst_labels <- c("sim-low")
output_file_path <- "time_report/plots/simlow"
p1 <- generate_plot_time(file_paths_simlow, dst_labels, output_file_path)
 
p1_split <- p1 + scale_y_break(c(200,500),scales = 1,expand=expansion(add = c(0, 0)),space = 0.3, ticklabels=c(500, 900)) + 
  scale_y_continuous(breaks=c(-300, -600), labels = abs) +
  scale_y_break(c(-300, -100),scales = 3.5, expand=expansion(add = c(0, 0)),space = 0.3, ticklabels=seq(-100,200,by=100)) +
  theme(axis.title.y.right = element_blank(),
        axis.text.y.right = element_blank(),
        axis.ticks.y.right = element_blank()) +
  expand_limits(y= c(-600, 900))
ggsave(paste0(output_file_path, "_time_facet.pdf"), plot = print(p1_split), dpi = 300, width = 12, height = 4.5)

file_paths_simhigh_gtdb <- c("time_report/simhigh-gtdb/simhigh-gtdb_all.txt")
dst_labels <- c("sim-high-gtdb")
output_file_path <- "time_report/plots/simhigh-gtdb"
p2 <- generate_plot_time(file_paths_simhigh_gtdb, dst_labels, output_file_path)
# p2_split <- p2 + scale_y_break(c(200,400), expand=expansion(add = c(0, 0)),scales = 0.5,space = 0.3, ticklabels=c(400,2500,5000)) + 
#   scale_y_continuous(breaks=c(-1000,-500, 0, 200), labels = abs) +
#   theme(axis.title.y.right = element_blank(),
#         axis.text.y.right = element_blank(),
#         axis.ticks.y.right = element_blank())
p2_split <-p2 + scale_y_break(c(600,2500), expand=expansion(add = c(0, 0)),scales = 0.2,space = 0.3, ticklabels=c(2500,5500)) + 
  scale_y_continuous(breaks=c(-1500,-1000,-500, 0, 200,400,600), labels = abs) +
  theme(axis.title.y.right = element_blank(),
        axis.text.y.right = element_blank(),
        axis.ticks.y.right = element_blank()) +
  expand_limits(y= c(-1500, 5500))
ggsave(paste0(output_file_path, "_time_facet.pdf"), plot = print(p2_split), dpi = 300, width = 12, height = 4.5)

file_paths_real <- c("time_report/PD/PD_ngs.txt", "time_report/rmhost/rmhost_tgs.txt", "time_report/omnivore_gut/omnivore_gut_tgs.txt")
dst_labels <- c("real dataset")
output_file_path <- "time_report/plots/real"
p3 <- generate_plot_time(file_paths_real, dst_labels, output_file_path)
p3_split <- p3 + scale_y_break(c(200,500),scales = 1.2,expand=expansion(add = c(0, 0)),space = 0.3, ticklabels=c(500, 1200)) + 
  scale_y_continuous(breaks=c(-300, -600), labels = abs) +
  scale_y_break(c(-300, -100),scales = 3.5, expand=expansion(add = c(0, 0)),space = 0.3, ticklabels=seq(-100,200,by=100)) +
  theme(axis.title.y.right = element_blank(),
        axis.text.y.right = element_blank(),
        axis.ticks.y.right = element_blank()) +
  expand_limits(y= c(-600, 1200))
ggsave(paste0(output_file_path, "_time_facet.pdf"), plot = print(p3_split), dpi = 300, width = 12, height = 6)

all_file_paths <- c(file_paths_simlow, file_paths_simhigh_gtdb, file_paths_real)
legend <- generate_legend(all_file_paths, "bottom")


p <- p1/p2/p3/legend + plot_layout(nrow=4,heights=c(3.5,3.5,5,0.5))
output_file_path <- "time_report/plots/all"
ggsave(paste0(output_file_path, "_time_facet.pdf"), plot = p, dpi = 300, width = 12, height = 12.5)


p_split <- print(p1_split)/print(p2_split)/print(p3_split)/legend + plot_layout(nrow=4,heights=c(4.5,5,6,1))
output_file_path <- "time_report/plots/all2"
ggsave(paste0(output_file_path, "_time_facet.pdf"), plot = p_split, dpi = 300, width = 12, height = 15)
# save_plot(paste0(output_file_path, "_time_facet.pdf"), p,
#           # ncol = 1, # we're saving a grid plot of 2 columns
#           # nrow = 3, # and 2 rows
#           # each individual subplot should have an aspect ratio of 1.3
#           base_asp = 1,
#           base_width = 10,  
#           base_height = 13,  )
