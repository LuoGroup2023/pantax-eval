library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

tools <- c("PanTax", "StrainScan", "StrainGE", "StrainEst")
samples <- c("ery_time1_rep3", "ery_time2_rep3", "ery_time3_rep3", "noATB_time1_rep3", "noATB_time2_rep3", "noATB_time3_rep3")
wd <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_all"
plot_outdir <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots"
setwd(wd)
data <- list()

for (tool in tools) {
  data[[tool]] <- list(
    'Ery' = list(),
    'no_ATB' = list()
  )
}
# pantax
for (i in seq_along(samples)) {
  target_genomes <- c("GCF_000276145", "GCF_000276305")
  sample <- samples[i]
  strain_abundance_file <- file.path(wd, "pantax2", sample, "second_pantax/pantax2_strain_abundance.txt")
  print(strain_abundance_file)
  if (file.exists(strain_abundance_file)) {
    strain_abundance <- read.table(strain_abundance_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
    strain_abundance$genome_ID <- gsub("\\..*", "", strain_abundance$genome_ID)
    # strain_abundance$genome_ID <- sub("(^GCF_\\d+\\.\\d+).*", "\\1", strain_abundance$genome_ID)
    genome_abundance <- setNames(strain_abundance$predicted_abundance, strain_abundance$genome_ID)
    
    target_data <- strain_abundance[strain_abundance$genome_ID %in% target_genomes, ]
    others_data <- strain_abundance[!strain_abundance$genome_ID %in% target_genomes, ]
    
    proportions <- as.list(setNames(target_data$predicted_abundance, target_data$genome_ID))
    
    if (nrow(others_data) > 0) {
      proportions$Others <- sum(others_data$predicted_abundance)
    }    

    if (i <= 3) {  
      data[['PanTax']][['Ery']][[paste0("T", i)]] <- proportions
    } else {  
      data[['PanTax']][['no_ATB']][[paste0("T", i - 3)]] <- proportions
    }
  } else {
    warning(paste("File not found:", strain_abundance_file))
  }
}

# strainscan
for (i in seq_along(samples)) {
  target_genomes <- c("GCF_000276145", "GCF_000276305")
  sample <- samples[i]
  strain_abundance_file <- file.path(wd, tolower(tools[2]), sample, "strainscan_result/final_report.txt")
  
  if (file.exists(strain_abundance_file)) {
    strain_abundance <- read.table(strain_abundance_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
    if (ncol(strain_abundance) > 7) {
      colnames(strain_abundance)[colnames(strain_abundance) == "Predicted_Depth..Ab.cls_depth."] <- "Predicted_Depth"
    }    
    sum_depth <- sum(strain_abundance$Predicted_Depth)
    strain_abundance$relative_abund <- strain_abundance$Predicted_Depth / sum_depth
    genome_abundance <- setNames(strain_abundance$relative_abund, strain_abundance$Strain_Name)
    
    target_data <- strain_abundance[strain_abundance$Strain_Name %in% target_genomes, ]
    others_data <- strain_abundance[!strain_abundance$Strain_Name %in% target_genomes, ]
    
    proportions <- as.list(setNames(target_data$relative_abund, target_data$Strain_Name))
    
    if (nrow(others_data) > 0) {
      proportions$Others <- sum(others_data$relative_abund)
    }    
    
    if (i <= 3) {  
      data[['StrainScan']][['Ery']][[paste0("T", i)]] <- proportions
    } else {  
      data[['StrainScan']][['no_ATB']][[paste0("T", i - 3)]] <- proportions
    }
  } else {
    warning(paste("File not found:", strain_abundance_file))
  }
}

# strainGE
for (i in seq_along(samples)) {
  target_genomes <- c("GCF_012029805", "GCF_000276305")
  sample <- samples[i]
  strain_abundance_file <- file.path(wd, "straingst", sample, "result.strains.tsv")
  
  if (file.exists(strain_abundance_file)) {
    strain_abundance <- read.table(strain_abundance_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
    strain_abundance$strain = gsub("\\..*", "", strain_abundance$strain)
    strain_abundance$rapct = strain_abundance$rapct / 100
    genome_abundance <- setNames(strain_abundance$rapct, strain_abundance$strain)
    
    target_data <- strain_abundance[strain_abundance$strain %in% target_genomes, ]
    others_data <- strain_abundance[!strain_abundance$strain %in% target_genomes, ]
    
    proportions <- as.list(setNames(target_data$rapct, target_data$strain))
    
    if (sum(strain_abundance$rapct) != 100) {
      proportions$Others <- 1 - sum(strain_abundance$rapct)
    }    
    
    if (i <= 3) {  
      data[['StrainGE']][['Ery']][[paste0("T", i)]] <- proportions
    } else {  
      data[['StrainGE']][['no_ATB']][[paste0("T", i - 3)]] <- proportions
    }
  } else {
    warning(paste("File not found:", strain_abundance_file))
  }
}

# strainest
for (i in seq_along(samples)) {
  target_genomes <- c("GCF_000276145", "GCF_016809135")
  sample <- samples[i]
  strain_abundance_file <- file.path(wd, tolower(tools[4]), sample, "outputdir/abund.txt")
  
  if (file.exists(strain_abundance_file)) {
    strain_abundance <- read.table(strain_abundance_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
    strain_abundance <- strain_abundance %>% filter(reads.sorted.bam != 0)
    colnames(strain_abundance)[colnames(strain_abundance) == "reads.sorted.bam"] <- "abund"
    strain_abundance$OTU = gsub("\\..*", "", strain_abundance$OTU)
    sum_abund = sum(strain_abundance$abund)
    strain_abundance$abund <- strain_abundance$abund / sum_abund
    genome_abundance <- setNames(strain_abundance$abund, strain_abundance$OTU)
    
    target_data <- strain_abundance[strain_abundance$OTU %in% target_genomes, ]
    others_data <- strain_abundance[!strain_abundance$OTU %in% target_genomes, ]
    
    proportions <- as.list(setNames(target_data$abund, target_data$OTU))
    
    if (nrow(others_data) > 0) {
      proportions$Others <- sum(others_data$abund)
    }    
    
    if (i <= 3) {  
      data[['StrainEst']][['Ery']][[paste0("T", i)]] <- proportions
    } else {  
      data[['StrainEst']][['no_ATB']][[paste0("T", i - 3)]] <- proportions
    }
  } else {
    warning(paste("File not found:", strain_abundance_file))
  }
}




df <- data.frame()
for(method in names(data)) {
  for(condition in names(data[[method]])) {
    for(time in names(data[[method]][[condition]])) {
      for(strain in names(data[[method]][[condition]][[time]])) {
        df <- rbind(df, data.frame(
          Method = method,
          Condition = condition,
          Time = time,
          Strain = strain,
          Abundance = data[[method]][[condition]][[time]][[strain]]
        ))
      }
    }
  }
}

colors <- c(
  'GCF_000276145' = '#E04832',
  'GCF_000276305' = '#FBBA73',
  'GCF_012029805' = '#CC99FF',
  'GCF_016809135' = '#B8DEEC', 
  'Others' = '#BFBEBE'
)

create_combined_plot <- function(data) {
  data %>%
    ggplot(aes(x = Time, y = Abundance, fill = Strain)) +
    geom_bar(stat = "identity", position = "stack") +
    geom_text(aes(label = sprintf("%d%%", round(Abundance * 100))),
              position = position_stack(vjust = 0.5),
              size = 3, color = "black", fontface = "bold") + 
    facet_grid(Condition ~ Method) + 
    scale_fill_manual(values = colors) +
    scale_y_continuous(limits = c(0, 1)) +
    # theme_bw() +
    theme(
      # 修改字体颜色和样式
      text = element_text(color = "black", face = "bold"), 
      axis.title = element_text(size = 14),               
      axis.text = element_text(size = 11),                
      strip.text = element_text(size = 13),            
      legend.title = element_text(size = 11),          
      legend.text = element_text(size = 10),            
      legend.position = "right", 
      legend.background = element_rect(fill = "white", color = "white", linewidth = 1),
      # strip.background = element_rect(fill = "gray80", color = "black"),  #
      axis.text.x = element_text(angle = 0),               
      #panel.grid.major.x = element_blank(),              
      #panel.grid.minor = element_blank(),            
      # panel.background = element_rect(fill = "white", color = "black"), 
      # panel.border = element_rect(color = "black")       
    ) +
    labs(
      x = "Time Point",
      y = "Abundance",
      fill = "Strain",
    )
}


combined_plot <- create_combined_plot(df)
combined_plot 



# ggsave("abundance_plot_R.png", combined_plot, width = 15, height = 8, dpi = 300)

ggsave(file.path(plot_outdir, "species1282_real.pdf"), combined_plot, width = 10, height = 6, dpi = 300)
