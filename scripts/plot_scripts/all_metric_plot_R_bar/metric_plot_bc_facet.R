

library(ggplot2)
library(tidyr)
library(ggpattern)
library(ggpubr)
library(gridExtra)
library(ggthemes)

setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts")

generate_plot_bc <- function(file_path, dataset_label, output_file_path) {
  tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                  "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                  "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")
  
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
    
    filter_data <- data[, c(1, 3, 4, 13)]
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
    
    filter_data <- data[, c(1, 2, 11, 12)]    
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
  
  filter_data$Tools <- factor(filter_data$Tools, levels = c("PanTax", "PanTax(fast)", "KMCP", "Ganon", "Centrifuger", "Centrifuge", "Kraken2", "Bracken", "MetaMaps", "StrainScan", "StrainGE", "StrainEst"))
  filter_data$sample_id <- factor(filter_data$sample_id, levels = c("NGS", "Pacbio HiFi", "PacBio CLR", "ONT R941", "ONT R104", "ONT R10"))
  filter_data$dataset <- factor(filter_data$dataset, levels = dataset_label) 
  
  filter_data <- filter_data[!apply(filter_data, 1, function(x) any(x == "-")), ]
  filter_data$bc_dist <- as.numeric(filter_data$bc_dist)
  
  if (length(grep("simhigh_gtdb", output_file_path)) > 0 | length(grep("spiked_in", output_file_path)) > 0) {
    geom_text_size = 2.5
  } else if (length(grep("base", output_file_path)) > 0) {
    geom_text_size = 2.1
  } else if (length(grep("single_species", output_file_path)) > 0) {
    geom_text_size = 2.3
  } else if (length(grep("zymo1", output_file_path)) > 0) {
    geom_text_size = 2.3
  }
  
  if (length(grep("single_species", output_file_path)) > 0) {
    p <- ggplot(filter_data, aes(x = Tools, y = bc_dist, fill = Tools)) +
      theme_igray() +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(label = sprintf("%.3f", bc_dist)), vjust = -0.5, color = "black", fontface = "bold", size = geom_text_size) +
      facet_grid(sample_id ~ dataset, scales = "free_x") +  
      labs(y = "BC distance") +
      scale_fill_manual(values = tool_colors) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold", size=9),
            axis.text.y = element_text(color = "black", face = "bold"),
            axis.title = element_text(size = 14, face = "bold"),
            strip.text = element_text(size = 12, face = "bold", color = "black"),
            plot.background = element_rect(fill = "white"),
            legend.background = element_rect(fill = "white"),
            legend.position = "right",
            legend.text = element_text(face = "bold"),
            legend.title = element_text(face = "bold"),
            panel.spacing = unit(0.3, "cm"),) +
      scale_y_continuous(limits = c(0, 1))
  } else if (length(grep("zymo1", output_file_path)) > 0) {
    p <- ggplot(filter_data, aes(x = Tools, y = bc_dist, fill = Tools)) +
      theme_igray() +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(label = sprintf("%.3f", bc_dist)), vjust = -0.5, color = "black", fontface = "bold", size = geom_text_size) +
      facet_grid(dataset ~ sample_id, scales = "free_x") +  
      labs(y = "BC distance") +
      scale_fill_manual(values = tool_colors) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold", size=9),
            axis.text.y = element_text(color = "black", face = "bold"),
            axis.title = element_text(size = 14, face = "bold"),
            strip.text = element_text(size = 12, face = "bold", color = "black"),
            plot.background = element_rect(fill = "white"),
            legend.background = element_rect(fill = "white"),
            legend.position = "right",
            legend.text = element_text(face = "bold"),
            legend.title = element_text(face = "bold"),
            panel.spacing = unit(0.3, "cm"),) +
      scale_y_continuous(limits = c(0, 1))
  } else {
    p <- ggplot(filter_data, aes(x = Tools, y = bc_dist, fill = Tools)) +
      theme_igray() +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(label = sprintf("%.3f", bc_dist)), vjust = -0.5, color = "black", fontface = "bold", size = geom_text_size) +
      facet_grid(dataset ~ sample_id, scales = "free_x") +  
      labs(y = "BC distance") +
      scale_fill_manual(values = tool_colors) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold", size=9),
            axis.text.y = element_text(color = "black", face = "bold"),
            axis.title = element_text(size = 16, face = "bold"),
            strip.text = element_text(size = 14, face = "bold", color = "black"),
            plot.background = element_rect(fill = "white"),
            legend.background = element_rect(fill = "white"),
            legend.position = "bottom",
            legend.text = element_text(face = "bold"),
            legend.title = element_text(face = "bold"),
            panel.spacing = unit(0.3, "cm"),) +
      scale_y_continuous(limits = c(0, 1))
  }

  if (length(grep("simhigh_gtdb", output_file_path)) > 0 | length(grep("spiked_in", output_file_path)) > 0) {
    ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 11, height = 4.5, dpi = 300)
  } else if (length(grep("base", output_file_path)) > 0) {
    ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 11, height = 6, dpi = 300)
  } else if (length(grep("single_species", output_file_path)) > 0) {
    ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 7, height = 3, dpi = 300)
  } else if (length(grep("zymo1", output_file_path)) > 0) {
    ggsave(paste0(output_file_path, "_facet.pdf"), plot = p, width = 10, height = 4, dpi = 300)
  }
}


