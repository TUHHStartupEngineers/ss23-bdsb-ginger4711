library(data.table)
library(tidyverse) # loads ggplot2
library(lubridate)
library(dplyr)
library(tibble)
library(scales)

options(repr.plot.width=50, repr.plot.height=3)

covid_data_tbl <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv") %>% # Read the covid data
  filter(location == "Europe" | location == "Germany" | location == "United Kingdom" | location == "France" | location == "Spain" | location == "United States") %>% # Filter only the locations specified in the task
  select(date,total_cases,location) %>% # Only date, total_cases and location are needed
  filter(!is.na(total_cases)) %>% # Remove those dates where the total_cases number is not a number
  filter(date < '2022-04-20') # Plot in task stops in may of 2022, so this data stops there as well

covid_data_dt <- as.data.table(covid_data_tbl) # Convert tibble to data.frame

last_date_europe <- covid_data_dt[location == "Europe"][order(-date)][1]$date
last_date_USA <- covid_data_dt[location == "United States"][order(-date)][1]$date

addMillions <- function(x, ...) #<== function will add " %" to any number, and allows for any additional formatting through "format".
  format(paste0(x/(1e+06), " M"), ...)

covid_data_dt %>% ggplot(aes(x=date,y=total_cases),palette="Dark2") + # plot total_cases over time
  geom_line(aes(colour=location)) + # each location gets its own line
  theme(legend.position = "bottom") + # position legend at the bottom
  scale_x_date(date_breaks = "1 month", date_labels = "%B '%y") + # Change the x axis to a date axis with montly intervals and "month 'year" labels
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate the x-axis labels by 45 degrees so they don't collide with each other
  scale_y_continuous(breaks = seq(0, 200000000, by = 50000000), labels = addMillions) + 
  labs( title = "COVID-19 confirmed cases worldwide", # Set plot title.
        subtitle = "As of 19/04/2022", # Set plot subtitle.
        y = "Cumulative Cases", # Set plot y-axis label.
        colour="Continent / Country") + # Set location/country legend title.
  theme(axis.title.x=element_blank(), # remove x axis label 
        text = element_text(size=10)) + # Increase text size
  geom_text(aes(label=ifelse((location == "Europe" & date == last_date_europe) | (location == "United States" & date == last_date_USA),as.character(total_cases),''),colour="white",size=3.0),hjust=1,vjust=0)