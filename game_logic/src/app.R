library("shiny")
library("ggplot2")
library("plotly")

ui <- fluidPage(
  
  titlePanel("AI Take Over"),
  
  mainPanel(
    HTML("You control the green dot, can you avoid our AI overlords ?"),
    plotOutput("output"),    
    h3("Controls"),
    actionButton("left", "LEFT"),
    actionButton("down", "DOWN"),
    actionButton("right", "RIGHT"),
    actionButton("up", "UP"),
    actionButton("reset", "RESET")
    )
  )

server <- function(input, output) {
  userSelection <- reactiveValues(data = NULL)
  observeEvent(input$left,{
    userSelection$data <- 1  
  })
  observeEvent(input$up,{
    userSelection$data <- 4  
  })
  observeEvent(input$right,{
    userSelection$data <- 3
  })
  observeEvent(input$down,{
    userSelection$data <- 2
  })
  observeEvent(input$reset,{
    userSelection$data <- NULL
  })
  output$output <- renderPlot({
    print(userSelection$data)
     if(is.null(userSelection$data)){
       engine$resetState()
       return(DEBUG(engine$getState()))
     }else{
       if(userSelection$data != 0){
         with(tf$Session() %as% sess, {
           saver <- tf$train$Saver()
           saver$restore(sess, "../data/tfmodel_alt.mdl")
           engine$playRound(agent, iteration = 1, export = FALSE, step = 100, p_action = userSelection$data)  
           userSelection$data <- 0
         })  
       }
       return(DEBUG(engine$getState()))
     }   
  })
}

app = shinyApp(ui = ui, server = server)

runApp(app, host = "0.0.0.0", port = 3515)

