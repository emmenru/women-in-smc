# plotting library 
library(ggplot2)
library(plotly)
library(dplyr)
library(tidyr)
library(lattice)


data_stats_corrected=0
data_stats_corrected <- read.csv("~/kurser/creative_coding/women-in-smc/output_data/ICMC_Stats_Corrected.csv")


# select only percentage columns 
myvars <- c("Year", "Female", "Male", "Unknown")
data = 0
data <- data_stats_corrected[myvars]
# skip last rows 
data = data[1:40,] 
# percentages 
data=cbind(data[1],data[c(2,4)]*100)

summary(data$Female)

p <- plot_ly(data, x = data$Year, y = data$Female, name = 'trace 0', type = 'scatter', mode = 'lines') %>%
add_trace(x = data$Year, y = data$Unknown, name = 'trace 1', mode = 'lines+markers') 

data_long = 0 
data_long <- gather(data, Category, Percentage, Female:Unknown, factor_key=TRUE) 


colors = c("midnightblue", "royalblue")
# NIME & SMC 
# set image to 900 x 500 
barchart(Percentage~Year,data=data_long,groups=Category, auto.key=list(space='right'), 
         scales=list(x=list(rot=90,cex=1.0)), ylab=list("Percentage (%)", cex=1.5), xlab=list("Year",cex=1.5), main=list("NIME 2001-2016",cex=1.5), col=c("midnightblue", "royalblue"),par.settings=list(superpose.polygon=list(col=colors)))

# ICMC 
# 1100 x 500
barchart(Percentage~Year,data=data_long,groups=Category, auto.key=list(space='right'), 
         scales=list(x=list(rot=90,cex=1.0)), ylab=list("Percentage", cex=2.0), xlab=list("Year",cex=2.0), main=list("ICMC 1975-2016",cex=2.0), col=c("midnightblue", "royalblue"),par.settings=list(superpose.polygon=list(col=colors)))


# Summarized results from years 2004-2016 
SMC<-read.csv("~/kurser/creative_coding/women-in-smc/output_data/SMC_Stats_Corrected.csv")
NIME<-read.csv("~/kurser/creative_coding/women-in-smc/output_data/NIME_Stats_Corrected.csv")
ICMC<-read.csv("~/kurser/creative_coding/women-in-smc/output_data/ICMC_Stats_Corrected.csv")

countvars <- c("Year", "FemaleCount", "MaleCount", "UnknownCount", "TotNames")
SMC=SMC[countvars][1:13,]
NIME=NIME[countvars][4:16,]
ICMC=ICMC[countvars][28:40,]

colnames(SMC)<- c("Year","FemaleCountSMC","MaleCount","UnknownCountSMC","TotNamesSMC")
colnames(NIME)<- c("Year","FemaleCountNIME","MaleCount","UnknownCountNIME","TotNamesNIME")
colnames(ICMC)<- c("Year","FemaleCountICMC","MaleCount","UnknownCountICMC","TotNamesICMC")

allData=0
allData<-cbind(SMC,NIME,ICMC)
allData$totNames=allData$TotNamesSMC+allData$TotNamesNIME+allData$TotNamesICMC
allData$female=allData$FemaleCountSMC+allData$FemaleCountNIME+allData$FemaleCountICMC
allData$femalePercentage=allData$female/allData$totNames

summary(allData$femalePercentage)
keepvars=c("Year","femalePercentage")
allData=allData[keepvars]

allData$femalePercentage=100*(allData$femalePercentage)

# Summarized data for SMC, NIME, ICMC 
# 900 x 400 
barchart(femalePercentage~Year,data=allData,auto.key=list(space='right'), 
         scales=list(x=list(rot=90,cex=1.0)), ylab=list("Percentage Female (%)", cex=1.5), xlab=list("Year",cex=1.5), main=list("ICMC, SMC & NIME 2001-2016",cex=1.5), col=c("midnightblue"))

# 2016
#29 + 43 + 31 = 103 female
#231 + 256 + 236 = 723 names 