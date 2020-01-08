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
    "",
    "Liveable environments" = list("canALE index" = "ale_tranis"),
    "Housing" = list("Tenant-occupied (%)" = "tenant_prop",
                     "Median rent" = "MedRent",
                     "Median mortgage" = "MedMort",
                     "Median property value" = "MedVal",
                     "Suitable housing (%)" = "suitable_prop"
    ),
    "Income" = list("Income under $50k (%)" = "income_50_prop",
                    "Income between $50k-$100k (%)" = "income_100_prop",
                    "Income above $100k (%)" = "income_high_prop"
    ),
    "Immigration" = list("Immigrants (%)" =  "Imm_proportion",
                         "New immigrants (%)" = "Imm_5year_proportion"
    ),
    "Transportation" = list("Drive to work (%)" = "driver_proportion",
                            "Passenger to work (%)" = "passenger_proportion",
                            "Public transit to work (%)" = "Pubtrans_proportion",
                            "Walk to work (%)" = "Walked_proportion",
                            "Bicycle to work (%)" = "Bicycle_proportion",
                            "Other mode to work (%)" = "Other_proportion",
                            "15 minutes to work (%)" = "T_15_proportion",
                            "15-30 minutes to work (%)" = "B15_29_proportion",
                            "30-45 minutes to work (%)" = "B30_44_proportion",
                            "45-60 minutes to work" = "B_45_59_proportion"
    )
  )


### Rows #######################################################################

row_selector <- 
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:50%}"),
    column(width = 6, selectInput("data_for_plot_left", label=h3("Variable 1"),
                                  choices = var_list)),
    
    column(width = 6, selectInput("data_for_plot_right", label=h3("Variable 2"), 
                                  choices = var_list)))

row_single_maps <- 
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    column(6, plotOutput("map1"), height = 300), 
    column(6, plotOutput("map2"), height = 300))

row_bivariate_map <-
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    h3("Bivariate map"),
    column(8, plotOutput("map3", height = 800)),
    # column(8, leafletOutput("map3", height = 800)),
    column(4, plotOutput("scatterplot", height = 800))
  )

row_descriptive <-
  fluidRow(
    tags$style(type = "text/css", "html, body {width:100%;height:50%}"),
    column(2, tableOutput("descript1")),
    column(4, plotOutput("hist1", height = 200)),
    column(2, tableOutput("descript2")),
    column(4, plotOutput("hist2", height = 200))
  )


### shinyUI ####################################################################

ui <- 
  dashboardPage(
    skin="black", 
    dashboardHeader(title = "Bivariate Analysis: Sustainability Variables"),
    dashboardSidebar(disable=TRUE, 
                     sidebarMenu(disable=TRUE, 
                                 menuItem("bivariate maps", tabName = "maps", 
                                          icon = icon("book")))),
    dashboardBody(tabItems(tabItem(tabName ="maps",
                                   row_selector,                    
                                   row_descriptive,
                                   row_single_maps,
                                   row_bivariate_map
    ))))