file_paths_gtdb <- c("report/simhigh-gtdb/ngs.tsv",
                     "report/simhigh-gtdb/hifi.tsv", "report/simhigh-gtdb/clr.tsv",
                     "report/simhigh-gtdb/ontR9.tsv", "report/simhigh-gtdb/ontR10.tsv")
dataset_label_gtdb <- c("sim-high-gtdb")
output_file_path <- "report/plots/simhigh_gtdb_bc"
generate_plot_bc(file_paths_gtdb, dataset_label_gtdb, output_file_path)

file_paths_base <- c("report/simlow/ngs.tsv", "report/simhigh/ngs.tsv", "report/simlow/hifi.tsv", 
                     "report/simhigh/hifi.tsv", "report/simlow/clr.tsv", "report/simhigh/clr.tsv",
                     "report/simlow/ontR9.tsv", "report/simhigh/ontR9.tsv", "report/simlow/ontR10.tsv",
                     "report/simhigh/ontR10.tsv")
dataset_label_base <- c("sim-low", "sim-high")
output_file_path <- "report/plots/base_bc"
generate_plot_bc(file_paths_base, dataset_label_base, output_file_path)

file_paths_spiked_in_eight <- c("report/spiked_in_eight_species666_large_pangenome/ngs.tsv", 
                     "report/spiked_in_eight_species666_large_pangenome/hifi.tsv", 
                     "report/spiked_in_eight_species666_large_pangenome/clr.tsv", 
                     "report/spiked_in_eight_species666_large_pangenome/ontR9.tsv", 
                     "report/spiked_in_eight_species666_large_pangenome/ontR10.tsv")
dataset_label_spiked_in <- c("Spiked-in")
output_file_path <- "report/plots/spiked_in_bc"
generate_plot_bc(file_paths_spiked_in_eight, dataset_label_spiked_in, output_file_path)

file_paths_zymo1 <- c("report/zymo1/ngs.tsv", "report/zymo1/ontR9.tsv", "report/zymo1/ontR10.tsv")
dataset_label_zymo1 <- c("Zymo1")
output_file_path <- "report/plots/zymo1_bc"
generate_plot_bc(file_paths_zymo1, dataset_label_zymo1, output_file_path)

file_paths_single_species_multi_strains <- c("report/3strains/3strains.tsv", 
                                "report/5strains/5strains.tsv", 
                                "report/10strains/10strains.tsv")
dataset_label_single_species_multi_strains <- c("3 strains", "5 strains", "10 strains")
output_file_path <- "report/plots/single_species_multi_strains_bc"
generate_plot_bc(file_paths_single_species_multi_strains, dataset_label_single_species_multi_strains, output_file_path)

