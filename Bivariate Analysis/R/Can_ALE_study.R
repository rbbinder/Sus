## Can ALE data study


## Load libraries

library(tidyverse) # ggplot2, dplyr, tidyr, readr, purrr, tibble
library(magrittr) # pipes

library(sf) # spatial data handling
library(raster) # raster handling (needed for relief)
library(viridis) # viridis color scale
library(cowplot) 

library(tidyverse) 
library(cancensus)

library(sf)

install.packages("devtools")
library(devtools)

install_github("easyGgplot2", "kassambara")
library(easyGgplot2)


## Import the data

CanALE_space <- st_read(
  "/Users/Robin/Dropbox/SUS MSSI/Bivariate Analysis/data/Mtl_DA_CANALE/Mtl_DA_CANALE.shp")

## Basic histograms

hist(CanALE_space$Bicycle/CanALE_space$Mode)
hist(CanALE_space$ale_index, add=T)

plot(CanALE_space$AvVal, CanALE_space$ale_index, type='h', lwd=5) 

## Corrleation
