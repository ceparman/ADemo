
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)
jscode <- "shinyjs.closeWindow = function() { window.close(); }"
fluidPage(
  useShinyjs(),
  extendShinyjs(text = jscode, functions = c("closeWindow")),
  verticalLayout(
      titlePanel("Abbvie ADC Sability App"),
      mainPanel(
        
               tags$h4("Processing Experiment"),
               verbatimTextOutput("expt"),
               tags$hr(),
               
                fileInput('file1', 'Choose Data File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
                
               tags$hr(),
                
               actionButton("fit","Process Data and Save Files"),
      
               tags$hr(),
                
          
               tags$h4("Status"),
               verbatimTextOutput("message",placeholder = TRUE),
               uiOutput("return")
    )
  )
)

