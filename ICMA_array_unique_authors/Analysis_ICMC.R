library(readr)
library(ggplot2)
library(tidyr)
library(RColorBrewer)

ICMC <- read.csv("~/Dev/women-in-smc/ICMA_array_unique_authors/input/ICMCgenderOutput_1975-2021_for_R_manually_fixed.csv", sep=";")[ ,c(1:40)]

summary(ICMC)
class(ICMC$Year)

is.empty <- function(x, mode = NULL){
  if (is.null(mode)) mode <- class(x)
  identical(vector(mode, 1), c(x, vector(class(x), 1)))
  #a <- 1
  #b <- numeric(0)
  #is.empty(a)
}


getCountsPerYear <- function(data){
  print("calculating stats for year: ")
  genders<-data[ , grepl( "Gender" , names( data ) ) ]
  # remove columns in which there are any NAs
  genders <- genders[ , apply(genders, 2, function(x) !any(is.na(x)))]
  # gets number per row in dataset 
  counts <- t(apply(genders, 1, function(u) table(factor(u, levels=c("male","female", "None"))))) 
  counts = as.data.frame(counts)
  # sum per column to get a number per year 
  #output <- c(sum(counts$female), sum(counts$male), sum(counts$None))
  year = as.numeric(data$Year[1])
  print(year)
  maleCountTot = sum(counts$male)
  femaleCountTot = sum(counts$female)
  unknownCountTot = sum(counts$None)
  totNames = maleCountTot + femaleCountTot + unknownCountTot
  malePercentage = maleCountTot/totNames
  femalePercentage = femaleCountTot/totNames 
  unknownPercentage = unknownCountTot/totNames
  #print(c(year, maleCountTot, femaleCountTot))
  row <- c(year, maleCountTot, femaleCountTot, unknownCountTot, totNames, malePercentage, femalePercentage, unknownPercentage)
  return(row)
}


getCountsPerYearFirstAuthor <- function(data){
  #for debugging
  #genders <- data$Gender
  #gets number per row in dataset 
  #print(summary(genders))
  year = data$Year[1]
  maleCountTot = sum(with(data, Gender=='male'))
  femaleCountTot = sum(with(data, Gender=='female'))
  unknownCountTot = sum(with(data, Gender=='None'))
  #print(femaleCountTot)
  #print(maleCountTot)
  #print(unknownCountTot)
  totNames = maleCountTot + femaleCountTot + unknownCountTot
  malePercentage = maleCountTot/totNames
  femalePercentage = femaleCountTot/totNames 
  unknownPercentage = unknownCountTot/totNames
  row <- c(year, maleCountTot, femaleCountTot, unknownCountTot, totNames, malePercentage, femalePercentage, unknownPercentage)
  return(row)
}

# sum column $NumberOfAuthors to verify that total is correct 

getYear <- function(year, data){
  oneYear <- data[ which(data$Year==year), ]
  oneYearRow <- getCountsPerYear(oneYear) 
  return(oneYearRow)
}

#getYear(2017, ICMC)
years <- levels(as.factor(ICMC$Year))
years = as.numeric(years)
df_ICMC <- lapply(years, getYear, data = ICMC)

# check old stat results with new results 
ICMC_stats <- read.csv("~/Dev/women-in-smc/2021_update/output/old-stats/ICMC_stats.csv")
ICMC_stats_new_fixed = as.data.frame(do.call(rbind, df_ICMC))
names(ICMC_stats_new_fixed) = names(ICMC_stats_new)
ICMC_stats_new=ICMC_stats_new_fixed
# compare these 
View(ICMC_stats)
View(ICMC_stats_new)
ICMC_stats$TotNames[0:40]==ICMC_stats_new$TotNames[0:40]
ICMC_stats$TotNames[0:40]
ICMC_stats_new$TotNames[0:40]
# there is a difference with one person after modifying the dataset file 

#olddata_wide_ICMC <- ICMC_stats_new[,c(1,6:8)]
#data_long_ICMC <- gather(olddata_wide_ICMC, gender, percentage, Male:Unknown, factor_key=TRUE)

# save file for ICMA Array - unique authors 
write.csv(ICMC_stats_new,"~/Dev/women-in-smc/ICMA_array_unique_authors/input/ICMC_stats_new.csv")

# overall 
ICMC_tot = sum(ICMC_stats_new$MaleCount)+sum(ICMC_stats_new$FemaleCount)+sum(ICMC_stats_new$UnknownCount)
ICMC_women = sum(ICMC_stats_new$FemaleCount)/ICMC_tot*100
ICMC_male = sum(ICMC_stats_new$MaleCount)/ICMC_tot*100

# INPUT DATASET HERE FOR PLOTTING 
df_plotting <- ICMC_stats_new
olddata_wide <- df_plotting[,c(1,6:8)]
data_long <- gather(olddata_wide, gender, percentage, Male:Unknown, factor_key=TRUE)

# PLOTTING 
#p <- ggplot(data=data_long, aes(x=Year, y=percentage, fill=gender)) +
#  geom_bar(stat="identity")
p <- ggplot(data=data_long, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity", position=position_dodge())+
  xlab("Year") + ylab("Percentage")+labs(fill = "Gender")
p + scale_fill_manual(values=c("#30BC85", "#3F30BC", "#30ADBC"))+ theme_minimal()

# ONLY PLOTTING WOMEN 
women <- subset(data_long, gender == 'Female')
p <- ggplot(data=women, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity", position=position_dodge())+
  xlab("Year") + ylab("Percentage")#+
  #ylim(0, 1)
p + scale_fill_manual(values=c("#30BC85", "#3F30BC", "#30ADBC"))+ theme_minimal()+theme(legend.position = "none")

# ONLY PLOTTING MEN (REVERSED MAPPING) 
men <- subset(data_long, gender == 'Male')
p <- ggplot(data=men, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity", position=position_dodge())+
  xlab("Year") + ylab("Percentage")+
  ylim(0, 1)
p + scale_fill_manual(values=c("#30BC85", "#3F30BC", "#30ADBC"))+ theme_minimal()+theme(legend.position = "none")


# ONLY PLOTTING THE FIRST AUTHORS ?
# PERHAPS IF THERE IS TIME 

# PUT LOG REGRESSION LINE TO SEE IF SIGNIFICANT DIFFERENCE OVER YEARS 

