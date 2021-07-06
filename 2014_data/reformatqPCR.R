

setwd(dir = "~/Desktop/GitHub/Symbiont_qPCR/2014_data/")
rm( list = ls())
graphics.off()
library(tidyr)

#enter your raw output from the qPCR machine here as csv 
data <- read.csv("rawdata/06_29_21_ahyacC56,C57,C64-68,D78,D80-82_threshold50.csv", header = F)
head(data)
colnames(data) <- as.character(unlist(data[20,]))
#remove header rows with metadata
data <- data[-c(1:20),]
head(data)
tail(data)

#look at ct values for FAM and VIC
data <- spread(data, Fluor, Cq)
head(data)

#confirm neg control 
data %>%
  filter(Content == "Neg Ctrl")
#check that theres no value for these in FAM or VIC columns 

#remove negative controls 
data <- data[!(data$Content == "Neg Ctrl"),]


#remove columns we dont need 
data$Target <- NULL
data$Content <- NULL
data$Well <- NULL
data$`Starting Quantity (SQ)` <- NULL

#check that data look good
head(data)
tail(data)


#write CSV
#write.csv(data,"cleandata/clean_06_29_21_ahyacC56,C57,C64-68,D78,D80-82_threshold50.csv", row.names = F)
