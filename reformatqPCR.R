setwd(dir = "~/Desktop/GitHub/Symbiont_qPCR/")
rm( list = ls())
graphics.off()
library(tidyr)

data <- read.csv("rawdata/08_05_20_ahyac2019_fields1-4_5sites_threshold115.csv", header = F)
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

head(data)
tail(data)


#write CSV

write.csv(data,"cleandata/08_05_20_fields1-4.csv")
