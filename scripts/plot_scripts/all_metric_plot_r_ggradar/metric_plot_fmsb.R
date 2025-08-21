
library(fmsb)
library(dplyr)

file_path <- "report/simlow/ngs.tsv"

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
  colnames(data)[12] <- "L1 distance"
  colnames(data)[13] <- "BC distance"
  
  filter_data <- data[, c(1, 5:13)]
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
  
  filter_data <- data[, c(1, 11)]    
}

filter_data <- filter_data[filter_data$Tools != "Centrifuge", ]
filter_data <- filter_data[!apply(filter_data, 1, function(x) any(grepl("-", x)) | any(is.na(x))), ]


# filter_data <- as.data.frame(t(filter_data))

# filter_data <- filter_data %>% 
#   rename_with(~ as.character(unlist(filter_data[1, ]))) %>%  
#   slice(-1) 

rownames(filter_data) <- filter_data[, 1]  
filter_data <- filter_data[, -1]

filter_data <- rbind(rep(1, ncol(filter_data)), rep(0, ncol(filter_data)), filter_data)

rownames(filter_data)[1:2] <- c("Max", "Min")

filter_data[, 1:9] <- lapply(filter_data[, 1:9], as.numeric)


tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")
pdf("simlow-ngs.pdf", width = 12, height = 8)  # 你也可以用 pdf() 或 tiff()

# 设置边距，防止图例或标题被裁剪
par(mar = c(4, 4, 4, 8))  # 右侧留白用于图例

# 画雷达图
radarchart(filter_data, axistype = 1,
           pcol = tool_colors[rownames(filter_data[-c(1,2),])], 
           plwd = 4, plty = "dotdash",
           cglcol = "grey", cglty = 1, cglwd = 0.8,
           axislabcol = "black", 
           vlcex = 1.5, vlabels = colnames(filter_data),
           caxislabels = seq(0, 1, by = 0.2))

# 添加标题
title("simlow-ngs")

# 调整图例位置
legend("topright", legend = rownames(filter_data[-c(1,2),]), 
       fill = tool_colors, bty = "n", cex = 1)

# 关闭设备，保存图片
dev.off()
# radarchart(filter_data, axistype = 1,
#            pcol = tool_colors[rownames(filter_data)], 
#            plwd = 2, plty = "dotdash",
#            cglcol = "grey", cglty = 1, cglwd = 0.8,
#            axislabcol = "black", 
#            vlcex = 1.5, vlabels = colnames(filter_data),
#            caxislabels = seq(0, 1, by = 0.2))
# 
# legend("topright", legend = rownames(filter_data[-c(1,2),]), fill = tool_colors, bty = "n", cex = 1, x=1.5, y=1.3)
# 
# title("simlow-ngs")
