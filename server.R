
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(BatUAV)
library(leaflet)
options(shiny.maxRequestSize=30*1024^2) 

shinyServer(function(input, output) {
  
  GPStab <- reactive({
    
    if(!is.null(input$GPSlog)){
      
      GPSFromLog(input$GPSlog[1, 'datapath'])
      
    }
  })
  
  filetab <- reactive({
    
    if(normalizePath(input$audiofiles) != ""){
      
      if(!dir.exists(normalizePath(input$audiofiles))) stop('Audio directory does not exist')
      
      audiofiles <- list.files(path = normalizePath(input$audiofiles),
                               pattern = '.wav$',
                               ignore.case = TRUE,
                               full.names = TRUE)
     
      createFileTimeTable(audiofiles)
      
    }
    
  })
  
  combTab <- reactive({
  
    filetab <- filetab()
    GPStab <- GPStab()
    
    # Adjust the filetab as the recorder was not correct
    filetab$time <- filetab$time + (60*5)#input$adjustment)
    
    combTab <- combineRecGPS(filetab = filetab, GPStab = GPStab)
    
    # Use file name to get peak frequency
    combTab$Peak <- gsub('^0', '', substr(combTab$file,
                                          start = nchar(combTab$file) - 10,
                                          stop = nchar(combTab$file) - 8))
    
    # Create 1 second sonograms
    combTab$Spectrogram <- unlist(lapply(X = combTab$file,
                                         FUN = writeSpectrogram,
                                         res = 70,
                                         outdir = 'www'))
    
    combTab
    
  })
  
  output$map <- renderLeaflet({
    
    if(is.null(filetab()) | is.null(GPStab())){
      
      m <- leaflet()
      m <- addProviderTiles(map = m,
                            provider = 'OpenStreetMap.Mapnik',
                            options = providerTileOptions(minZoom = 5, maxZoom = 20))
      m <- fitBounds(m, -5, 45, 2, 60)
      m
      
    } else {
      
      combTab <- combTab()
      
      m <- leaflet()
      m <- addPolylines(map = m, lng = GPStab()$longitude, lat = GPStab()$latitude, color = 'red')
      m <- addMarkers(map = m,
                      lng = combTab$longitude,
                      lat = combTab$latitude,
                      popup = paste("<style> div.leaflet-popup-content {width:auto !important;}</style>",
                                    '<span>', paste('Trigger Frequency -', combTab$Peak, 'kHz'), '<span/><br>',
                                    '<span>Time -', combTab$time, '<span/><br>',
                                    paste0('<img src="',
                                           basename(combTab$Spectrogram),
                                           '" alt="Spectrogram" height=280px width=420px>')))
      m <- addProviderTiles(map = m,
                            provider = 'OpenStreetMap.Mapnik',
                            options = providerTileOptions(minZoom = 5, maxZoom = 20))
      m <- setView(m,
                   lng = min(GPStab()$longitude) + ((max(GPStab()$longitude) - min(GPStab()$longitude))/2),
                   lat = min(GPStab()$latitude) + ((max(GPStab()$latitude) - min(GPStab()$latitude))/2),
                   zoom = 18)
      m
    }
  
  })
  
  output$path_print <- renderDataTable({
    
    GPStab() 
    
  })
  
  output$path_audio <- renderPrint({
    
    print(combTab()$Spectrogram)
    
  })
  
})
