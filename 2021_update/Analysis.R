library(readr)
library(ggplot2)
library(tidyr)

# DO BEFORE INPUTTING FILES HERE
# IMPORT CSV FILES IN EXCEL 
# EXPORT AS CSV 
ICMC <- read.csv("~/Dev/women-in-smc/2021_update/output/ICMCgenderOutput_2021_for_R.csv", sep=";", stringsAsFactors=TRUE)[ ,c(1:40)]
NIME <- read.csv("~/Dev/women-in-smc/2021_update/output/NIMEgenderOutput_2021_for_R.csv", sep=";", stringsAsFactors=TRUE)[ ,c(1:40)]


# ICMC 
years <- range(ICMC$Year)
mydata <- ICMC 
newdata2017 <- ICMC[ which(ICMC$Year==2017), ]
newdata2018 <- ICMC[ which(ICMC$Year==2018), ]

# NIME 
years <- range(NIME$Year)
NIME2017 <- NIME[ which(NIME$Year==2017), ]
NIME2018 <- NIME[ which(NIME$Year==2018), ]
NIME2019 <- NIME[ which(NIME$Year==2019), ]
NIME2020 <- NIME[ which(NIME$Year==2020), ]


is.empty <- function(x, mode = NULL){
  if (is.null(mode)) mode <- class(x)
  identical(vector(mode, 1), c(x, vector(class(x), 1)))
}

#a <- 1
#b <- numeric(0)
#is.empty(a)

# for every year, get number of authors 
getCountsPerColumn <- function(data, column, gender){
  # this is because there table differs between the two (first gender column has no empty cells)
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
  data[ , grepl( "Gender" , names( data ) ) ]
  genders<-data[ , grepl( "Gender" , names( data ) ) ]
  
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
  return(row)
}

# ICMC 
row2017 <- getStats(newdata2017)
row2018 <- getStats(newdata2018)

df <- setNames(data.frame(matrix(ncol = 8, nrow = 0)), c('Year', 'Male', 'Female', 'Unknown', 'Total', 'Male%', 'Female%', 'Unknown%'))
df[nrow(df) + 1,] = row2017
df[nrow(df) + 1,] = row2018

# NIME 
NIME2017row <- getStats(NIME2017)
NIME2018row <- getStats(NIME2018)
NIME2019row <- getStats(NIME2019)
NIME2020row <- getStats(NIME2020)

#df <- setNames(data.frame(matrix(ncol = 8, nrow = 0)), c('Year', 'Male', 'Female', 'Unknown', 'Total', 'Male%', 'Female%', 'Unknown%'))
#df[nrow(df) + 1,] = NIME2017row
#df[nrow(df) + 1,] = NIME2018row
#df[nrow(df) + 1,] = NIME2019row
#df[nrow(df) + 1,] = NIME2020row



# format to fit with data from previous years 
# Year, MaleCount, FemaleCount, UnknownCount, TotNames, MalePercentage, FemalePercentage,  UnknownPercentage

# ICMC 
ICMC_stats <- read.csv("~/Dev/women-in-smc/2021_update/output/old-stats/ICMC_stats.csv")
stoprow <- nrow(ICMC_stats)-4
ICMC_stats_new <- ICMC_stats[c(1:stoprow),]
ICMC_stats_new[nrow(ICMC_stats_new) + 1,] = row2017
ICMC_stats_new[nrow(ICMC_stats_new) + 1,] = row2018
# make new plots over years 
olddata_wide <- ICMC_stats_new[,c(1,6:8)]
data_long <- gather(olddata_wide, gender, percentage, Male:Unknown, factor_key=TRUE)

# NIME  
NIME_stats <- read.csv("~/Dev/women-in-smc/2021_update/output/old-stats/NIME_stats.csv")
stoprow <- nrow(NIME_stats)-4

NIME_stats_new <- NIME_stats[c(1:stoprow),]
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2017row
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2018row
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2019row
NIME_stats_new[nrow(NIME_stats_new) + 1,] = NIME2020row

# WIDE TO LONG 
df_plotting <- NIME_stats_new
olddata_wide <- df_plotting[,c(1,6:8)]
data_long <- gather(olddata_wide, gender, percentage, Male:Unknown, factor_key=TRUE)


# PLOTTING 
p <- ggplot(data=data_long, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity")
p <- ggplot(data=data_long, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity", position=position_dodge())
p + scale_fill_brewer(palette="Dark2") + theme_minimal()

# ONLY PLOTTING WOMEN 
women <- subset(data_long, gender == 'Female')
p <- ggplot(data=women, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity", position=position_dodge())
p + scale_fill_brewer(palette="Dark2") + theme_minimal()



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
