require(shiny)
require(shinydashboard)
require(raster)
require(ape)
require(spdep)
require(leaflet)
require(RColorBrewer)
require(tidyverse)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
## import data_for_plot file & duplicate

load(file = "data/data_for_plot.Rdata")

data_for_plot2 <- data_for_plot

## save colors
  bivariate_color_scale <- tibble(
    "3 - 3" = "#3F2949", # high inequality, high income
    "2 - 3" = "#435786",
    "1 - 3" = "#4885C1", # low inequality, high income
    "3 - 2" = "#77324C",
    "2 - 2" = "#806A8A", # medium inequality, medium income
    "1 - 2" = "#89A1C8",
    "3 - 1" = "#AE3A4E", # high inequality, low income
    "2 - 1" = "#BC7C8F",
    "1 - 1" = "#CABED0" # low inequality, low income
  ) %>%
    gather("group", "fill")

  color_scale <- tibble(
    6 = "#AE3A4E",
    5 = "#BC7C8F", # medium inequality, medium income
    4 = "#CABED0",
    3 = "#4885C1", # high inequality, low income
    2 = "#89A1C8",
    1 = "#CABED0" # low inequality, low income
  ) %>%
    gather("group", "fill")

   #color_scale <- cbind(color_scale[,1], color_scale) %>% 
     #as.numeric(color_scale)
   # names(color_scale) <- c("pers","haps", "fill_color")
   # color_scale$pers <- as.numeric(color_scale$pers)
   # color_scale$haps <- as.numeric(color_scale$haps)

  colors <- color_scale$fill

 # g <- grid::circleGrob(gp = grid::gpar(fill = "white", col="white"))

# ## maps output

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


  output$map1 <- renderPlot({

    data_for_plot_left <- data_for_plot %>%
      dplyr::select(input$data_for_plot_left)

    data_for_plot_left <- data_for_plot_left %>%
      mutate(
        group = paste(
          as.numeric(input$data_for_plot_left) 
        ) %>% 
          left_join(color_scale, by = "group")
      )

    ggplot(data_for_plot_left) +
      geom_sf(
        aes(
          fill = as.factor(input$data_for_plot_left)
        ),
        # use thin white stroke for municipalities
        color = "white",
        size = 0.01
      ) +
      scale_fill_manual(values=rev(colors[c(1:3)]))+
      theme_map()

  })


  output$map2 <- renderPlot({
    data_for_plot_right <- data_for_plot %>%
      dplyr::select(input$data_for_plot_right)

    data_for_plot_right <- data_for_plot_right %>%
      mutate(
        group = paste(
          as.numeric(input$data_for_plot_right)
        )
      ) %>%
      left_join(color_scale, by = "group")

    ggplot(data_for_plot_right) +
      geom_sf(
        aes(
          fill = as.factor(data_for_plot_right)
        ),
        # use thin white stroke for municipalities
        color = "white",
        size = 0.01
      ) +
      scale_fill_manual(values=rev(colors[c(1:3)]))+
      theme_map()

  })
  
  # output$map3 <- renderPlot({
  #   plot(1,1,col="red")
  #   # data_for_plot_bivariate <- data_for_plot %>% 
  #   #   dplyr::select(input$data_for_plot_left, input$data_for_plot_right)  
  #   # 
  #   # data_for_plot_bivariate <- data_for_plot_bivariate %>%
  #   #   mutate(
  #   #     group = paste(
  #   #       as.numeric(input$data_for_plot_left), "-",
  #   #       as.numeric(input$data_for_plot_right)
  #   #     )
  #   #   ) %>%
  #   #   left_join(bivariate_color_scale, by = "group")
  #   # 
  #   # ggplot(data_for_plot_bivariate) +
  #   #   geom_sf(
  #   #     aes(
  #   #       fill = as.factor(data_for_plot_bivariate)
  #   #     ),
  #   #     # use thin white stroke for municipalities
  #   #     color = "white",
  #   #     size = 0.01
  #   #   ) +
  #   #   scale_fill_manual(values=rev(colors[c(1:3)]))+ 
  #   #   theme_map() 
  #   
  # })
  
})
  
  