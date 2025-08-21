
library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(tidyr)
library(grid)

output_dir <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts/report/plots"
## Similarity scaling -- the ANI range of datasets
setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_div2/datasets/res")

all_data <- data.frame(i = integer(), ani = numeric())

for (i in c(1, 2, 5, 10, 20, 30, 40, 50)) {
  matrix_file <- list.files(
    as.character(i),
    pattern = "matrix$",   
    full.names = TRUE
  )
  
  if (length(matrix_file) == 0) {
    next
  } else if (length(matrix_file) == 1) {
    cat("Reading:", matrix_file, "\n")
    lines <- readLines(matrix_file)
    lines <- lines[-1]
    
    ani <- unlist(lapply(lines, function(x) {
      fields <- strsplit(x, "\\s+")[[1]] 
      as.numeric(fields[-1])
    }))
    
    all_data <- bind_rows(all_data, data.frame(i = i, ani = ani))
  } else {
    warning("No unique matrix file in ", as.character(i))
  }
}

all_data <- bind_rows(data.frame(i = 1, ani = NA), all_data)

all_data$i <- factor(all_data$i, levels = c(1, 2, 5, 10, 20, 30, 40, 50))

p1 <- ggplot(all_data, aes(x = i, y = ani, fill=i)) +
  geom_boxplot(na.rm = TRUE, color = "black") +
  labs(x = "Number of strains", y = "ANI") +
  theme_minimal_hgrid(12) + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),  
        panel.border = element_rect(color ="black", fill = NA, linewidth =0.8), 
        legend.position ="none", 
        axis.text = element_text(color ="black"),  
        axis.title = element_text(color ="black") )


ggsave(
  filename = file.path(output_dir, "similarity_scaling_ani_range.pdf"),
  plot = p1,
  width = 6,  
  height = 4,
  dpi = 300
)

## Similarity scaling
setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_div2/pantax/res")
dst_dir <- "/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_div2/datasets/res"

res_list <- list()

for (i in c(1, 2, 5, 10, 20, 30, 40, 50)) {
  eval_file_path <- file.path(as.character(i), "evaluation_report.txt")
  
  col_names_line <- readLines(eval_file_path, n = 1)
  col_names <- str_split(col_names_line, "\t")[[1]]
  
  data_lines <- readLines(eval_file_path)[-1]
  
  clean_data <- lapply(data_lines, function(line) {
    fields <- str_trim(str_split(line, "&")[[1]])
    nums <- suppressWarnings(as.numeric(fields))
    if (all(is.na(nums))) return(NULL)
    return(nums)
  })
  
  clean_data <- Filter(Negate(is.null), clean_data)
  
  if (length(clean_data) > 0) {
    
    ani_path = file.path(dst_dir, as.character(i), "mean_ani")
    # ani <- as.numeric(readLines(ani_path, n = 1))
    ani <- scan(ani_path, what = numeric(), nmax = 1, quiet = TRUE)
    
    data_matrix <- do.call(rbind, clean_data)
    df <- as.data.frame(data_matrix)
    colnames(df) <- col_names
    df$num <- i
    df$ANI <- ani
    df$sample_id <- "NGS"
    res_list[[length(res_list) + 1]] <- df
  }
}

setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/single_species_strain_level_1282_div2/pantax/res_hifi")
for (i in c(1, 2, 5, 10, 20, 30, 40, 50)) {
  eval_file_path <- file.path(as.character(i), "evaluation_report.txt")
  
  col_names_line <- readLines(eval_file_path, n = 1)
  col_names <- str_split(col_names_line, "\t")[[1]]
  
  data_lines <- readLines(eval_file_path)[-1]
  
  clean_data <- lapply(data_lines, function(line) {
    fields <- str_trim(str_split(line, "&")[[1]])
    nums <- suppressWarnings(as.numeric(fields))
    if (all(is.na(nums))) return(NULL)
    return(nums)
  })
  
  clean_data <- Filter(Negate(is.null), clean_data)
  
  if (length(clean_data) > 0) {
    
    ani_path = file.path(dst_dir, as.character(i), "mean_ani")
    # ani <- as.numeric(readLines(ani_path, n = 1))
    ani <- scan(ani_path, what = numeric(), nmax = 1, quiet = TRUE)
    
    data_matrix <- do.call(rbind, clean_data)
    df <- as.data.frame(data_matrix)
    colnames(df) <- col_names
    df$num <- i
    df$ANI <- ani
    df$sample_id <- "PacBio HiFi"
    res_list[[length(res_list) + 1]] <- df
  }
}

