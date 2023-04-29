#
# Created on: April 11, 2023


# load packages ----
# library(shiny)
# library(tidyverse)
# library(scales)
# library(plotly)

# source scripts ----
# source("helpers/data_prep.R")
# source("helpers/ggplot_theme_Publication-2.R")


# next steps: 
# - a button to show numbers/percents
# - facets?


# Define UI for application that draws a histogram
ui <- fluidPage(

  # titlePanel("Comparing adoption rates of CGIAR innovations across waves in the ESPS"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create bar graphs comparing adoption rates from the Ethiopian
               Socio-economic Panel Survey (ESPS)."),
      
      radioButtons("type",
                   label = "Choose sample type to display",
                   choices = list(
                     "All" = "All households/EA", 
                     "Panel" = "Panel households/EA"
                     ),
                   selected = "All households/EA"),
      
      width = 2
     
    ),
    
    mainPanel(
      
      selectInput("var", 
                  label = "Choose an innovation to display",
                  choices = labels_choices,
                  multiple = FALSE,
                  selected = NULL),
      
      tabsetPanel(
        type = "tabs",
        tabPanel("Household", plotOutput("plothh")),
        tabPanel("EA", plotOutput("plotea"))
      )
      
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  filteredDatahh <- reactive({
    adoption_rates %>%
      filter(
        label %in% input$var, sample == input$type, level == "Household"
      )
  })

  filteredDataEA <- reactive({
    adoption_rates %>%
      filter(
        label %in% input$var, sample == input$type, level == "EA"
      )
  })
  
  maxGridhh <- reactive({
    filteredDatahh() %>% 
      slice_max(mean) %>% 
      pull(mean)
  })
  
  maxGridEA <- reactive({
    filteredDataEA() %>% 
      slice_max(mean) %>% 
      pull(mean)
  })

    output$plothh <- renderPlot({
      
      filteredDatahh() %>% 
        plot_waves() +
        expand_limits(y = maxGridhh() + .15) +
        labs(title = input$var)
      
      
    }, height = 400)
    
    output$plotea <- renderPlot({
      
      filteredDataEA() %>% 
        plot_waves() +
        expand_limits(y = maxGridEA() + .15) +
        labs(title = input$var)
      
      
    }, height = 400)
}

# Run the application 
shinyApp(ui = ui, server = server)
