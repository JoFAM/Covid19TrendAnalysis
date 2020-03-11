#------------------------------------
# Create a plot showing trend of confirmed cases
# Author: Joris Meys
# date last modified: 2020-03-10
#------------------------------------
# Setup

library(ggplot2)
library(patchwork)
library(dplyr)
library(gridExtra)

# This will either create the file covid_selection.csv
# or download the latest data and add that to covid_selection.csv
source("DownloadData.R")

# Read in the data
dat <- read.csv("processed/covid_selection.csv",
                colClasses = c("Date",rep("numeric",3),"character"))

# Calculate the delay based on reaching 100 patients.
# Look for the first date more than 100 patients were confirmed.
# Calculate the difference with Italy to determine lag.
dat %>% group_by(Country) %>%
  summarise(refdate = date[min(which(Confirmed > 100))]) %>%
  ungroup() %>%
  mutate(delay = refdate - refdate[Country == "Italy"]) ->
  delays

ItalyStart <- delays[delays$Country == "Italy","refdate", drop = TRUE]

plotdata <- left_join(dat, delays, by = "Country") %>%
  mutate(alpha = ifelse(Country == "Belgium",1,0.5))

# Some plots

# Linear plot
plin <- ggplot(plotdata, aes(x = date, y = Confirmed,
                             color = Country)) +
  geom_line(size = 1) + geom_point(alpha = 0.5) +
  scale_color_viridis_d(option= "magma")

# Logarithmic plot
plog <- plin + scale_y_log10() +
  labs(y = "Confirmed (log)")

# Delay plot
pdelay <- ggplot(plotdata, aes(x = as.numeric((date - delay) - ItalyStart),
                               y = Confirmed,
                               color = Country)) +
  geom_point(alpha = 0.5) + geom_line(stat = "smooth",
                                      method = "loess",
                                      size = 1,
                                      alpha = 0.5) +
  geom_line(data = plotdata[plotdata$Country == "Belgium",],
            stat = "smooth",
            method = "loess",
            size = 1) +
  scale_color_viridis_d(option= "magma") +
  labs(x = "Days since 100 patients reached",
       y = "Confirmed (log)") +
  guides(color = FALSE)

pdelaylog <- pdelay + scale_y_log10()

# The table
delaytab <-tableGrob(t(delays[,c('Country','delay')]),
                     rows = NULL,
                     theme = ttheme_minimal(base_size = 10))

# Construct the patchwork
(plin | plog)  /
  (pdelay | pdelaylog) / wrap_elements(delaytab) + 
  ggtitle("Difference with Italy in day of reaching 100 patients") +
  plot_layout(guides = 'collect',
              heights = c(2,2,1)) +
  plot_annotation(title = "Evolution of total confirmed cases in 8 countries",
                  caption = paste("Created by Joris Meys on",
                                  Sys.Date(),
                                  "\n Data obtained from Johns Hopkins CSSE:",
                                  "https://github.com/CSSEGISandData/COVID-19"))

# Save the figure
if(!dir.exists("Fig")) dir.create("Fig")
fname <- paste0("TrendConfirmed",Sys.Date(),".png")
ggsave(file.path("Fig",fname), width = 8, height = 8)
