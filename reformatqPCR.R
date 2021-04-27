setwd(dir = "~/Desktop/GitHub/Symbiont_qPCR/")
rm( list = ls())
graphics.off()
library(tidyr)

data <- read.csv("rawdata/2014data/2014data_04_26_21_ahyac31-36,38-43_50th.csv", header = F)
head(data)
colnames(data) <- as.character(unlist(data[20,]))
data <- data[-c(1:20),]
head(data)
tail(data)

data <- spread(data, Fluor, Cq)
head(data)

#confirm neg control 
data %>%
  filter(Content == "Neg Ctrl")
#check that theres no value for these in FAM or VIC columns 

data$Target <- NULL
data$Content <- NULL
data$Well <- NULL
data$`Starting Quantity (SQ)` <- NULL

head(data)
tail(data)


#write CSV
write.csv(data,"cleandata/2014data/2014data_clean_04_26_21_ahyac31-36,38-43_50th.csv", row.names = F)
