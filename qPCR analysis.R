setwd(dir = "~/Desktop/GitHub/Symbiont_qPCR/")
rm( list = ls())
graphics.off()
library(ggplot2)
library(ggpubr)
library(plyr)
library(dplyr)
library(reshape2)
library(mosaic)


### script to read in Master qPCR data and analyze
# VIC = C and FAM = D
# Makes 3 figures! 
#1. raw ct values by site, 
#2. averaged triplicate values by site, 
#3. averaged triplicate C/D log ratios by site

#read in all data files produced with 'reformat qPCR script'
#should be stored in 'clean_data' folder

dat1 <- read.csv("cleandata/08_05_20_fields1-4.csv")
dat2 <- read.csv("cleandata/10_14_20_fields5-8.csv")

head(dat1)
nrow(dat1)
head(dat2)
nrow(dat2)

dat <- rbind(dat1,dat2)
nrow(dat)

head(dat)
dat$FAM <- as.numeric(dat$FAM)
dat$VIC <- as.numeric(dat$VIC)


dat$Site = "n"

dat <- mutate(dat, Site = derivedFactor(
  "Faga'tele" = (grepl("Tele", dat$Sample)),
  "Faga'alu" = (grepl("Alu", dat$Sample)),
  "Vatia" = (grepl("Vat", dat$Sample)),
  "Cannery" = (grepl("Can", dat$Sample)),
  "Coconut Point" = (grepl("Coco", dat$Sample)),
  "Neg Control" = (grepl("ontrol", dat$Sample)),
  method ="first",
  .default = NA
))

dat <- dat[!(dat$Site == "Neg Control"),]

#plot raw values first (not averaged across triplicate)

dat_melt <- melt(dat, id.vars = c("Sample", "Site"), measure.vars = c("FAM", "VIC"))
head(dat_melt)

ggplot(dat_melt, aes(x = Site, y = value, fill = variable)) + 
  geom_boxplot() + theme_bw() + scale_fill_manual("Symbiont species", 
                                                  values = c("Blue", "ForestGreen"), labels = c("D. trenchii", "C. goreaui")) + 
  ylab("Ct Value (lower = MORE of that symbiont)") 

ggsave("figures/symbiontsraw_10_17_20.pdf", width = 6, height = 4)


#this takes the means for the three samples (since done in triplicate)
#if any of the three did not amplify, will say NaN

dat2 <- dat %>%
  group_by(Sample, Site) %>%
  summarize(FAM_mean = mean(FAM), VIC_mean = mean(VIC))
head(dat2)


#reformat for plotting
dat2_melt <- melt(dat2, id.vars = c("Sample", "Site"), measure.vars = c("FAM_mean", "VIC_mean"))
head(dat2_melt)

ggplot(dat2_melt, aes(x = Site, y = value, fill = variable)) + 
  geom_boxplot() + theme_bw() + scale_fill_manual("Symbiont species", 
  values = c("Blue", "ForestGreen"), labels = c("D. trenchii", "C. goreaui")) + 
  ylab("Ct Value (lower = MORE of that symbiont)") 

ggsave("figures/symbiontstriplicate_10_17_20.pdf", width = 6, height = 4)
#lower Ct value means MORE of that symbiont


# removes NAs (so not all three need to amplify (*maybe should change this*)
# then summarizes by site
replicate_means <- dat %>%
  group_by(Sample, Site) %>%
  filter(!FAM == "NaN") %>%
  filter(!VIC == "NaN") %>%
  summarize(FAM_mean = mean(FAM), VIC_mean = mean(VIC)) %>%
  filter(!Site == "")

replicate_means$CD_ratio <- (replicate_means$VIC_mean / replicate_means$FAM_mean)

#lower ratio means more C, higher means more D 

#replicate_means

replicate_means$Sample <- as.character(replicate_means$Sample)

ggplot(replicate_means, aes(Site, CD_logratio, fill = Site)) + 
  geom_boxplot() + theme_minimal() + ylab("C:D Log Ratio") 

ggsave("figures/symbiontlogratios_10_17_20.pdf", width = 6, height = 4)
#lower ratio = more C
# higher ratio = more D




# ANOVA of CD ratio by site


modelCD = lm(CD_logratio ~ Site, data=replicate_means) 
anova(modelCD) 
#not signif 
shapiro.test(modelCD$residuals)
#normal
HSD.test(modelCD,"Site")$groups
#no diffs



