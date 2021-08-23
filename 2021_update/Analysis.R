library(readr)
library(ggplot2)
library(tidyr)
library(RColorBrewer)

# DO BEFORE INPUTTING FILES HERE
# IMPORT CSV FILES IN EXCEL 
# EXPORT AS CSV 
ICMC <- read.csv("~/Dev/women-in-smc/2021_update/output/corrected_output/ICMCgenderOutput_1975-2021_for_R.csv", sep=";")[ ,c(1:40)]
# add all data for NIME or SMC here instead?
NIME <- read.csv("~/Dev/women-in-smc/2021_update/output/corrected_output/NIMEgenderOutput_2020_for_R.csv", sep=";", stringsAsFactors=TRUE)[ ,c(1:40)]
SMC <- read.csv("~/Dev/women-in-smc/2021_update/output/corrected_output/SMCgenderOutput_2020_for_R.csv", sep=";", stringsAsFactors=TRUE)[ ,c(1:40)]

summary(ICMC)
class(ICMC$Year)


# ICMC 
ICMC2017 <- ICMC[ which(ICMC$Year==2017), ]
ICMC2018 <- ICMC[ which(ICMC$Year==2018), ]
ICMC2019 <- ICMC[ which(ICMC$Year==2019), ]
ICMC2021 <- ICMC[ which(ICMC$Year==2021), ]


# NIME 
NIME2017 <- NIME[ which(NIME$Year==2017), ]
NIME2018 <- NIME[ which(NIME$Year==2018), ]
NIME2019 <- NIME[ which(NIME$Year==2019), ]
NIME2020 <- NIME[ which(NIME$Year==2020), ]

# SMC 
years <- range(SMC$Year)
SMC2017 <- SMC[ which(SMC$Year==2017), ]
SMC2018 <- SMC[ which(SMC$Year==2018), ]
SMC2019 <- SMC[ which(SMC$Year==2019), ]
SMC2020 <- SMC[ which(SMC$Year==2020), ]

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

# ICMC 
#getYear(2017, ICMC)
years <- levels(as.factor(ICMC$Year))
years = years[-length(years)] # remove Year label
years = as.numeric(years)


df_ICMC <- lapply(years, getYear, data = ICMC)

# NIME 
NIME2017row <- getCountsPerYear(NIME2017)
NIME2018row <- getCountsPerYear(NIME2018)
NIME2019row <- getCountsPerYear(NIME2019)
NIME2020row <- getCountsPerYear(NIME2020)

# SMC 
SMC2017row <- getCountsPerYear(SMC2017)
SMC2018row <- getCountsPerYear(SMC2018)
SMC2019row <- getCountsPerYear(SMC2019)
SMC2020row <- getCountsPerYear(SMC2020)

# SMC first authors 
SMC2017rowFirst <- getCountsPerYearFirstAuthor(SMC2017)
SMC2018rowFirst <- getCountsPerYearFirstAuthor(SMC2018)
SMC2019rowFirst <- getCountsPerYearFirstAuthor(SMC2019)
SMC2020rowFirst <- getCountsPerYearFirstAuthor(SMC2020)

df <- setNames(data.frame(matrix(ncol = 8, nrow = 0)), c('Year', 'Male', 'Female', 'Unknown', 'Total', 'Male%', 'Female%', 'Unknown%'))
df[nrow(df) + 1,] = SMC2017rowFirst
df[nrow(df) + 1,] = SMC2018rowFirst
df[nrow(df) + 1,] = SMC2019rowFirst
df[nrow(df) + 1,] = SMC2020rowFirst

# format to fit with data from previous years 
# ICMC 
ICMC_stats <- read.csv("~/Dev/women-in-smc/2021_update/output/old-stats/ICMC_stats.csv")
# this one is wrong and needs to be recalculated !!!! or maybe not? 
stoprowICMC <- nrow(ICMC_stats)-4
ICMC_stats_new <- ICMC_stats[c(1:stoprowICMC),]

ICMC_stats_new_fixed = as.data.frame(do.call(rbind, df_ICMC))
names(ICMC_stats_new_fixed) = names(ICMC_stats_new)
ICMC_stats_new=ICMC_stats_new_fixed
# compare these 
View(ICMC_stats)
View(ICMC_stats_new_fixed)
ICMC_stats$TotNames[0:40]==ICMC_stats_new_fixed$TotNames[0:40]

#olddata_wide_ICMC <- ICMC_stats_new[,c(1,6:8)]
#data_long_ICMC <- gather(olddata_wide_ICMC, gender, percentage, Male:Unknown, factor_key=TRUE)

# save file for ICMA Array - unique authors 
write.csv(ICMC_stats_new,'ICMC_stats_new.csv')

ICMC_tot = sum(ICMC_stats_new$MaleCount)+sum(ICMC_stats_new$FemaleCount)+sum(ICMC_stats_new$UnknownCount)
ICMC_women = sum(ICMC_stats_new$FemaleCount)/ICMC_tot*100

