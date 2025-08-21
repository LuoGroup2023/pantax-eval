


library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(jsonlite)
library(Hmisc)

setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/reference_diversity/eval/graph_mapq_eval")

data_lines <- readLines("refdiv_stat.tsv") 
df_raw <- read_tsv(paste(data_lines, collapse = "\n"), 
                   col_names = FALSE, 
                   col_types = cols(.default = "c")) 
colnames(df_raw)[1:3] <- c("label", "type", "graph_node_count")

df_raw <- df_raw %>%
  filter(!str_detect(label, "zymo")) %>%
  filter(type != "ngs")
colnames(df_raw)[ncol(df_raw)] <- "hist_str"
df_raw <- df_raw %>%
  mutate(graph_node_count = as.integer(graph_node_count))

df_long <- df_raw %>%
  select(label = 1, type = 2, graph_node_count = 3, hist_str = ncol(.)) %>%
  rowwise() %>%
  mutate(
    kv_pairs = list(str_extract_all(hist_str, "\\d+: \\d+")[[1]])
  ) %>%
  unnest(kv_pairs) %>%
  separate(kv_pairs, into = c("qv", "count"), sep = ": ") %>%
  mutate(
    qv = as.integer(qv),
    count = as.integer(count)
  ) %>%
  ungroup()

df_long <- df_long %>%
  mutate(type = recode(type,
                       "hifi"   = "PacBio HiFi",
                       "clr"    = "PacBio CLR",
                       "ontR10" = "ONT R10.4",
                       "ontR9"  = "ONT R9.4.1")) %>%
  mutate(type = factor(type,
                       levels = c("PacBio HiFi", "PacBio CLR", "ONT R10.4", "ONT R9.4.1")))

df_long <- df_long %>%
  group_by(label, type) %>%
  mutate(count_pct = count / sum(count) * 100) %>%
  ungroup()

boxplot_weighted <- df_long %>%
  group_by(type, graph_node_count) %>%
  summarise(
    ymin = min(qv),
    lower = wtd.quantile(qv, weights = count, probs = 0.25),
    middle = wtd.quantile(qv, weights = count, probs = 0.5),
    upper = wtd.quantile(qv, weights = count, probs = 0.75),
    ymax = max(qv)
  ) %>%
  ungroup()

p <- ggplot() +
  geom_boxplot(
    data = boxplot_weighted,
    aes(
      x = factor(graph_node_count),
      ymin = ymin, lower = lower, middle = middle, upper = upper, ymax = ymax
    ),
    stat = "identity", fill = "gray90", width = 0.6
  ) +
  geom_jitter(
    data = df_long,
    aes(x = factor(graph_node_count), y = qv, size = count_pct),
    width = 0.2, alpha = 0.6,
    color = "#E51718"
  ) +
  scale_size_continuous(name = "Ratio", range = c(1, 8)) +
  facet_wrap(~ type, scales = "free_x", nrow = 1) +
  labs(
    x = "Graph Node Count",
    y = "Mapping Quality (MAPQ)",
    # title = "Weighted Quality Value Distribution with Graph Complexity"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(output_dir, "graph_mapq_eval.pdf"),
  plot = p,
  width = 9,  
  height = 4,
  dpi = 300
)
        


