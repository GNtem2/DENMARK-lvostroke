#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(shiny)
library(leaflet)
#library(multiplex) #Algebraic Tools for the Analysis of Multiple Social Networks

#use ggmap
source("Search.R")

##
#create data frame
#https://strokefoundation.org.au/about-stroke/treatment-for-stroke/stroke-care-units
edge<- read.csv("Hosp_Network_geocoded.csv")
df<-edge[,c(2:dim(edge)[2])]
row.names(df)<-edge[,1] #bipartite matrix
df_se<-edge[,c(2:16)]
row.names(df_se)<-edge[,1] #bipartite matrix
df_se<-df_se[c(1,6,7,11,12,13,14,17,19,20,24,25,31,33,34,35),]
#gf_se <- galois(df_se, labeling = "reduced")
df_geo<-edge[,c(47:49)]
df_geo<-df_geo[c(1,6,7,11,12,13,14,17,19,20,24,25,31,33,34,35),]

#library(bipartite)
#community structure of a network as distinct clusters of interactions
#Nedge3<-computeModules(df_se)
#plotModuleWeb(Nedge3) #module web object

#color leaflet
pal <- colorFactor(
  palette = c("red","blue"),  
  #bins=2,
  domain = as.factor(df_se$TPA))
pal2 <- colorFactor(
  palette = c("red","green"),  
  #bins=2,
  domain = as.factor(df_se$stroke_unit))
pal3 <- colorFactor(
  palette = c("red","yellow"),  
  domain = as.factor(df_se$CTP))

#set up the user interface page
ui <- fluidPage(
  titlePanel("Googling Acute Stroke Service in South-East Metropolitan Melbourne-Prototype App"),
    wellPanel(
      #helpText("This app helps you to select destination for stroke treatment. It accesses Google Map API to plot the route to the hospital. Please note that only selected hospitals can provide acute stroke therapy ie the app will not return a hospital that does not provide acute stroke therapy such as clot extraction or clot busting drugs. A table showing the list of hospitals and their capabilities are provided below. The app performs an optimization procedure using the estimated door in door out and trip time and assignment of LVO status to arrive at hospital destination choice. As you enter data, wait for the app to recalculate the trip time. The app is still being tested and should not be used to choose hospital at this stage "),
      tags$h5("This app helps you to select destination for stroke treatment. It accesses Google Map API to plot the route to the hospital. Please note that only selected hospitals can provide acute stroke therapy ie the app will not return a hospital that does not provide acute stroke therapy such as clot extraction or clot busting drugs. The app performs an optimization procedure using the estimated door in door out and trip time and assignment of LVO status to arrive at hospital destination choice. As you enter data, wait for the app to recalculate the trip time. The app is still being tested and should not be used to choose hospital at this stage. The app is related to several publications from the group and can be accessed by clicking the link below"),
      tags$a(href ="http://stroke.ahajournals.org/content/48/5/1353.long","Link to reference paper"),
      #location      
      textInput('varA'," enter your current location","300 springvale rd glen waverley"),
      #date & time
      textInput('time'," enter your time of onset, eg 2pm as 14:00 ", Sys.time()-2*60*60),
      #LVO score
      textInput('var'," enter large vessel occlusion status-Yes or No","Yes")
      ),
  #divide the page into 3 columns which sum to 12
    br(),
    column(9,
           tabPanel("Leaflet map of hospital locations",
                    leafletOutput("mymap"),p()),
           tabPanel("Hospital by Stroke Service Provision", 
                    plotOutput("hospNet",width="100%"),p())
           ),
    br(),
    column(3,
      tabPanel(
      #helpText("The probability of reduced good outcome based on rerouting to clot retrieval centre"),
      #textOutput("Prob"),
      helpText("The closest hospital providing acute stroke therapy is"),
      textOutput("Hospital"),
      helpText("Time in minutes to destination:"),
      textOutput("traveltime"),
      helpText("Time from onset in hours and minutes:"),
      textOutput("onsettime")
      )
  )
)

