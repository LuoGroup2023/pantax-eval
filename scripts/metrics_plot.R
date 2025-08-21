
library(ggplot2)
library(ggpattern)
library(tidyr)
library(gridExtra)

# 读取数据文件
setwd("/home/work/wenhai/metaprofiling/bacteria_refgenome_NCBIdata/scripts")
data <- read.csv("report/simhigh-gtdb/hifi.tsv", sep="\t")  
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

data <- data[, c(1, 5, 6)]

data <- data[!apply(data, 1, function(x) any(grepl("-", x))), ]

data_long <- pivot_longer(data, cols = c(precision, recall), names_to = "Metrics", values_to = "value")
data_long$value <- as.numeric(data_long$value)
# 为了让 precision 和 recall 分别朝左右两侧，我们可以调整它们的值
data_long$value <- ifelse(data_long$Metrics == "precision", -data_long$value, data_long$value)

# 设置颜色
# 删除 'color' 列，这里直接根据工具名称映射颜色
tool_colors = c("PanTax"="#de402d","PanTax(fast)"="#46CEA0","Kraken2"="#d6eff6","Ganon"="#f7e1ed",
                "Centrifuger"="#5273fc","Centrifuge"="#c695b5","MetaMaps"="#91c4e1","Bracken"="#aeb5c7", "KMCP"="#BABB37")

# 工具名称列应作为 'fill' 美学映射
data_long$Tools <- factor(data_long$Tools, levels = unique(data_long$Tools))


# 绘制条形图并添加斜线
p <- ggplot(data_long, aes(x = Tools, y = value, fill = Tools, pattern=Metrics)) +
  geom_bar_pattern(stat = "identity", position = "stack", pattern_density = 0.01, pattern_angle = 45) +  # 调整position参数为stack
  coord_flip() + 
  scale_pattern_manual(values = c(precision=NA, recall="stripe")) +
  scale_fill_manual(values = tool_colors) +  # 使用工具颜色
  labs(x = "Tools",
       y = "Score",
       fill = "Tools") +
  theme_minimal() +
  scale_y_continuous(labels = abs) +    # 确保y轴从0开始，负值显示为正值
  theme(
    legend.position = "bottom",
    axis.text.x = element_blank(), # 设置x轴文本为黑体
    axis.text.y = element_blank()   # 设置y轴文本为黑体
  ) +
  guides(pattern = "none") +
  geom_text(aes(label = round(value, 3), 
                hjust = ifelse(value > mean(value), -0.1, 2)),  # 大于均值放右侧，小于均值放左侧
            position = position_stack(vjust = 1),  
            color = "black", 
            size = 4)
grid.arrange(p, bottom=ggpubr::text_grob("simlow-gtdb-hifi", size = 12, face = "bold", hjust = 1))

legend_grob <- cowplot::get_legend(p)

p <- ggplot(data_long, aes(x = Tools, y = value, fill = Tools)) +
  geom_bar_pattern(stat = "identity", position = "stack") +  # 调整position参数为stack
  coord_flip() + 
  scale_fill_manual(values = tool_colors) +  # 使用工具颜色
  labs(x = "Tools",
       y = "Score",
       fill = "Tools") +
  theme_minimal() +
  scale_y_continuous(labels = abs) +    # 确保y轴从0开始，负值显示为正值
  theme(
    legend.position = "bottom",
    axis.text.x = element_blank(), # 设置x轴文本为黑体
    axis.text.y = element_blank()   # 设置y轴文本为黑体
  ) 

filter_data <- data[, c(1, 13)]
filter_data <- filter_data[!apply(filter_data, 1, function(x) any(grepl("-", x))), ]    
filter_data$bc_dist <- as.numeric(filter_data$bc_dist)
p <- ggplot(filter_data, aes(x = Tools, y = bc_dist, fill = Tools)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = tool_colors) + 
  labs(x = "Tools", y = "BC distance") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
grid.arrange(p, bottom=ggpubr::text_grob("simlow-gtdb-hifi", size = 12, face = "bold"))
ggsave("metrics.png", plot = p, dpi = 300)
