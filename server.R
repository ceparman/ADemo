
library(CoreAPI)
library(dplyr)
library(shiny)

## function call
## ${servletUrl}?cmd=iframe&iframeSrc=https://ngsanalytics.shinyapps.io/AbbvieDemo/?exptBarcode=${entityBarcode}




source("process_data.R")
source("plot_data.R")
clean_data<-data.frame()


#Global Variables


filePath <- ""
exptBarcode <- ""
exptID <-""
filename <- ""
clean_data<-data.frame()

function(input, output,session) {
  
  
  output$expt <- renderText({
    
    exptBarcode <<- parseQueryString(session$clientData$url_search)$exptBarcode
    
    exptBarcode
    
  })
  
  output$message <- renderText({
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
  
    filePath <<- inFile$datapath
    filename <<- inFile$name
    paste0("file '", inFile$name, ", loaded")
    
  })
  
  
  
###################### 
  
  
   observeEvent(input$fit,{
    
    if (is.null( input$file1))
    {
      output$message <- renderText({ "no file selected"})
      return()
      
    } 
    
    #load file
    
   
    output$message <- renderText({ "creating and loading fits"})
    
    tenant<-CoreAPI::coreAPI("account.json")
    
    tenant<-CoreAPI::authBasic(tenant)$coreApi
   
    
    
    #Get the Experiment info
    
  
    
    experiment<-CoreAPI::getEntityByBarcode(tenant,"ADC STABILITY EXPERIMENT",exptBarcode )
    
   
    #Reduce Data 
    
    clean_data<-process_data(filePath)
    
   
    
    samples<-unique(clean_data$sample_lot)
    
    #no nice way but to go throught one at a time
    withProgress(message = 'Saving Data', value = 0, {
      
    for (i in 1: length(samples))
    {
     incProgress(1/length(samples), detail = paste("Processing Sample", i))   
     
       sdata <- clean_data[clean_data$sample_lot== samples[i],]  
       
      
       
       #build assay data  
       
       assayAttributeValues <- list(DEMO_CALCCONC_DAY0 = sdata$Calc.Conc.[sdata$t == 0],  
                                    DEMO_CALCCONC_DAY1 = sdata$Calc.Conc.[sdata$t == 1],
                                    DEMO_CALCCONC_DAY2 = sdata$Calc.Conc.[sdata$t == 2],
                                    DEMO_CALCCONC_DAY3 = sdata$Calc.Conc.[sdata$t == 3],
                                    DEMO_CALCCONC_DAY4 = sdata$Calc.Conc.[sdata$t == 4]
         )  
       
       
       #add experiment Sample
       
       es<-CoreAPI::createExperimentSample(coreApi = tenant,entityType ="ADC STABILITY EXPERIMENT SAMPLE",
                                           sampleLotBarcode = samples[i],
                                           experimentBarcode = exptBarcode,
                                           useVerbose = FALSE
          )
       
       #add assay data
       ad<-CoreAPI::updateExperimentSampleData(coreApi = tenant,entityType = "ADC STABILITY EXPERIMENT SAMPLE",
                                               experimentSamplebarcode = es$entity$barcode,
                                               assayAttributeValues =  assayAttributeValues,
                                               useVerbose = FALSE
       )
       
       Sys.sleep(.1)
       
    }
    
      
     
  
    
    
    })  
    
    
    output$message <- renderText({paste0("Generatng Plots")})  
    
    plot_data(clean_data,"plots.pdf")
  
    
    
    #save data file to experiment
 
  
    
    save <- CoreAPI::attachFile(coreApi = tenant,barcode =  exptBarcode, filename = filename,
                                filepath = filePath ,useVerbose = TRUE )    
  
    
    save2 <- CoreAPI::attachFile(coreApi = tenant,barcode =  exptBarcode, filename = "plots.pdf",
                                   filepath = "plots.pdf" )  
    
    
    
   
    
    logout<- CoreAPI::logOut(tenant)
    
    output$message <- renderText({paste0("All data and files saved, you may return to the experiment")})  
   
  
   
    
  })
  
  
   
   ############################ 
  
    output$return <- renderUI({
      
      tenant<-CoreAPI::coreAPI("account.json")
      
      tenant<-CoreAPI::authBasic(tenant)$coreApi
      
      #Get the Experiment info
      
     
      experiment<-CoreAPI::getEntityByBarcode(tenant,"ADC STABILITY EXPERIMENT",exptBarcode )
      
      id<-experiment$entity$entityId
      
      logout<- CoreAPI::logOut(tenant)
      
      
      shiny::a(h4("Return to Experiment", class = "btn btn-default action-button",
                  style = "fontweight:600"), target = "_parent",
               href = paste0(tenant$coreUrl,"/corelims?cmd=get&entityType=ADC%20STABILITY%20EXPERIMENT&entityId="
                             , id)
               )
      
    })
  
  observeEvent(input$return, {js$closeWindow()
    stopApp()
    })
  
  
  
}