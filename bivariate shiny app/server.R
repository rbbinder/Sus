#### SHINY BIVARIATE MAPPING APP ###############################################

### Load libraries #############################################################

require(shiny)
require(shinydashboard)
require(ape)
require(spdep)
require(leaflet)
require(tidyverse)


### Colours ####################################################################

colour_scale <- 
  c("#CABED0", "#89A1C8", "#4885C1", 
    "#BC7C8F", "#806A8A", "#435786", 
    "#AE3A4E", "#77324C", "#3F2949")

colour_left <- c("grey80", colour_scale[c(4,7)])

colour_right <- c("grey80", colour_scale[c(2,3)])


### Theme functions ############################################################

theme_map <- function(...) {
  default_bg <- "transparent"
  default_font_col <- "black"
  default_font <- "Helvetica"
  
  theme_minimal() +
    theme(
      text = element_text(family = default_font, colour = default_font_col),
      # remove all axes
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      # add a subtle grid
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      # background colours
      plot.background = element_rect(fill = default_bg, colour = NA),
      panel.background = element_rect(fill = default_bg, colour = NA),
      legend.background = element_rect(fill = default_bg, colour = NA),
      legend.position = "none",
      # borders and margins
      plot.margin = unit(c(.5, .5, .2, .5), "cm"),
      panel.border = element_blank(),
      panel.spacing = unit(c(-.1, 0.2, .2, 0.2), "cm"),
      # titles
      legend.title = element_text(size = 11),
      legend.text = element_text(size = 22, hjust = 0, colour = default_font_col),
      plot.title = element_text(size = 15, hjust = 0.5, colour = default_font_col),
      plot.subtitle = element_text(size = 10, hjust = 0.5, 
                                   colour = default_font_col,
                                   margin = margin(b = -0.1, t = -0.1,
                                                   l = 2, unit = "cm")),
      # captions
      plot.caption = element_text(size = 7, hjust = .5,
                                  margin = margin(t = 0.2, b = 0, unit = "cm"),
                                  colour = "#939184"),
      ...
    )
}

theme_histogram <- function(...) {
  theme_minimal() +
    theme(legend.position = "none", 
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          panel.background = element_rect(fill = "white", 
                                          colour = "transparent"),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          ...
          )
}


### Univariate map function ####################################################

map_function <- function(data, variable_name, colours) {
  
  ggplot(data) +
    geom_sf(aes(fill = as.factor(ntile({{ variable_name }}, 3))), 
            colour = "transparent", size = 0) +
    scale_fill_manual(values = colours, na.value = "grey50") +
    theme_map()
}


### Leaflet map colour function ################################################

pal <- colorFactor(colour_scale, 
                   levels = c("1 - 1", "1 - 2", "1 - 3", 
                              "2 - 1", "2 - 2", "2 - 3",
                              "3 - 1", "3 - 2", "3 - 3"),
                   na.color = "grey50")


### Server #####################################################################

