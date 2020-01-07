require(shiny)
require(shinydashboard)
require(raster)
require(ape)
require(spdep)
require(leaflet)
require(tidyverse)
require(ggplot2)



### Colours ####################################################################

colour_scale <- 
  # Low income
  c("#CABED0", "#89A1C8", "#4885C1", 
    # Medium income
    "#BC7C8F", "#806A8A", "#435786", 
    # High income
    "#AE3A4E", "#77324C", "#3F2949")


### Theme function #############################################################

theme_map <- function(...) {
  default_background_colour <- "transparent"
  default_font_colour <- "black"
  default_font_family <- "Helvetica"
  
  theme_minimal() +
    theme(
      text = element_text(family = default_font_family,
                          colour = default_font_colour),
      # remove all axes
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      # add a subtle grid
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      # background colours
      plot.background = element_rect(fill = default_background_colour,
                                     colour = NA),
      panel.background = element_rect(fill = default_background_colour,
                                      colour = NA),
      legend.background = element_rect(fill = default_background_colour,
                                       colour = NA),
      legend.position = "none",
      # borders and margins
      plot.margin = unit(c(.5, .5, .2, .5), "cm"),
      panel.border = element_blank(),
      panel.spacing = unit(c(-.1, 0.2, .2, 0.2), "cm"),
      # titles
      legend.title = element_text(size = 11),
      legend.text = element_text(size = 22, hjust = 0,
                                 colour = default_font_colour),
      plot.title = element_text(size = 15, hjust = 0.5,
                                colour = default_font_colour),
      plot.subtitle = element_text(size = 10, hjust = 0.5,
                                   colour = default_font_colour,
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
                                  colour = "#939184"),
      ...
    )
}


### Simple map function ########################################################

map_function <- function(data, variable_name, colours) {
  
  ggplot(data) +
    geom_sf(aes(fill = as.factor(ntile({{ variable_name }}, 3))), 
            colour = "transparent", size = 0) +
    scale_fill_manual(values = colours, na.value = "grey50") +
    theme_map()
}


### shinyServer ################################################################

shinyServer(function(input, output, session) {
  
  ## import data_for_plot file & duplicate
  load(file = "data/data_for_plot.Rdata")
  
  ## maps output

  output$map1 <- renderPlot({
    
    # Get input data frame
    data_for_plot %>%
      select(input$data_for_plot_left) %>% 
      set_names(c("left_variable", "geometry")) %>% 
      # Send data frame to ggplot
      map_function(left_variable, c("grey80", colour_scale[c(4,7)]))
    })
  
  output$map2 <- renderPlot({
    data_for_plot %>%
      select(input$data_for_plot_right) %>% 
      set_names(c("right_variable", "geometry")) %>% 
      map_function(right_variable, c("grey80", colour_scale[c(2,3)]))
  })
  
  output$map3 <- renderPlot({

    data_for_map <-
      data_for_plot %>%
      select(input$data_for_plot_left, input$data_for_plot_right)

    # Case for two columns (including geometry)
    if (length(data_for_map) == 2) {
      NULL
      
      # Case for three columns (including geometry)
      } else {
        
        data_for_map %>%
          set_names(c("left_variable", "right_variable", "geometry")) %>%
          filter(!is.na(left_variable), !is.na(right_variable)) %>% 
          mutate(left_variable = ntile(left_variable, 3),
                 right_variable = ntile(right_variable, 3),
                 group = paste(left_variable, right_variable, sep = " - ")) %>% 
          ggplot() +
          geom_sf(aes(fill = as.factor(group)), colour = "transparent", size = 0) +
          scale_fill_manual(values = colour_scale, na.value = "grey50") +
          theme_map()
        
        }
  })
  
  output$hist1 <- renderPlot({
    
    data_for_hist_left <- data_for_plot %>%
      select(input$data_for_plot_left) %>% 
      set_names(c("left_variable", "geometry"))
    
    data_for_hist_left %>% 
      filter(data_for_hist_left$left_variable < 
               quantile(data_for_hist_left$left_variable, 0.99)) %>% 
      ggplot() +
      geom_histogram(aes(left_variable),
                     fill = "#AE3A4E") +
      # xlim(NA, quantile(data_for_hist_left$left_variable, 0.992)) +
      # ylim(NA, quantile(data_for_hist_left$left_variable, 0.992)) +
      theme_minimal() +
      theme(axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            panel.background = element_rect(fill = "white", colour = "transparent"),
            panel.grid.minor = element_blank(),
            panel.grid.major = element_blank()
      )

  })
  

  output$hist2 <- renderPlot({
    
      data_for_hist_right <- data_for_plot %>%
      select(input$data_for_plot_right) %>% 
      set_names(c("right_variable", "geometry")) 
      
      data_for_hist_right %>% 
      filter(data_for_hist_right$right_variable < 
               quantile(data_for_hist_right$right_variable, 0.99)) %>% 
      ggplot() +
      geom_histogram(aes(right_variable),
                     fill = "#4885C1") +
      # xlim(NA, quantile(data_for_hist_right$right_variable, 0.992)) +
      # ylim(NA, quantile(data_for_hist_right$right_variable, 0.992)) +
      theme_minimal() +
      theme(axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            panel.background = element_rect(fill = "white", colour = "transparent"),
            panel.grid.minor = element_blank(),
            panel.grid.major = element_blank()
      )
  
})
  
  output$descript1 <- renderTable({

      data_for_stats_left <-
        data_for_plot %>%
        select(input$data_for_plot_left) %>%
        set_names(c("left_variable", "geometry"))

      tibble(
        "Descriptive" = c("Min", "Max", "Median", "Mean", "Sd"),
        "Value" = c(min(data_for_stats_left$left_variable, na.rm = TRUE), 
                    max(data_for_stats_left$left_variable, na.rm = TRUE),
                    median(data_for_stats_left$left_variable),
                    mean(data_for_stats_left$left_variable),
                    sd(data_for_stats_left$left_variable)) %>%
          as.data.frame())

  })

  output$descript2 <- renderTable({
    
    data_for_stats_right <-
      data_for_plot %>%
      select(input$data_for_plot_right) %>%
      set_names(c("right_variable", "geometry"))
    
    tibble(
      "Descriptive" = c("Min", "Max", "Median", "Mean", "Sd"),
      "Value" = c(min(data_for_stats_right$right_variable, na.rm = TRUE), 
                  max(data_for_stats_right$right_variable, na.rm = TRUE),
                  median(data_for_stats_right$right_variable),
                  mean(data_for_stats_right$right_variable),
                  sd(data_for_stats_right$right_variable)) %>%
        as.data.frame())
    
  })

  output$scatterplot <- renderPlot({
    data_for_map <-
    data_for_plot %>%
    select(input$data_for_plot_left, input$data_for_plot_right)
  
  # Case for two columns (including geometry)
  if (length(data_for_map) == 2) {
    NULL
    
    # Case for three columns (including geometry)
  } else {
    
    data_for_map %>%
      set_names(c("left_variable", "right_variable", "geometry")) %>%
      ggplot() +
      geom_point(aes(left_variable, right_variable)) +
      theme_minimal() +
      theme(panel.background = element_rect(fill = "white", colour = "transparent"),
            panel.grid.minor = element_blank(),
            panel.grid.major = element_blank()
      )
    
  }
    
  })  
  
}) 
    
