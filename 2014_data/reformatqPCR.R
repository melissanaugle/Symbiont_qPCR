setwd(dir = "~/Desktop/GitHub/Symbiont_qPCR/2014_data/")
rm( list = ls())
graphics.off()
library(tidyr)

#enter your raw output from the qPCR machine here as csv 
data <- read.csv("rawdata/04_26_21_ahyac31-36,38-43_50th.csv", header = F)
head(data)
colnames(data) <- as.character(unlist(data[20,]))
#remove header rows with metadata
data <- data[-c(1:20),]
head(data)
tail(data)

data <- spread(data, Fluor, Cq)
head(data)

#confirm neg control 
data %>%
  filter(Content == "Neg Ctrl")
#check that theres no value for these in FAM or VIC columns 

#remove negative controls 
data <- data[!(data$Content == "Neg Ctrl"),]

#remve columns we dont need 
data$Target <- NULL
data$Content <- NULL
data$Well <- NULL
data$`Starting Quantity (SQ)` <- NULL

#check that data look good
head(data)
tail(data)


#write CSV
write.csv(data,"cleandata/clean_04_26_21_ahyac31-36,38-43_50th.csv", row.names = F)