final_df <- bind_rows(res_list)
# print(final_df)
df_long <- final_df %>%
  select(num, f1_score, bc_dist, ANI, sample_id) %>% 
  pivot_longer(cols = c(f1_score, bc_dist), names_to = "metric", values_to = "value") %>%
  mutate(metric = recode(metric,
                         f1_score = "F1 score",
                         bc_dist = "BC distance"))

# bc_max <- max(df_long$value[df_long$metric == "BC distance"])
# bc_min <- min(df_long$value[df_long$metric == "BC distance"])
bc_max_p2 <- 0.125
bc_min_p2 <- 0
f1_max_p2 <- 1
f1_min_p2 <- 0.97


df_wide <- df_long %>%
  pivot_wider(names_from = metric, values_from = value) %>%
  mutate(
    bc_scaled = ( `BC distance` - bc_min_p2 ) / (bc_max_p2 - bc_min_p2) * (f1_max_p2 - f1_min_p2) + f1_min_p2
  )

p2 <- ggplot(df_wide, aes(x = num)) +
  geom_line(aes(y = `F1 score`, color = "F1 score"), size = 1) +
  geom_point(aes(y = `F1 score`, color = "F1 score"), size = 2) +
  geom_line(aes(y = bc_scaled, color = "BC distance"), size = 1, linetype = "dashed") +
  geom_point(aes(y = bc_scaled, color = "BC distance"), size = 2, shape = 17) +
  scale_y_continuous(
    name = "F1 score",
    breaks = seq(f1_min_p2, f1_max_p2, length.out = 5),
    labels = seq(f1_min_p2, f1_max_p2, length.out = 5),
    limits = c(f1_min_p2, f1_max_p2),
    sec.axis = sec_axis(
      # ~ bc_max_p2 - (. - f1_min_p2) * (bc_max_p2 - bc_min_p2) / (f1_max_p2 - f1_min_p2),
      ~ (.-f1_min_p2)/(f1_max_p2-f1_min_p2)*(bc_max_p2-bc_min_p2) + bc_min_p2,
      name = "BC distance",
      breaks = seq(bc_min_p2, bc_max_p2, length.out = 5),
      labels = seq(bc_min_p2, bc_max_p2, length.out = 5)
    )
  ) +
  scale_color_manual(
    name = NULL,
    values = c("F1 score" = "#238443", "BC distance" = "#ec7014")
  ) +
  labs(x = "Number of strains") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8), 
    axis.text = element_text(color = "black"),
    axis.title.y.right = element_text(color = "#ec7014"),
    axis.line = element_line(color = "black"), 
    axis.ticks = element_line(color = "black"),
    legend.position = "top",
    legend.key.width = unit(1, "cm")
  ) +
  facet_wrap(~ sample_id)


ggsave(
  filename = file.path(output_dir, "similarity_scaling_res.pdf"),
  plot = p2,
  width = 6,  
  height = 4,
  dpi = 300
)

# number scaling
setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts")
file_paths <- c("report/simhigh1000/ngs.tsv", "report/simhigh2000/ngs.tsv",
                "report/simhigh3000/ngs.tsv", "report/simhigh4000/ngs.tsv",
                "report/simhigh1000/hifi.tsv", "report/simhigh2000/hifi.tsv",
                "report/simhigh3000/hifi.tsv", "report/simhigh4000/hifi.tsv")

data <- do.call(rbind, lapply(file_paths, read.csv, sep="\t"))
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

