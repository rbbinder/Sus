require(shiny)
require(shinydashboard)
require(raster)
require(ape)
require(spdep)
require(leaflet)
require(RColorBrewer)

#tabPanel("Title", ... elements to appear)

shinyUI(dashboardPage(skin="black", 
                       dashboardHeader(title = "Bivariate Analysis: Sustainability Variables"),
                       dashboardSidebar(
                         sidebarMenu(disable=TRUE,
                                     menuItem("Traits as binary", tabName = "maps", icon = icon("book"))
                         )
                       ),
                       dashboardBody(
                         mainPanel(tags$h4("This app works best in full screen.")),
                         tabItems( 
                           tabItem(tabName ="maps",
                                   fluidRow(
                                     tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                                     column(6, plotOutput("map1"), height=300), 
                                     column(6, plotOutput("map2"), height=300)),
                                   fluidRow(
                                     tags$style(type = "text/css", "html, body {width:100%;height:50%}"),
                                     column(width = 6, selectInput("data_for_plot_left", label=h3("Choose a variable"), choices = list(
                                       "Tenant housing" = "TenantH_quant3",
                                       "Sublet rental" = "Subs_quant3",
                                       "Over 30 yrs old" = "Plus30_quant3",
                                       "Median Rent" = "MedRent_quant3",
                                       "Average Rent" = "AvRent_quant3",
                                       "Median morgage price" = "MedMort_quant3",
                                       "Average morgage price" = "AvMort_quant3",
                                       "Median property value" = "MedVal_quant3",
                                       "Average property value" = "AvVal_quant3",
                                       "Number of owners" = "Owner_quant3",
                                       "Owners with morgages" = "Wmortg_quant3",
                                       "Over 30yr old that own home" = "Plus30Own_quant3",
                                       "CTIR" = "CTIR_quant3",
                                       "Less than 30" = "Less30_quant3",
                                       "More than 30" = "More30_quant3",
                                       "Suitable housing" = "Suitable_quant3",
                                       "Non-suitable housing" = "NonSuit_quant3",
                                       "Income under 5k" = "Under_5k_proportion_quant3",
                                       "Income 5k - 10k" = "IN5k_10k_proportion_quant3",
                                       "Income 10k - 15k" = "IN10k_15k_proportion_quant3",
                                       "Income 15k - 20k" = "IN15k_proportion_quant3",
                                       "Income 20k - 25k" = "N20k_25k_proportion_quant3",
                                       "Income 25k - 30k" = "IN25k_30k_proportion_quant3",
                                       "Income 30k - 35k" = "IN30k_35k_proportion_quant3",
                                       "Income 35k - 40k" = "IN35k_40k_proportion_quant3",
                                       "Income 40k - 45k" = "IN40k_45k_proportion_quant3",
                                       "Income 45k - 50k" = "IN45k_50k_proportion_quant3",
                                       "Income 50k - 60k" = "IN50k_60k_proportion_quant3",
                                       "Income 60k - 70k" = "IN60k_70k_proportion_quant3",
                                       "Income 70k - 80k" = "IN70k_80k_proportion_quant3",
                                       "Income 80k - 90k" = "IN80K_90k_proportion_quant3",
                                       "Income 90k - 100k" = "IN90k_proportion_quant3",
                                       "Income over 100k" = "INOver100k_proportion_quant3",
                                       "Income 100k - 250k" = "IN100k_125_proportion_quant3",
                                       "Income 125k - 150k" = "IN125k_150_proportion_quant3",
                                       "Income 150k - 200k" = "IN150k_200_proportion_quant3",
                                       "Income over 200k" = "Over200k_proportion_quant3",
                                       "Proportion of non-immigrants" = "Non_Im_proportion_quant3",
                                       "Proportion of immigrants" =  "Imm_proportion_quant3",
                                       "Proportion of new immigrants" = "Imm_5year_proportion_quant3",
                                       "Drive to work" = "driver_proportion_quant3",
                                       "Passenger to work" = "passenger_proportion_quant3",
                                       "Public transit to work" = "Pubtrans_proportion_quant3",
                                       "Walk to work" = "Walked_proportion_quant3",
                                       "Bicycle to work" = "Bicycle_proportion_quant3",
                                       "Other transit mode to work" = "Other_proportion_quant3",
                                       "15 minutes to work" = "T_15_proportion_quant3",
                                       "15-30 minutes to work" = "B15_29_proportion_quant3",
                                       "30-45 minutes to work" = "B30_44_proportion_quant3",
                                       "0-60 minutes to work" = "O_60_proportion_quant3",
                                       "45-60 minutes to work" = "B_45_59_proportion_quant3",
                                       "Household income less than 40K" = "under_40K_quant3",
                                       "Household income greater than 40K" = "over_40K_quant3",
                                       "canALE index" = "ale_tranis_quant3")))),

                                     column(width = 6, selectInput("data_for_plot_right", label=h3("Choose another variable"), choices = list(
                                       "Tenant housing" = "TenantH_quant3",
                                       "Sublet rental" = "Subs_quant3",
                                       "Over 30 yrs old" = "Plus30_quant3",
                                       "Median Rent" = "MedRent_quant3",
                                       "Average Rent" = "AvRent_quant3",
                                       "Median morgage price" = "MedMort_quant3",
                                       "Average morgage price" = "AvMort_quant3",
                                       "Median property value" = "MedVal_quant3",
                                       "Average property value" = "AvVal_quant3",
                                       "Number of owners" = "Owner_quant3",
                                       "Owners with morgages" = "Wmortg_quant3",
                                       "Over 30yr old that own home" = "Plus30Own_quant3",
                                       "CTIR" = "CTIR_quant3",
                                       "Less than 30" = "Less30_quant3",
                                       "More than 30" = "More30_quant3",
                                       "Suitable housing" = "Suitable_quant3",
                                       "Non-suitable housing" = "NonSuit_quant3",
                                       "Income under 5k" = "Under_5k_proportion_quant3",
                                       "Income 5k - 10k" = "IN5k_10k_proportion_quant3",
                                       "Income 10k - 15k" = "IN10k_15k_proportion_quant3",
                                       "Income 15k - 20k" = "IN15k_proportion_quant3",
                                       "Income 20k - 25k" = "N20k_25k_proportion_quant3",
                                       "Income 25k - 30k" = "IN25k_30k_proportion_quant3",
                                       "Income 30k - 35k" = "IN30k_35k_proportion_quant3",
                                       "Income 35k - 40k" = "IN35k_40k_proportion_quant3",
                                       "Income 40k - 45k" = "IN40k_45k_proportion_quant3",
                                       "Income 45k - 50k" = "IN45k_50k_proportion_quant3",
                                       "Income 50k - 60k" = "IN50k_60k_proportion_quant3",
                                       "Income 60k - 70k" = "IN60k_70k_proportion_quant3",
                                       "Income 70k - 80k" = "IN70k_80k_proportion_quant3",
                                       "Income 80k - 90k" = "IN80K_90k_proportion_quant3",
                                       "Income 90k - 100k" = "IN90k_proportion_quant3",
                                       "Income over 100k" = "INOver100k_proportion_quant3",
                                       "Income 100k - 250k" = "IN100k_125_proportion_quant3",
                                       "Income 125k - 150k" = "IN125k_150_proportion_quant3",
                                       "Income 150k - 200k" = "IN150k_200_proportion_quant3",
                                       "Income over 200k" = "Over200k_proportion_quant3",
                                       "Proportion of non-immigrants" = "Non_Im_proportion_quant3",
                                       "Proportion of immigrants" =  "Imm_proportion_quant3",
                                       "Proportion of new immigrants" = "Imm_5year_proportion_quant3",
                                       "Drive to work" = "driver_proportion_quant3",
                                       "Passenger to work" = "passenger_proportion_quant3",
                                       "Public transit to work" = "Pubtrans_proportion_quant3",
                                       "Walk to work" = "Walked_proportion_quant3",
                                       "Bicycle to work" = "Bicycle_proportion_quant3",
                                       "Other transit mode to work" = "Other_proportion_quant3",
                                       "15 minutes to work" = "T_15_proportion_quant3",
                                       "15-30 minutes to work" = "B15_29_proportion_quant3",
                                       "30-45 minutes to work" = "B30_44_proportion_quant3",
                                       "0-60 minutes to work" = "O_60_proportion_quant3",
                                       "45-60 minutes to work" = "B_45_59_proportion_quant3",
                                       "Household income less than 40K" = "under_40K_quant3",
                                       "Household income greater than 40K" = "over_40K_quant3",
                                       "canALE index" = "ale_tranis_quant3")))
                                   # fluidRow(
                                   #   tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                                   #   column(6, plotOutput("map3"), height=300)

                                     )))))