# overall 
ICMC_tot = sum(ICMC_stats_new$MaleCount)+sum(ICMC_stats_new$FemaleCount)+sum(ICMC_stats_new$UnknownCount)
ICMC_women = sum(ICMC_stats_new$FemaleCount)/ICMC_tot*100
ICMC_male = sum(ICMC_stats_new$MaleCount)/ICMC_tot*100

# NIME  
NIME_stats <- read.csv("~/Dev/women-in-smc/2021_update/output/old-stats/NIME_stats.csv")
stoprowNIME <- nrow(NIME_stats)-4
NIME_stats_new <- NIME_stats[c(1:stoprowNIME),]
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2017row
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2018row
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2019row
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2020row

# overall 
NIME_tot = sum(NIME_stats_new$MaleCount)+sum(NIME_stats_new$FemaleCount)+sum(NIME_stats_new$UnknownCount)
NIME_women = sum(NIME_stats_new$FemaleCount)/NIME_tot*100

# SMC  
SMC_stats <- read.csv("~/Dev/women-in-smc/2021_update/output/old-stats/SMC_stats.csv")
stoprowSMC <- nrow(SMC_stats)-4
SMC_stats_new <- SMC_stats[c(1:stoprowSMC),]
SMC_stats_new[nrow(SMC_stats_new) + 1,] = SMC2017row
SMC_stats_new[nrow(SMC_stats_new) + 1,] = SMC2018row
SMC_stats_new[nrow(SMC_stats_new) + 1,] = SMC2019row
SMC_stats_new[nrow(SMC_stats_new) + 1,] = SMC2020row

# overall 
SMC_tot = sum(SMC_stats_new$MaleCount)+sum(SMC_stats_new$FemaleCount)+sum(SMC_stats_new$UnknownCount)
SMC_women = sum(SMC_stats_new$FemaleCount)/SMC_tot*100
  
# make a sonification for SMC 2019
View(SMC2019) # these figures are very high, check if everything is actually correct 
View(gendersSMC2019)
occurences<-table(unlist(gendersSMC2019))
occurences["male"]

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

#################################################### OLD 


# for every year, get number of authors 
getCountsPerColumn <- function(data, column, gender){
  tab <- table(data[column])
  #print(tab)
  if (gender=='female') { 
    out <- (tab[names(tab)=='female'])
  } else if (gender=='male') { 
    out <- (tab[names(tab)=='male'])
  } else {
    out <- (tab[names(tab)=='None'])
  }
  return(out)
}

getStats <- function(data) {
  # only get columns with gender data 
  genders<-data[ , grepl( "Gender" , names( data ) ) ]
  #print(genders)
  # total number of names per year 
  numAuthors <- sum(data$NumberOfAuthors)
  femaleCountTot = 0 
  maleCountTot = 0 
  unknownCountTot = 0
  # iterate through all columns in the dataset 
  for(i in 1:17) {
    print(paste('COLUMN NUMBER:', i)) 
    column = i 
    #print((genders[column]))
    tab <- table(genders[column])
    print(tab)
    femaleCount = as.integer(getCountsPerColumn(genders, column, 'female'))
    maleCount = as.integer(getCountsPerColumn(genders, column, 'male'))
    unknownCount = as.integer(getCountsPerColumn(genders, column, 'unknown')) 
    
    # if count is empty, do not add it 
    if (is.empty(unknownCount)){
      unknownCount = 0
    }
    if (is.empty(femaleCount)){
      femaleCount = 0
    }
    if (is.empty(maleCount)){
      maleCount = 0
    }
    
    femaleCountTot = femaleCountTot + femaleCount 
    maleCountTot = maleCountTot + maleCount
    unknownCountTot = unknownCountTot + unknownCount
    
    # output per column
    print(paste('F:', femaleCount)) 
    print(paste('M:', maleCount)) 
    print(paste('U:', unknownCount)) 
  }
  
  
  year = data$Year[1]
  totNames = femaleCountTot + maleCountTot + unknownCountTot
  malePercentage = maleCountTot/totNames
  femalePercentage = femaleCountTot/totNames 
  unknownPercentage = unknownCountTot/totNames
  row <- c(year, maleCountTot, femaleCountTot, unknownCountTot, totNames, malePercentage, femalePercentage, unknownPercentage)
  # make sure that the total corresponds to the total number of authors listed in the original csv file 
  stopifnot(numAuthors == totNames)
  return(row)
}


#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#### CHECK THIS 
#### SOMETHING IS UP WITH THE LEVELS 
# I don't understand why this one has the category None
summary(newdata2017$Gender4)
View(newdata2017$Gender4)
# but this one does not
summary(newdata2017$Gender3)
View(newdata2017$Gender3)

levels(newdata2017$Gender4)
levels(newdata2017$Gender3)
levels(droplevels(newdata2017$Gender4))

# check agains this to verify 
summary(newdata2017$Gender2)

