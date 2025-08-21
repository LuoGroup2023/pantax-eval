library(dplyr)
library(ggplot2)
library(tidyr)
library(ggpattern)
library(ggpubr)
library(gridExtra)
library(ggthemes)
library(cowplot)

setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts")

plot_mode <- 2
generate_plot_recall <- function(file_path, dataset_label, output_file_path, add_legend) {
  tool_colors = c("PanTax"="#f8766d", "PanTax (fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                  "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3","Sylph"="#8fc3e2")

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

    filter_data <- data[, c(1, 3, 4, 6)]
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

    filter_data <- data[, c(1, 2, 4, 12)]    
  }

  if (length(grep("zymo1", output_file_path)) > 0) {
    filter_data <- filter_data %>%
      mutate(sample_id = recode(sample_id,
                                "ngs" = "NGS", "clr" = "PacBio CLR",
                                "hifi" = "Pacbio HiFi", "ontR9" = "ONT R941", "ontR10" = "ONT R10"))     
  } else {
    filter_data <- filter_data %>%
      mutate(sample_id = recode(sample_id,
                                "ngs" = "NGS", "clr" = "PacBio CLR",
                                "hifi" = "Pacbio HiFi", "ontR9" = "ONT R941", "ontR10" = "ONT R104"))    
  }

  filter_data <- filter_data %>%
    mutate(dataset = recode(dataset,
                            "spiked_in_eight_species666_large_pangenome" = "Spiked-in",
                            "3strains" = "3 strains", "5strains" = "5 strains", "10strains" = "10 strains",
                            "simlow" = "sim-low", "simhigh" = "sim-high",
                            "simhigh-gtdb" = "sim-high-gtdb",
                            "zymo1" = "Zymo1"))

  filter_data$Tools <- factor(filter_data$Tools, levels = c("PanTax", "PanTax (fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps","Sylph"))
  filter_data$sample_id <- factor(filter_data$sample_id, levels = c("NGS", "Pacbio HiFi", "PacBio CLR", "ONT R941", "ONT R104", "ONT R10"))
  filter_data$dataset <- factor(filter_data$dataset, levels = dataset_label) 

  # ȥ?? centrifuge ?? centrifuger
  filter_data <- filter_data[!filter_data$Tools %in% c("Centrifuge", "MetaMaps"),]

  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(x == "-")), ]
  filter_data$recall <- as.numeric(filter_data$recall)

  if (length(grep("simhigh_gtdb", output_file_path)) > 0 | length(grep("spiked_in", output_file_path)) > 0) {
    geom_text_size = 2.5
  } else if (length(grep("base", output_file_path)) > 0) {
    geom_text_size = 2.1
  } else if (length(grep("single_species", output_file_path)) > 0) {
    geom_text_size = 2.3
  } else if (length(grep("zymo1", output_file_path)) > 0) {
    geom_text_size = 2.3
  }

  if (length(grep("zymo1", output_file_path)) > 0) {
    p <- ggplot(filter_data, aes(x = Tools, y = recall, fill = Tools)) +
      theme_igray() +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(label = sprintf("%.3f", recall)), vjust = -0.5, color = "black", fontface = "bold", size = geom_text_size) +
      facet_wrap(~ sample_id, scales = "free_x", nrow = 1) +
      labs(y = "Recall", title = dataset_label) +
      scale_fill_manual(values = tool_colors) + 
      theme(
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold", size=9),
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        axis.line.y = element_line(color = "black", size = 0.5),
        strip.text = element_text(size = 12, face = "bold", color = "black"),
        plot.background = element_rect(fill = "white"),
        legend.background = element_rect(fill = "white"),
        legend.position = "bottom",
        legend.text = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        panel.spacing = unit(0.3, "cm")
      ) +
      scale_y_continuous(limits = c(0, 1))
  } else if (add_legend) {
    p <- ggplot(filter_data, aes(x = Tools, y = recall, fill = Tools)) +
      theme_igray() +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(label = sprintf("%.3f", recall)), vjust = -0.5, color = "black", fontface = "bold", size = geom_text_size) +
      facet_wrap(~ sample_id, scales = "free_x", nrow = 1) +  
      labs(y = "Recall", title = dataset_label) +
      scale_fill_manual(values = tool_colors) + 
      theme(
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold", size=9),
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.title = element_text(size = 16, face = "bold"),
        axis.line.y = element_line(color = "black", size = 0.5),
        strip.text = element_text(size = 14, face = "bold", color = "black"),
        plot.background = element_rect(fill = "white"),
        legend.background = element_rect(fill = "white"),
        legend.position = "bottom",
        legend.text = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        # legend.position = "none",
        panel.spacing = unit(0.3, "cm")
      ) +
      scale_y_continuous(limits = c(0, 1))
  } else if (!add_legend) {
    p <- ggplot(filter_data, aes(x = Tools, y = recall, fill = Tools)) +
      theme_igray() +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(label = sprintf("%.3f", recall)), vjust = -0.5, color = "black", fontface = "bold", size = geom_text_size) +
      facet_wrap(~ sample_id, scales = "free_x", nrow = 1) +  
      labs(y = "Recall", title = dataset_label) +
      scale_fill_manual(values = tool_colors) + 
      theme(
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold", size=9),
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.title = element_text(size = 16, face = "bold"),
        axis.line.y = element_line(color = "black", size = 0.5),
        strip.text = element_text(size = 14, face = "bold", color = "black"),
        plot.background = element_rect(fill = "white"),
        # legend.background = element_rect(fill = "white"),
        # legend.position = "bottom",
        # legend.text = element_text(face = "bold"),
        # legend.title = element_text(face = "bold"),
        legend.position = "none",
        panel.spacing = unit(0.3, "cm")
      ) +
      scale_y_continuous(limits = c(0, 1))    
  }

  # if (length(grep("simhigh_gtdb", output_file_path)) > 0 | length(grep("spiked_in", output_file_path)) > 0) {
  #   ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 11, height = 4.5, dpi = 300)
  # } else if (length(grep("base", output_file_path)) > 0) {
  #   ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 11, height = 4, dpi = 300)
  # } else if (length(grep("single_species", output_file_path)) > 0) {
  #   ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 7, height = 3, dpi = 300)
  # } else if (length(grep("zymo1", output_file_path)) > 0) {
  #   ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 11, height = 4, dpi = 300)
  # }
  return(p)
}

