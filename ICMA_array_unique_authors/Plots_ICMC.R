# SCRIPT FOR PLOTS AND POISSON REGRESSIONS
library(car)
 
#### FEMALE AUTHOR NAMES ICMC 
# INPUT DATASET HERE FOR PLOTTING 
# DATA THAT HAS BEEN CORRECTED TO ACCOUNT FOR THE FACT THAT SOME AUTHORS OCCUR SEVERAL TIMES, I.E. UNIQUE AUTHOR NAMES 
df_plotting <- read.csv("~/Dev/women-in-smc/ICMA_array_unique_authors/output/ICMC_stats_unique_authors.csv", sep=",")

# Total number of female author names 
summary(df_plotting$Female.)
sum(df_plotting$FemaleCount)/ (sum(df_plotting$FemaleCount)+ sum(df_plotting$MaleCount))

df_wide <- df_plotting[,c(2,7:9)] # only pick percentages 
data_long <- gather(df_wide, gender, percentage, Male.:Unknown., factor_key=TRUE)
# convert to percentages 
data_long$percentage = data_long$percentage*100

# ONLY PLOTTING WOMEN 
women <- subset(data_long, gender == 'Female.')
p <- ggplot(data=women, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity", position=position_dodge())+
  xlab("Year") + ylab("ICMC Female Author Names (%)")
p+geom_smooth(method = "glm", formula = y~x, method.args = list(family = gaussian(link = 'log')))+
  scale_fill_manual(values=c("black"))+ theme_minimal()+theme(legend.position = "none")

plot(df_plotting$FemaleCount)
p<-plot(df_plotting$FemaleCount/df_plotting$MaleCount)
ggplot(df_plotting, aes(x=Year, y=Female.)) + 
  geom_point()+
  geom_smooth(method = 'loess', formula=y~x)+
  scale_y_continuous(limits = c(0, 0.5))

scatterplot(FemaleCount ~ MaleCount, data = df_plotting)

# linear regression with a logit transformation 

df_plotting$TotFemaleMale <- df_plotting$MaleCount+df_plotting$FemaleCount 

poisson.model.count <- glm(FemaleCount ~ Year + MaleCount, family="poisson", data=df_plotting)
summary(poisson.model.count)

years = 40
testYear=df_plotting$Year[years]
testMaleCount = df_plotting$MaleCount[years]
testFemaleCount = df_plotting$FemaleCount[years]
exp(coef(poisson.model.count)[1] + coef(poisson.model.count)[2]*testYear+coef(poisson.model.count)[3]*testMaleCount)
# count female = exp(Intercept + B1*x0 +B2*x1)  
fitted(poisson.model.count)[years]
testFemaleCount

# count in x years if number of men is z
x = 100 # please note that the time required would be (1975+x)-2021
z = 177.0 #median for all years
# what is a reasonable z? 
plot(df_plotting$TotFemaleMale)
summary(df_plotting$TotFemaleMale)
exp(coef(poisson.model.count)[1] + coef(poisson.model.count)[2]*(1975+x)+coef(poisson.model.count)[3]*z)
time= (1975+x)-2021
#https://stats.stackexchange.com/questions/272194/interpreting-poisson-output-in-r/272199

# find the log(n) of each value (n=population)
new_df = df_plotting
new_df = new_df[,c(2,4,10)]
logpop = log(new_df$TotFemaleMale) # disregard unknowns
newYear<-new_df$Year-1975
new_df = cbind(new_df, logpop, newYear)
poisson.model.rate <-glm(FemaleCount ~ Year + offset(logpop), family = poisson(link = "log"), data = new_df)
summary(poisson.model.rate)
# expected log count for a one-unit increase in Year is 0.021923
#For a 1 unit increase in log(year), the estimated count increases by a factor of e^0.021923
exp(0.021923)

x = 21
offset = new_df$TotFemaleMale[x]
exp(coef(poisson.model.rate)[1] + coef(poisson.model.rate)[2]*(1975+x) + log(offset)) # is this correct?? 
# compare to 
fitted(poisson.model.rate)
new_df$FemaleCount[x]
# why are the fitted values not the same as the ones I get from the equation

plot(poisson.model.rate)

# use 'predict()' to run model on new data
summary(poisson.model.rate)

# naive approach
naive.model <- (lm(Female.~Year, data=df_plotting))
#y = kx+m 
year = 2150
coef(naive.model)[1]+coef(naive.model)[2]*year


# POISSON REGRESSION WITH OFFSET FOR TOTAL POPULATION (RATIO DATA)
#https://stats.idre.ucla.edu/r/dae/poisson-regression/ 
# https://education.illinois.edu/docs/default-source/carolyn-anderson/edpsy589/lectures/4_glm/4glm_3_beamer_post.pdf
# https://www.dataquest.io/blog/tutorial-poisson-regression-in-r/ 
with(poisson.model.rate, cbind(res.deviance = deviance, df = df.residual,
               p = pchisq(deviance, df.residual, lower.tail=FALSE)))

new_df
#s1 <- data.frame(Year = c(1975, 1975+10, 1975+20, 1975+30, 1975+40, 1975+50), logpop=c(3.218876,4.488636,5.459586,5.950643,5.209486,5.209486))

s1 <- data.frame(Year = c(2010, 2020, 2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100), logpop=c(log(177), log(177), log(177), log(177), log(177), log(177), log(177), log(177), log(177), log(177)))

predict(poisson.model.rate, s1, type="response", se.fit=TRUE)

## calculate and store predicted values
p$phat <- predict(poisson.model.rate, type="response")

#### MEMBERSHIPS ICMA 
# IMPORT ICMA MEMBERSHIP DATA 
df_ICMA <- read.csv("~/Dev//women-in-smc/ICMA_array_unique_authors/ICMA-members/ICMA_data.csv", sep=";", header = F)
df_ICMA_nums <- df_ICMA[-1,-1]

new_row <-  colSums(df_ICMA_nums) 
new_row = as.numeric(new_row)
new_row = c("Total", new_row)
df_ICMA = rbind(df_ICMA, new_row)

t_df_ICMA <- t(df_ICMA)#[-1,]
t_df_ICMA = as.data.frame(t_df_ICMA)
names(t_df_ICMA) <- as.character(unlist(t_df_ICMA[1,]))
t_df_ICMA = t_df_ICMA[-1,]
t_df_ICMA <- as.data.frame(sapply(t_df_ICMA, as.numeric))

# do not take non profit into account! thats like companies or organizations
t_df_ICMA$TotalNotNonProfit <- t_df_ICMA$Male+t_df_ICMA$Female
t_df_ICMA$WomenPercentage <- t_df_ICMA$Female / t_df_ICMA$TotalNotNonProfit * 100
t_df_ICMA$MenPercentage <- t_df_ICMA$Male / t_df_ICMA$TotalNotNonProfit * 100
# summary
summary(t_df_ICMA$WomenPercentage)

# to long 
data_long_ICMA <- gather(t_df_ICMA, gender, percentage, WomenPercentage:MenPercentage, factor_key=TRUE)
data_long_ICMA <- data_long_ICMA[,c(1,7:8)] # only pick percentages 

# PLOT ICMA MEMBERSHIPS 
women_ICMA <- subset(data_long_ICMA, gender=="WomenPercentage")
p <- ggplot(data=women_ICMA, aes(x=Year, y=percentage)) +
  geom_bar(stat="identity", position=position_dodge())+
  xlab("Year") + ylab("ICMA Female Members (%)")#+
#ylim(0, 1)
p + scale_fill_manual(values=c("black"))+ theme_minimal()+theme(legend.position = "none")
#p+geom_smooth(method = "lm", se = FALSE)