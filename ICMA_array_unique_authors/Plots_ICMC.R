# SCRIPT FOR PLOTS 

# INPUT DATASET HERE FOR PLOTTING 
df_plotting <- ICMC_stats_new # from Analysis_ICMC.R 
df_wide <- df_plotting[,c(1,6:8)] # only pick percentages 
data_long <- gather(df_wide, gender, percentage, Male:Unknown, factor_key=TRUE)

# PLOTTING 
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
p + scale_fill_manual(values=c("black"))+ theme_minimal()+theme(legend.position = "none")
p+geom_smooth(method = "lm", se = FALSE)

# ONLY PLOTTING MEN (REVERSED MAPPING) 
men <- subset(data_long, gender == 'Male')
p <- ggplot(data=men, aes(x=Year, y=percentage, fill=gender)) +
  geom_bar(stat="identity", position=position_dodge())+
  xlab("Year") + ylab("Percentage")+
  ylim(0, 1)
p + scale_fill_manual(values=c("#30BC85", "#3F30BC", "#30ADBC"))+ theme_minimal()+theme(legend.position = "none")


# ONLY PLOTTING THE FIRST AUTHORS ?

# PUT LOG REGRESSION LINE TO SEE IF SIGNIFICANT DIFFERENCE OVER YEARS 
