##1. Load libraries
library(tidyverse)
library(magrittr)
library(png)
library(sf)
library(raster)
library(viridis)
library(cowplot)
library(shiny)

## 2. Import CanALE data

CanALE_space <- st_read(
  "data/Mtl_DA_CANALE/Mtl_DA_CANALE.shp")
#plot(CanALE_space)

## 3. Create columns needed for analysis

CanALE_space_proportions <- CanALE_space %>%  
  mutate_at(
    c("Under_5k", "IN5k_10k", "IN10k_15k", "IN15k",  "IN20k_25k",  "IN25k_30k",  "IN30k_35k", 
      "IN35k_40k",  "IN40k_45k",  "IN45k_50k",  "IN50k_60k", "IN60k_70k",  "IN70k_80k",  "IN80k_90k", 
      "IN90k", "INOver100k", "IN100k_125", "IN125k_150", "IN150k_200", "Over200k"),
    funs(proportion = ./Households)
  )  %>%  
  mutate_at(
    c("Non_Im", "Imm", "Imm_5year"),
    funs(proportion = ./Pop)
  ) %>% 
  mutate_at(
    c("driver", "passenger", "Pubtrans", "Walked", "Bicycle", "Other"),
    funs(proportion = ./Mode)
  ) %>%  
  mutate_at(
    c("T_15", "B15_29", "B30_44", "O_60", "B_45_59"),
    funs(proportion = ./Time)
  ) 


head(CanALE_space_proportions)

## 4. Aggregate data ->  There seems to be a problem with the counts here. 
#                     Why does sum_under_and_over_40 exceed 1
CanALE_space_proportions_aggregate <- CanALE_space_proportions %>%
  mutate (under_40K = 
            c(Under_5k + 
                IN5k_10k +
                IN10k_15k +
                IN15k +
                IN20k_25k +
                IN25k_30k +
                IN30k_35k +
                IN35k_40k) /
            Households) %>%
  mutate (over_40K =  
            c(IN40k_45k +
                IN45k_50k + 
                IN50k_60k +
                IN60k_70k +
                IN70k_80k +
                IN80k_90k +
                IN90k +
                INOver100k +
                IN100k_125 +
                IN125k_150 +
                IN150k_200 +
                Over200k)/
            Households
  ) %>%
  mutate(sum_under_and_over_40 = under_40K + over_40K)

colnames(CanALE_space_proportions_aggregate)

plot(CanALE_space_proportions_aggregate$sum_under_and_over_40) ## numbers need to be checked

## 5. extract quantiles
quant_list <- c("TenantH"    ,           "Subs"       ,           "Plus30"      ,          
                "MedRent"  , "AvRent"              ,  "MedMort"        ,       "AvMort"      ,          "MedVal", "AvVal",         "Owner"      ,           "Wmortg"       ,         "Plus30Own"            ,"CTIR"    ,           
                "Less30"        ,        "More30"  ,              "Househol_1"  ,
                "Suitable"     ,         "NonSuit","Under_5k_proportion" , "IN5k_10k_proportion" ,  "IN10k_15k_proportion",  "IN15k_proportion" ,     "IN20k_25k_proportion", "IN25k_30k_proportion" , "IN30k_35k_proportion"  ,"IN35k_40k_proportion" , "IN40k_45k_proportion", "IN45k_50k_proportion" , "IN50k_60k_proportion" , "IN60k_70k_proportion" , "IN70k_80k_proportion" , "IN80k_90k_proportion",  "IN90k_proportion"  ,    "INOver100k_proportion", "IN100k_125_proportion" ,"IN125k_150_proportion", "IN150k_200_proportion" ,"Over200k_proportion" ,  "Non_Im_proportion" ,"Imm_proportion"   ,     "Imm_5year_proportion" , "driver_proportion"  ,   "passenger_proportion" , "Pubtrans_proportion" ,  "Walked_proportion" ,    "Bicycle_proportion" ,   "Other_proportion" , "T_15_proportion"   ,    "B15_29_proportion" ,    "B30_44_proportion" ,    "O_60_proportion"  ,    "B_45_59_proportion" ,   "under_40K"    ,         "over_40K", "ale_tranis")


CanALE_space_proportions_aggregate_quantile <- 
  CanALE_space_proportions_aggregate %>% 
  mutate_at(quant_list,
            funs(quant3 = ntile(.,3))
  ) 

CanALE_space_proportions_aggregate_quantile

## 6. Create data_for_plot
data_for_plot <- 
  st_intersection(CanALE_space_proportions_aggregate_quantile, 
                                 st_buffer(st_centroid(st_union(CanALE_space_proportions_aggregate_quantile)), 26000))
names(data_for_plot)

save(data_for_plot, file = "data/data_for_plot.Rdata")

## 7. mapping

default_background_color <- "transparent"
default_font_color <- "black"
default_font_family <- "Helvetica"

theme_map <- function(...) {
  default_background_color <- "transparent"
  default_font_color <- "black"
  default_font_family <- "Helvetica"
  
  theme_minimal() +
    theme(
      text = element_text(family = default_font_family,
                          color = default_font_color),
      # remove all axes
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      # add a subtle grid
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      # background colors
      plot.background = element_rect(fill = default_background_color,
                                     color = NA),
      panel.background = element_rect(fill = default_background_color,
                                      color = NA),
      legend.background = element_rect(fill = default_background_color,
                                       color = NA),
      legend.position = "none",
      # borders and margins
      plot.margin = unit(c(.5, .5, .2, .5), "cm"),
      panel.border = element_blank(),
      panel.spacing = unit(c(-.1, 0.2, .2, 0.2), "cm"),
      # titles
      legend.title = element_text(size = 11),
      legend.text = element_text(size = 22, hjust = 0,
                                 color = default_font_color),
      plot.title = element_text(size = 15, hjust = 0.5,
                                color = default_font_color),
      plot.subtitle = element_text(size = 10, hjust = 0.5,
                                   color = default_font_color,
                                   margin = margin(b = -0.1,
                                                   t = -0.1,
                                                   l = 2,
                                                   unit = "cm"),
                                   debug = F),
      # captions
      plot.caption = element_text(size = 7,
                                  hjust = .5,
                                  margin = margin(t = 0.2,
                                                  b = 0,
                                                  unit = "cm"),
                                  color = "#939184"),
      ...
    )
}