server <- function(input, output, session) {
  
  #bipartite module
  #output$hospNet<-renderPlot({
  #  plotModuleWeb(Nedge3) #module web object
  #})
  
  #map
  output$mymap <- renderLeaflet({
  
  #calculate time using the input$time
    time1<-input$time
    time2=Sys.time()
    timeOnset<-difftime(time2,time1,units="mins")
    timeOnset<-round(timeOnset/60,2)
    
  #dislay time  
    output$onsettime <- renderText({
      return(timeOnset)
    }) 
    
  #origin
  var1<-input$varA  
  geo1<-geocode(var1)
  x1<-geo1$lon
  y1<-geo1$lat
  
  #Destination
  var2<-"Monash Medical Centre"#c(145.1234, -37.92067) #
  var3<-"Box Hill Hospital"#c(145.1185, -37.81353) #
  var4<-"Frankston Hospital"#c(145.1292, -38.15121) #
  var5<-"wonthaggi hospital"#c(145.5812, -38.6081) #
  var6<-"warragul hospital"#c(145.9278 -38.17293) #
  var7<-"bairnsdale hospital"
  var8<-"sale hospital"
  var9<-"latrobe regional hospital"
  
  time1<-round(mapdist(var1,var2)$minutes,2)
  
  
  #if (timeOnset>= 8*60 &input$var>=4) {
  timeA<-reactive({
    if (timeOnset>= 8*60 &input$var=="Yes") {
      return (round(mapdist(var1,var3)$minutes,2))
    } else {
      if (timeOnset <= 8*60 & input$var=="Yes"  ) {
        return (round(mapdist(var1,var3)$minutes,2)+120)
      } else {
        if (input$var=="Yes" & timeOnset >= 8*60) {
          return (round(mapdist(var1,var3)$minutes,2))
        } else {
          return (round(mapdist(var1,var3)$minutes,2))
        }
      }
    }
  })
  
  
  time2=timeA() #BHH
  #
  timeB<-reactive({
    if (timeOnset<= 8*60 &input$var=="Yes") {
      return (round(mapdist(var1,var4)$minutes,2))
    } else {
      if (timeOnset <= 8*60 & input$var=="Yes"  ) {
        return (round(mapdist(var1,var4)$minutes,2))
      } else {
        if (input$var=="Yes" & timeOnset >= 8*60) {
          return (round(mapdist(var1,var4)$minutes,2))
        } else {
          return (round(mapdist(var1,var4)$minutes,2)+60)
        }
      }
    }
  })
  
  time3=timeB() #frankston
  #
  timeC<-reactive({
    if (timeOnset<= 8*60 &input$var=="Yes") {
      return (round(mapdist(var1,var5)$minutes,2))
    } else {
      if (timeOnset <= 8*60 & input$var=="Yes"  ) {
        return (round(mapdist(var1,var5)$minutes,2))
      } else {
        if (input$var=="Yes" & timeOnset >= 8*60) {
          return (round(mapdist(var1,var5)$minutes,2))
        } else {
          return (round(mapdist(var1,var5)$minutes,2)+120)
        }
      }
    }
  })
  
  
  time4=timeC() #wontahggi
  #
  timeD<-reactive({
    if (timeOnset<= 8*60 &input$var=="Yes") {
      return (round(mapdist(var1,var6)$minutes,2))
    } else {
      if (timeOnset <= 8*60 & input$var=="Yes"  ) {
        return (round(mapdist(var1,var6)$minutes,2))
      } else {
        if (input$var=="Yes" & timeOnset >= 8*60) {
          return (round(mapdist(var1,var6)$minutes,2))
        } else {
          return (round(mapdist(var1,var6)$minutes,2)+120)
        }
      }
    }
  })
  
  
  time5=timeD() #warragul
  
  #
  timeE<-reactive({
    if (timeOnset<= 8*60 &input$var=="Yes") {
      return (round(mapdist(var1,var7)$minutes,2))
    } else {
      if (timeOnset <= 8*60 & input$var=="Yes"  ) {
        return (round(mapdist(var1,var7)$minutes,2))
      } else {
        if (input$var=="Yes" & timeOnset >= 8*60) {
          return (round(mapdist(var1,var7)$minutes,2))
        } else {
          return (round(mapdist(var1,var7)$minutes,2)+120)
        }
      }
    }
  })

  time6=timeE() #bairsndale
  #
  timeF<-reactive({
    if (timeOnset<= 8*60 &input$var=="Yes") {
      return (round(mapdist(var1,var8)$minutes,2))
    } else {
      if (timeOnset <= 8*60 & input$var=="Yes"  ) {
        return (round(mapdist(var1,var8)$minutes,2))
      } else {
        if (input$var=="Yes" & timeOnset >= 8*60) {
          return (round(mapdist(var1,var8)$minutes,2))
        } else {
          return (round(mapdist(var1,var8)$minutes,2)+120)
        }
      }
    }
  })
  time7=timeF() #sale
  #
  timeG<-reactive({
    if (timeOnset<= 8*60 &input$var=="Yes") {
      return (round(mapdist(var1,var9)$minutes,2))
    } else {
      if (timeOnset <= 8*60 & input$var=="Yes"  ) {
        return (round(mapdist(var1,var9)$minutes,2))
      } else {
        if (input$var=="Yes" & timeOnset >= 8*60) {
          return (round(mapdist(var1,var9)$minutes,2))
        } else {
          return (round(mapdist(var1,var9)$minutes,2)+120)
        }
      }
    }
  })
  
  time8=timeG()   #latrobe
  
  #travel time
  Amb<-data.frame(Time=c(time1,time2,time3,time4,time5,time6,time7,time8),
                  Hosp=c(var2,var3,var4,var5,var6,var7,var8,var9),stringsAsFactors = FALSE)
  timeHosp<-min(Amb$Time)
  output$traveltime <- renderText({
    return(timeHosp)
  })
  
  No<-Amb$Hosp[Amb$Time==timeHosp]
    myHosp<-as.character(No)
  output$Hospital <- renderText({
    return(myHosp)
  })
  
  geo<-geocode(myHosp)
  x<-geo$lon
  y<-geo$lat
  #geo1<-geocode(var1)
  #x1<-geo1$lon
  #y1<-geo1$lat
  
  
  ###########
  #plot route
  ###########
  #https://stackoverflow.com/questions/30270011/ggmap-route-finding-doesnt-stay-on-roads
  legs_df<-route(input$varA,myHosp,structure = "route",output = "all")
  # Custom decode function
  # Taken from http://s4rdd.blogspot.com/2012/12/google-maps-api-decoding-polylines-for.html
  
  decodeLine <- function(encoded){
    require(bitops)
    vlen <- nchar(encoded)
    vindex <- 0
    varray <- NULL
    vlat <- 0
    vlng <- 0
    
    while(vindex < vlen){
      vb <- NULL
      vshift <- 0
      vresult <- 0
      repeat{
        if(vindex + 1 <= vlen){
          vindex <- vindex + 1
          vb <- as.integer(charToRaw(substr(encoded, vindex, vindex))) - 63  
        }
        
        vresult <- bitOr(vresult, bitShiftL(bitAnd(vb, 31), vshift))
        vshift <- vshift + 5
        if(vb < 32) break
      }
      
      dlat <- ifelse(
        bitAnd(vresult, 1)
        , -(bitShiftR(vresult, 1)+1)
        , bitShiftR(vresult, 1)
      )
      vlat <- vlat + dlat
      
      vshift <- 0
      vresult <- 0
      repeat{
        if(vindex + 1 <= vlen) {
          vindex <- vindex+1
          vb <- as.integer(charToRaw(substr(encoded, vindex, vindex))) - 63        
        }
        
        vresult <- bitOr(vresult, bitShiftL(bitAnd(vb, 31), vshift))
        vshift <- vshift + 5
        if(vb < 32) break
      }
      
      dlng <- ifelse(
        bitAnd(vresult, 1)
        , -(bitShiftR(vresult, 1)+1)
        , bitShiftR(vresult, 1)
      )
      vlng <- vlng + dlng
      
      varray <- rbind(varray, c(vlat * 1e-5, vlng * 1e-5))
    }
    coords <- data.frame(varray)
    names(coords) <- c("lat", "lon")
    coords
  }
  
  route_df <- decodeLine( legs_df$routes[[1]]$overview_polyline$points )
  ########
  
  ############
  #leaflet map
  ############
  m<-leaflet(data=df_geo) %>%
      setView(145.1234,-37.92067,10)     %>% 
      addTiles() #%>%
      
      m=m %>%   
      addCircleMarkers(lng=~long,lat=~lat,radius=8,fillOpacity = .5, stroke=F,color=~pal(df_se$TPA),group="TPA",label=~as.character(Hosp))%>%  
      addLegend(pal=pal, values = ~df_se$TPA, opacity = 1,title = "TPA") %>%
      #hideGroup("TPA") %>%
      
      #second layer-stroke unit
      addCircleMarkers(lng=~long,lat=~lat,radius=8,fillOpacity = .5, stroke=F,color=~pal2(df_se$stroke_unit),group="Stroke Unit",label=~as.character(Hosp)) %>%
      addLegend(pal=pal2, values = ~df_se$stroke_unit, opacity = 1,title = "Stroke Unit") %>%
      
      #third layer-imaging
      addCircleMarkers(lng=~long,lat=~lat,radius=8,fillOpacity = .5, stroke=F,color=~pal3(df_se$CTP),group="Imaging",label=~as.character(Hosp)) %>%
      addLegend(pal=pal3, values = ~df_se$CTP, opacity = 1,title = "Imaging") #%>%
      
      #Fourth layer
      #addCircleMarkers(lng=~long,lat=~lat,radius=5,fillOpacity = .5, stroke=F,color=~pal2(df_se$VST),group="VST",label=~as.character(Hosp)) %>%
      #addLegend(pal=pal2, values = ~df_se$VST, opacity = 1,title = "VST") 
    #
      m=m %>%
      addLayersControl(baseGroups=c("TPA","Stroke Unit","Imaging"),overlayGroups = "Stroke Service Capability",options = layersControlOptions(collapsed = TRUE))
    
      
    m = m %>% addPolylines(route_df$lon, route_df$lat, fill = FALSE)
    #m = m %>% addPopups(route_df$lon[1], route_df$lat[1], 'Origin')
    #m = m %>% addPopups(route_df$lon[length(route_df$lon)], 
      #             route_df$lat[length(route_df$lon)], 'Destination')
      m
      
  })
  
 
}




shinyApp(ui, server)
