#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(scales)
# library(plotly)

adopt_rates_all_hh <- read_csv("data/adopt_rates_all_hh.csv")

adopt_rates_panel_hh <- read_csv("data/adopt_rates_panel_hh.csv")

adoption_rates <- bind_rows(
  adopt_rates_all_hh %>% 
    mutate(sample = "All households"),
  adopt_rates_panel_hh %>% 
    mutate(sample = "Panel households")
) %>% 
  mutate(
    region = fct_relevel(region, 
                         "Amhara", "Oromia", "SNNP", "Other regions", "National")
    ) 

labels <- unique(adoption_rates$label)

# Define UI for application that draws a histogram
ui <- fluidPage(

  titlePanel("Comparing adoption rates of CGIAR across waves in the ESPS"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create bar graphs comparing adoption rates from the Ethiopian 
               Socio-economic Panle Survey."),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = labels,
                  selected = "Afforestation"),
      
      radioButtons("type",
                   label = "Choose sample type to display",
                   choices = list(
                     "All households", 
                     "Panel households"),
                   selected = "All households")
     
    ),
    
    mainPanel(plotOutput("plot"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$plot <- renderPlot({
      
      adoption_rates %>% 
        filter(
          label == input$var, 
          sample == input$type,
          region != "Tigray"
          ) %>% 
        ggplot(aes(region, mean, fill = wave)) +
        geom_col(position = "dodge") +
        # geom_text(aes(label = paste0( round(mean_chickpea*100, 1), "%", "\n(", nobs, ")" ) ),
        #           position = position_dodge(width = 1),
        #           vjust = -.35, size = 2.5) +
        scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
        scale_y_continuous(labels = percent_format()) +
        expand_limits(y = .15) +
        theme(legend.position = "top") +
        labs(x = "", y = "Percent",
             title = "Add title",
             fill = "",
             caption = "Percent are weighted sample means.
       Number of responding households in parenthesis")
      
      
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
