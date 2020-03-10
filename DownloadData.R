#------------------------------------
# Download and selection data Belgium
# Author: Joris Meys
# date last modified: 2020-03-08
#------------------------------------
# This file will check the latest data on the repo of John Hopkins
# It will -if necessary - download those and add the new data to
# the original file. 
library(dplyr)
# Setup
firstdate <- as.Date("2020-01-22")
fprocessed <- file.path("processed","covid_selection.csv")

# Choose countries to keep
countries <- c("Belgium","France","Germany","Italy","Netherlands", "UK",
               "South Korea","Japan")

days <- seq(firstdate,Sys.Date() - 1,
            by = "1 day")
fnames <- paste0(format(days, "%m-%d-%Y"),".csv")

if(!dir.exists("rawdata")) dir.create("rawdata")

if(!dir.exists("processed")) dir.create("processed")

if(!file.exists(fprocessed)){
  tmpdf <- data.frame(date = integer(0), Confirmed = integer(0), 
                      Deaths = integer(0), Recovered = integer(0),
                      Country = character(0))
  write.csv(tmpdf,
            fprocessed,
            row.names = FALSE
  )
  rm(tmpdf)
}


#----------------------------------------
# Download files from John Hopkins (thx!)
master_url <- paste("https://raw.githubusercontent.com",
                    "CSSEGISandData/COVID-19/master",
                    "csse_covid_19_data",
                    "csse_covid_19_daily_reports",
                    sep = "/")

for(fn in fnames){
  thefile <- file.path("rawdata",fn)
  if(!file.exists(thefile))
  download.file(file.path(master_url,fn),
                dest = thefile)
}

#----------------------------------------
# Select data for Belgium

# find files to add
presdates <- read.csv(fprocessed,
                      colClasses = c("Date",rep("numeric",3),
                                     "character")
)
latest <- max(presdates$date, firstdate - 1, na.rm = TRUE)
id <- days > latest

cols <- c("Country.Region","Confirmed","Deaths","Recovered")
# Loop over the necessary files, find data, add to .csv
for(i in which(id)){
  fn <- fnames[i]
  tmp <- read.csv(file.path("rawdata",fn))[cols] %>%
    filter(Country.Region %in% countries) %>%
    mutate(date = days[i]) %>%
    select(date, Confirmed, Deaths, Recovered,
           Country = Country.Region)
  write.table(tmp,
            fprocessed,
            row.names = FALSE,
            col.names = FALSE,
            append = TRUE,
            sep = ",")
}

# Cleanup
rm(list = ls())
