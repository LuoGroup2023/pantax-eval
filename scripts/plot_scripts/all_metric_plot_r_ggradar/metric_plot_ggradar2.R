
library(ggradar2)
library(dplyr)
library(ggplot2)

file_path <- "report/simlow/ngs.tsv"

data <- read.csv(file_path, sep = "\t")

if ("sample_id" %in% colnames(data)) {
  colnames(data)[1] <- "group"
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

filter_data <- filter_data[!apply(filter_data, 1, function(x) any(grepl("-", x)) | any(is.na(x))), ]


filter_data[, 2:9] <- lapply(filter_data[, 2:9], as.numeric)

# p <- ggradar(
#   filter_data[1, ],
#   values.radar = c("0", "0.5", "1"),
#   grid.min = 0,
#   grid.mid = 0.5,
#   grid.max = 1
# )

tool_colors = c("PanTax"="#f8766d", "PanTax(fast)"="#dcb255", "KMCP"="#93aa00", "Ganon"="#00ba38",
                "Centrifuger"="#00c19f", "Centrifuge"="#00b9e3", "Kraken2"="#619cff", "Bracken"="#db72fb","MetaMaps"="#ff61c3",
                "StrainScan" = "#f7e1ed", "StrainGE" = "#8fc3e2", "StrainEst" = "#ffd686")

p <- ggradar2(filter_data,
              gridline.label.type = "numeric",
             gridline.label = seq(0, 1, by = 0.2),
             grid.line.width = 0.5,
             # group parameters
             group.line.width = 0.4,
             group.point.size = 2,
             polygonfill = FALSE,
             group.colours = tool_colors,
             axis.label.offset = 1.15,
             axis.label.size = 4,
             # gridline.min.linetype = "solid",
             # gridline.mid.linetype = "solid",
             # gridline.max.linetype = "solid",
             gridline.min.colour = "grey",
             gridline.mid.colour = "grey",
             gridline.max.colour = "grey",
             )

ggsave("ggradar_test.pdf", plot = p, dpi = 300)


# data(mtcars)
# 
# group = row.names(mtcars)
# df = cbind(group,mtcars)
# 
# dftest = head(df,4)
# 
# dftest = dftest[,1:7]
# facettest <- df[c(1,2,4,5,8:14),]
# # Set the subgroup names
# facet1 <- mapply(rep,c('Mazda','Hornet','Merc'),c(2,2,7))
# facet1 <- Reduce(c,facet1)
# facettest <- cbind(facettest,facet1)
# p <- ggradar2(facettest,multiplots = TRUE)
# ggsave("ggradar_test.pdf", plot = p, dpi = 300)
