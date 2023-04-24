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
# - a button to show numbers/percents
# - facets?


# Define UI for application that draws a histogram
ui <- fluidPage(

  titlePanel("Comparing adoption rates of CGIAR innovations across waves in the ESPS"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create bar graphs comparing adoption rates from the Ethiopian 
               Socio-economic Panle Survey (ESPS)."),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = labels_choices,
                  multiple = FALSE,
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
  
  filteredData <- reactive({
    adoption_rates %>% 
      filter(
        label %in% input$var, 
        sample == input$type
      )
  })
  
  maxGrid <- reactive({
    filteredData() %>% slice_max(mean) %>% pull(mean)
  })
  
  facetLabs <- reactive({ 
    if_else(
    input$type == "All households/EA",
    c("Household" = "All households", 
                  "EA" = "All EA"),
    c("Household" = "Household - panel sample", 
                  "EA" = "EA - panel sample")
    ) 
  })
    
  

    output$plot <- renderPlot({
      
      filteredData() %>% 
        ggplot(aes(region, mean, fill = wave)) +
        geom_col(position = "dodge") +
        geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
                  position = position_dodge(width = 1),
                  vjust = -.35, size = 3) +
        scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
        scale_y_continuous(labels = percent_format()) +
        expand_limits(y = maxGrid() + .15) +
        facet_wrap(~ level, nrow=2, scales = "free") +
        scale_fill_Publication() + 
        theme_Publication() +
        theme(
          legend.position = "top",
          legend.margin = margin(t = -0.4, unit = "cm"),
          axis.title = element_text(size = 12.5),
          plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
        ) +
        labs(x = "", y = "Percent",
             title = input$var,
             fill = "",
             caption = "Percent at the household level are weighted sample means.
             Number of observations in parenthesis.")
      
      
    }, height = 700)
}

# Run the application 
shinyApp(ui = ui, server = server)
