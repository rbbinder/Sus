require(shiny)
require(shinydashboard)
require(raster)
require(ape)
require(spdep)
require(leaflet)
require(RColorBrewer)

#tabPanel("Title", ... elements to appear)


### Variables ##################################################################

var_list <- 
  list(
    "Tenant housing" = "TenantH",
    "Sublet rental" = "Subs",
    "Over 30 yrs old" = "Plus30",
    "Median Rent" = "MedRent",
    "Average Rent" = "AvRent",
    "Median morgage price" = "MedMort",
    "Average morgage price" = "AvMort",
    "Median property value" = "MedVal",
    "Average property value" = "AvVal",
    "Number of owners" = "Owner",
    "Owners with morgages" = "Wmortg",
    "Over 30yr old that own home" = "Plus30Own",
    "CTIR" = "CTIR",
    "Less than 30" = "Less30",
    "More than 30" = "More30",
    "Suitable housing" = "Suitable",
    "Non-suitable housing" = "NonSuit",
    "Income under 5k" = "Under_5k_proportion",
    "Income 5k - 10k" = "IN5k_10k_proportion",
    "Income 10k - 15k" = "IN10k_15k_proportion",
    "Income 15k - 20k" = "IN15k_proportion",
    "Income 20k - 25k" = "N20k_25k_proportion",
    "Income 25k - 30k" = "IN25k_30k_proportion",
    "Income 30k - 35k" = "IN30k_35k_proportion",
    "Income 35k - 40k" = "IN35k_40k_proportion",
    "Income 40k - 45k" = "IN40k_45k_proportion",
    "Income 45k - 50k" = "IN45k_50k_proportion",
    "Income 50k - 60k" = "IN50k_60k_proportion",
    "Income 60k - 70k" = "IN60k_70k_proportion",
    "Income 70k - 80k" = "IN70k_80k_proportion",
    "Income 80k - 90k" = "IN80K_90k_proportion",
    "Income 90k - 100k" = "IN90k_proportion",
    "Income over 100k" = "INOver100k_proportion",
    "Income 100k - 250k" = "IN100k_125_proportion",
    "Income 125k - 150k" = "IN125k_150_proportion",
    "Income 150k - 200k" = "IN150k_200_proportion",
    "Income over 200k" = "Over200k_proportion",
    "Proportion of non-immigrants" = "Non_Im_proportion",
    "Proportion of immigrants" =  "Imm_proportion",
    "Proportion of new immigrants" = "Imm_5year_proportion",
    "Drive to work" = "driver_proportion",
    "Passenger to work" = "passenger_proportion",
    "Public transit to work" = "Pubtrans_proportion",
    "Walk to work" = "Walked_proportion",
    "Bicycle to work" = "Bicycle_proportion",
    "Other transit mode to work" = "Other_proportion",
    "15 minutes to work" = "T_15_proportion",
    "15-30 minutes to work" = "B15_29_proportion",
    "30-45 minutes to work" = "B30_44_proportion",
    "0-60 minutes to work" = "O_60_proportion",
    "45-60 minutes to work" = "B_45_59_proportion",
    "Household income less than 40K" = "under_40K",
    "Household income greater than 40K" = "over_40K",
    "canALE index" = "ale_tranis")


### Rows #######################################################################

row_selector <- 
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:50%}"),
    column(width = 6, selectInput("data_for_plot_left", label=h3("Variable 1"), 
                                  selected = "ale_tranis", choices = var_list)),
    
    column(width = 6, selectInput("data_for_plot_right", label=h3("Variable 2"), 
                                  selected = "over_40k", choices = var_list)))

row_single_maps <- 
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    column(6, plotOutput("map1"), height=300), 
    column(6, plotOutput("map2"), height=300))

row_bivariate_map <-
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    column(12, h3("Bivariate Map: Variables 1 and 2"), plotOutput("map3"),
           height=600))

row_descriptive <-
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    # column(3, plotOutput("descript1"), height=200),
    column(3, plotOutput("hist1"), height=200),
    # column(3, plotOutput("descript2"), height=200),
    column(3, plotOutput("hist2"), height=200))

row_scatterplot <- 
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    column(12, h3("Bivariate Scatterplot: Variables 1 and 2"), plotOutput("scatterplot"),
           height=600))


### shinyUI ####################################################################

shinyUI(dashboardPage(
  skin="black", 
  dashboardHeader(title = "Bivariate Analysis: Sustainability Variables"),
  dashboardSidebar(disable=TRUE, 
                   sidebarMenu(disable=TRUE, 
                               menuItem("bivariate maps", tabName = "maps", 
                                        icon = icon("book")))),
  dashboardBody(tabItems(tabItem(tabName ="maps",
                                 row_selector,                    
                                 row_single_maps,
                                 row_descriptive,
                                 row_bivariate_map,
                                 row_scatterplot
                                 )))))








