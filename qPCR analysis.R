setwd(dir = "~/Desktop/CSUMB/Thesis/Data analysis/Scripts/")
rm( list = ls())
graphics.off()
library(ggplot2)
library(ggpubr)
require(plyr)
library(dplyr)
library(reshape2)

### script to read in Master qPCR data and analyze
# VIC = C and FAM = D

#dat <- read.csv("../Data/qpcr/qPCR  Master - Data_2014andpractice.csv")
dat <- read.csv("../Data/qpcr/Master2019Ahyac_qPCR.csv")
head(dat)
dat$FAM.Cq <- as.numeric(dat$FAM.Cq)
dat$VIC.Cq <- as.numeric(dat$VIC.Cq)

dat2 <- dat %>%
  group_by(Sample, Site, Year, Well_FAM) %>%
  summarize(FAM.Cq = mean(FAM.Cq), VIC.Cq = mean(VIC.Cq))
head(dat2)

dat2 <- melt(dat2, id.vars = c("Sample", "Site", "Year", "Well_FAM"), measure.vars = c("FAM.Cq", "VIC.Cq"))
head(dat2)

ggplot(dat2, aes(x = Site, y = value, fill = variable)) + 
  geom_boxplot() + theme_bw() + scale_fill_manual("Symbiont species", 
  values = c("Blue", "Green"), labels = c("D. trenchii", "C. goreaui")) + 
  ylab("Ct Value (lower = MORE of that symbiont)") 

ggsave("../Figures - symbionts/080520prelim_symbiontqpcr_2019fields.pdf", width = 6, height = 4)

#lower value means MORE of that symbiont



replicate_means <- dat %>%
  group_by(Sample, Site, Year) %>%
  summarize(FAMCq_mean = mean(FAM.Cq), VICCq_mean = mean(VIC.Cq)) %>%
  filter(!FAMCq_mean == "NaN") %>%
  filter(!VICCq_mean == "NaN") %>%
  filter(!Site == "")

replicate_means$CD_logratio <- log(replicate_means$VICCq_mean / replicate_means$FAMCq_mean)

#lower ratio means more C, higher means more D 

#replicate_means

replicate_means$Sample <- as.character(replicate_means$Sample)

ggplot(replicate_means, aes(Site, CD_logratio, fill = Site)) + geom_bar(stat = "identity") 

modelCD = lm(CD_logratio ~ Site, data=replicate_means) 
anova(modelCD) 
#signif 
shapiro.test(modelCD$residuals)
#normal
HSD.test(modelCD,"Site")$groups
#no diffs


# to add error bars

se <- function(x) sd(x)/sqrt(length(x))

data.means <- replicate_means %>% 
  group_by(Site) %>% 
  summarise(CD_logratio_mean = mean(CD_logratio))
data.means

data.se <- replicate_means %>%
  group_by(Site) %>% 
  summarise(CD_logratio_se = se(CD_logratio))
data.se

ggplot(data.means, aes(Site, CD_logratio_mean, fill = Site)) + geom_bar(stat = "identity") + 
  geom_errorbar(aes(ymin = data.means$CD_logratio_mean - data.se$CD_logratio_se, 
                  ymax = data.means$CD_logratio_mean + data.se$CD_logratio_se), 
                width = .1, colour = "black") + theme_bw() + ylab("C:D Log Ratio") + 
  ggtitle("")


ggsave("../CD_logratios.pdf", width = 5, height = 5)
