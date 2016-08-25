
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(leaflet)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Bat Drone Data Analysis"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput("GPSlog",
                "Upload your GPS log",
                accept = '.log'),
      textInput("audiofiles",
                'Enter Audio file directory',
                value = '')
      #              'adjustment',
      #              value = 5,
      #              min = 0,
      #              step = 0.1)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      # dataTableOutput("path_print"),
      # textOutput("path_audio"),
      leafletOutput('map',  height = '800px')
    )
  )
))