file_paths_base <- c("report/simlow/ngs.tsv", "report/simlow/hifi.tsv", 
                     "report/simlow/clr.tsv",
                     "report/simlow/ontR9.tsv","report/simlow/ontR10.tsv"
                     )
dataset_label_base <- c("sim-low")
output_file_path <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots/base_simlow_recall"
p1 <- generate_plot_recall(file_paths_base, dataset_label_base, output_file_path, add_legend = FALSE)

file_paths_base <- c("report/simhigh/ngs.tsv", 
                     "report/simhigh/hifi.tsv","report/simhigh/clr.tsv",
                     "report/simhigh/ontR9.tsv",
                     "report/simhigh/ontR10.tsv")
dataset_label_base <- c("sim-high")
output_file_path <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots/base_simhigh_recall"
p2 <- generate_plot_recall(file_paths_base, dataset_label_base, output_file_path, add_legend = TRUE)

# file_paths_zymo1 <- c("report/zymo1/ngs.tsv", "report/zymo1/ontR9.tsv", "report/zymo1/ontR10.tsv")
# dataset_label_zymo1 <- c("Zymo1")
# output_file_path <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots/zymo1_recall"
# p3 <- generate_plot_recall(file_paths_zymo1, dataset_label_zymo1, output_file_path, add_legend = TRUE)

output_file_path <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots/sylph_recall_all"
combined_plot <- (p1/p2) + plot_annotation(tag_levels = "A")
ggsave(paste0(output_file_path, ".pdf"), plot = combined_plot, width = 11, height = 8.5, dpi = 300)
ggsave(paste0(output_file_path, ".png"), plot = combined_plot, width = 11, height = 8.5, dpi = 300)