data <- data %>%
  mutate(sample_id = recode(sample_id, "ngs" = "NGS", "hifi" = "Pacbio HiFi")) %>%
  mutate(dataset = str_replace(dataset, "simhigh", "sim-high"))

data$sample_id <- factor(data$sample_id, levels = c("NGS", "Pacbio HiFi"))

df_long <- data %>%
  select(dataset, f1_score, bc_dist, sample_id) %>% 
  pivot_longer(cols = c(f1_score, bc_dist), names_to = "metric", values_to = "value") %>%
  mutate(metric = recode(metric,
                         f1_score = "F1 score",
                         bc_dist = "BC distance"))

# ngs_bc_max <- max(df_long$value[df_long$metric == "BC distance" & grepl("NGS", df_long$sample_id)])
# ngs_bc_min <- min(df_long$value[df_long$metric == "BC distance" & grepl("NGS", df_long$sample_id)])
# max(df_long$value[df_long$metric == "F1 score" & grepl("NGS", df_long$sample_id)])
# min(df_long$value[df_long$metric == "F1 score" & grepl("NGS", df_long$sample_id)])
# max(df_long$value[df_long$metric == "F1 score" & grepl("HiFi", df_long$sample_id)])
# min(df_long$value[df_long$metric == "F1 score" & grepl("HiFi", df_long$sample_id)])
# max(df_long$value[df_long$metric == "BC distance" & grepl("HiFi", df_long$sample_id)])
# min(df_long$value[df_long$metric == "BC distance" & grepl("HiFi", df_long$sample_id)])

bc_max <- 0.1
bc_min <- 0.05
f1_max <- 1
f1_min <- 0.98

df_wide <- df_long %>%
  pivot_wider(names_from = metric, values_from = value) %>%
  mutate(
    # bc_scaled = (f1_max - f1_min - ( `BC distance` - bc_min ) / (bc_max - bc_min) * (f1_max - f1_min)) + f1_min
    bc_scaled = ( `BC distance` - bc_min ) / (bc_max - bc_min) * (f1_max - f1_min) + f1_min
  )

p3 <- ggplot(df_wide, aes(x = dataset)) +
  geom_line(aes(y = `F1 score`, color = "F1 score", group = sample_id), size = 1) +
  geom_point(aes(y = `F1 score`, color = "F1 score"), size = 2) +
  geom_line(aes(y = bc_scaled, color = "BC distance", group = sample_id), size = 1, linetype = "dashed") +
  geom_point(aes(y = bc_scaled, color = "BC distance"), size = 2, shape = 17) +
  scale_y_continuous(
    name = "F1 score",
    breaks = seq(f1_min, f1_max, length.out = 5),
    labels = seq(f1_min, f1_max, length.out = 5),
    limits = c(f1_min, f1_max),
    sec.axis = sec_axis(
      # ~ bc_max - (. - f1_min) * (bc_max - bc_min) / (f1_max - f1_min),
      ~ (.-f1_min)/(f1_max-f1_min)*(bc_max-bc_min) + bc_min,
      name = "BC distance",
      breaks = seq(bc_min, bc_max, length.out = 5),
      labels = seq(bc_min, bc_max, length.out = 5)
      )
  ) +
  scale_color_manual(
    name = NULL,
    values = c("F1 score" = "#238443", "BC distance" = "#ec7014")
  ) +
  labs(x = "Datasets") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8), 
    axis.text = element_text(color = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title.y.right = element_text(color = "#ec7014"),
    axis.line = element_line(color = "black"), 
    axis.ticks = element_line(color = "black"),
    legend.position = "top",
    legend.key.width = unit(1, "cm")
  ) +
  facet_wrap(~ sample_id)

library(patchwork)

combined <- p3 + p1 + p2 + plot_layout(ncol = 3)
combined <- combined + plot_annotation(tag_levels = "A")
ggsave(
  filename = file.path(output_dir, "scaling_limit_res.pdf"),
  plot = combined,
  width = 12,  
  height = 4,
  dpi = 300
)