server <- function(input, output, session) {
  
  ## Import data_for_plot file
  load(file = "data/data_for_plot.Rdata")
  
  data_for_plot <- 
    data_for_plot %>% 
    as_tibble() %>% 
    st_as_sf() %>% 
    select(-(PRUID:z_poi), -ale_class, -DA_1, -OID1, -UID, -MHI, 
           -(Under_5k:Over200k), -(Non_Im:B_45_59),
           -(TenantH_quant3:ale_tranis_quant3),
           -transit, -z_transit) %>% 
    mutate(tenant_prop = TenantH / Households) %>% 
    select(-TenantH, -Subs, -Plus30, -AvRent, -AvMort, -AvVal, -Owner, -Wmortg,
           -Plus30Own, -CTIR, -Less30, -More30) %>% 
    mutate(suitable_prop = Suitable / Househol_1) %>% 
    select(-Suitable, -NonSuit) %>% 
    mutate(income_50_prop = 
             Under_5k_proportion + IN5k_10k_proportion +
             IN10k_15k_proportion + IN15k_proportion + IN20k_25k_proportion +
             IN25k_30k_proportion + IN30k_35k_proportion + IN35k_40k_proportion +
             IN40k_45k_proportion + IN45k_50k_proportion) %>% 
    select(-(Under_5k_proportion:IN45k_50k_proportion)) %>% 
    mutate(income_100_prop = 
             IN50k_60k_proportion + IN60k_70k_proportion +
             IN70k_80k_proportion + IN80k_90k_proportion + 
             IN90k_proportion) %>% 
    select(-(IN50k_60k_proportion:IN90k_proportion)) %>% 
    rename(income_high_prop = INOver100k_proportion) %>% 
    select(-(IN100k_125_proportion:Over200k_proportion))
  
  
  wait <- reactive({
    if (input$data_for_plot_left == "" | input$data_for_plot_right == "") {
      
      wait <- TRUE
      
    } else {
      
      wait <- FALSE
  }})
  
  ## Create reactive version of table
  data_processed <- 
    reactive({
    
        data_processed <- 
          data_for_plot %>% 
          select(input$data_for_plot_left, input$data_for_plot_right) %>% 
          st_transform(4326)
        
        
        ## If the two inputs are the same, duplicate it
        
        if (length(data_processed) == 2) {
          data_processed <- 
            data_processed %>% 
            set_names(c("left_variable", "geometry")) %>% 
            mutate(right_variable = left_variable)
        } else {
          data_processed <- 
            data_processed %>% 
            set_names(c("left_variable", "right_variable", "geometry"))
        }
        
        ## Add tertiles
        
        data_processed <- 
          data_processed %>% 
          mutate(group = paste(ntile(left_variable, 3), 
                               ntile(right_variable, 3), 
                               sep = " - "),
                 group = factor(group, levels = c("1 - 1", "1 - 2", "1 - 3",
                                                  "2 - 1", "2 - 2", "2 - 3",
                                                  "3 - 1", "3 - 2", "3 - 3")))  
        
        data_processed
      
  })
    
  
  
  ## Map outputs

  output$map1 <- renderPlot({
    
    if (wait()){
      NULL
    } else {
      data_processed() %>%
        map_function(left_variable, colour_left)  
    }
    
    
    })
  
  output$map2 <- renderPlot({
    
    if (wait()){
      NULL
    } else {
      data_processed() %>%
        map_function(right_variable, colour_right)
    }
    
  })
  
  # output$map3 <- renderPlot({
  #   
  #   data_processed() %>%
  #     ggplot() +
  #     geom_sf(aes(fill = group), colour = "transparent", size = 0) +
  #     scale_fill_manual(values = colour_scale, na.value = "grey50") +
  #     theme_map()
  #       
  # }, height = 800)
  
  output$map3 <- renderLeaflet({
    
    if (wait()){
      NULL
    } else {
      
      # Add leaflet output - this without the proxy should produce the blank basemap
      leaflet() %>% 
        addTiles() %>% 
        setView(-73.70715, 45.572605, zoom = 11) %>%
        # fitBounds(-74.03534, 45.34213, -73.37896, 45.80308) %>% 
        addProviderTiles(providers$CartoDB.Positron) %>% 
        addPolygons(data = data_processed(),
                    fillColor = ~pal(data_processed()$group),
                    fillOpacity = 0.95,
                    color = "white",
                    opacity = 0,
                    weight = 0)
    }

  })
  
  output$hist1 <- renderPlot({
    
    if (wait()){
      NULL
    } else {
      
      data_processed() %>% 
        filter(left_variable < 
                 quantile(data_processed()$left_variable, 0.99, na.rm = TRUE)) %>% 
        ggplot() +
        geom_histogram(aes(left_variable,
                           fill = as.factor(ntile(left_variable, 3)))) +
        scale_x_continuous(name = input$data_for_plot_left) +
        scale_fill_manual(values = colour_left, na.value = "grey50") +
        theme_histogram()
    }
    
  }, height = 200)
  
  output$hist2 <- renderPlot({
    
    if (wait()){
      NULL
    } else {
      data_processed() %>% 
        filter(right_variable < quantile(data_processed()$right_variable, 0.99,
                                         na.rm = TRUE)) %>% 
        ggplot() +
        geom_histogram(aes(right_variable, 
                           fill = as.factor(ntile(right_variable, 3)))) +
        scale_x_continuous(name = input$data_for_plot_right) +
        scale_fill_manual(values = colour_right, na.value = "grey50") +
        theme_histogram()
    }
    
    
}, height = 200)
  
  output$descript1 <- renderTable({

    if (wait()){
      NULL
    } else {
      tibble(
        "Descriptive" = c(
          "Minimum", "Maximum", "Median", "Mean", "Standard deviation"),
        "Value" = c(min(data_processed()$left_variable, na.rm = TRUE), 
                    max(data_processed()$left_variable, na.rm = TRUE),
                    median(data_processed()$left_variable, na.rm = TRUE),
                    mean(data_processed()$left_variable, na.rm = TRUE),
                    sd(data_processed()$left_variable, na.rm = TRUE)) %>%
          as.data.frame())
    }
      
  })

  output$descript2 <- renderTable({
    
    if (wait()){
      NULL
    } else {
      tibble(
        "Descriptive" = c(
          "Minimum", "Maximum", "Median", "Mean", "Standard deviation"),
        "Value" = c(min(data_processed()$right_variable, na.rm = TRUE), 
                    max(data_processed()$right_variable, na.rm = TRUE),
                    median(data_processed()$right_variable, na.rm = TRUE),
                    mean(data_processed()$right_variable, na.rm = TRUE),
                    sd(data_processed()$right_variable, na.rm = TRUE)) %>%
          as.data.frame()) 
    }
    
  })

  output$scatterplot <- renderPlot({
    
    if (wait()){
      NULL
    } else {
      
      data_processed() %>% 
        ggplot() +
        geom_point(aes(left_variable, right_variable, colour = group)) +
        geom_smooth(aes(left_variable, right_variable), colour = "grey50", 
                    se = FALSE) +
        scale_x_continuous(name = input$data_for_plot_left) +
        scale_y_continuous(name = input$data_for_plot_right) +
        scale_colour_manual(values = colour_scale, na.value = "grey50") +
        theme_minimal() +
        theme(legend.position = "none", 
              panel.background = element_rect(fill = "white", 
                                              colour = "transparent"),
              panel.grid.minor = element_blank(),
              panel.grid.major = element_blank()
        )
    }
   

  })  
  
}


