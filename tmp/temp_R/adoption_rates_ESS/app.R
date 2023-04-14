#
# Created on: April 11, 2023


# load packages ----
library(shiny)
library(tidyverse)
library(scales)
# library(plotly)

# source scripts ----
source("helpers/data_prep.R")
source("helpers/ggplot_theme_Publication-2.R")


# next steps: 
# - add psnp at EA level
# - add maize DNA
# 


# Define UI for application that draws a histogram
ui <- fluidPage(

  titlePanel("Comparing adoption rates of CGIAR across waves in the ESPS"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create bar graphs comparing adoption rates from the Ethiopian 
               Socio-economic Panle Survey."),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = labels_choices,
                  multiple = TRUE,
                  selected = NULL),
      
      radioButtons("type",
                   label = "Choose sample type to display",
                   choices = list(
                     "All households/EA", 
                     "Panel households/EA"),
                   selected = "All households/EA")
     
    ),
    
    mainPanel(plotOutput("plot"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$plot <- renderPlot({
      
      adoption_rates %>% 
        filter(
          label %in% input$var, 
          sample == input$type
          ) %>% 
        ggplot(aes(region, mean, fill = wave)) +
        geom_col(position = "dodge") +
        # geom_text(aes(label = paste0( round(mean_chickpea*100, 1), "%", "\n(", nobs, ")" ) ),
        #           position = position_dodge(width = 1),
        #           vjust = -.35, size = 2.5) +
        scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
        scale_y_continuous(labels = percent_format()) +
        expand_limits(y = .15) +
        facet_grid(label ~ level) +
        scale_fill_Publication() + 
        theme_Publication() +
        theme(
          legend.position = "top",
          legend.margin = margin(t = -0.4, unit = "cm"),
          axis.title = element_text(size = 12.5),
          plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
        ) +
        labs(x = "", y = "Percent",
             title = "Add title",
             fill = "",
             caption = "Percent are weighted sample means.
       Number of responding households in parenthesis")
      
      
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
