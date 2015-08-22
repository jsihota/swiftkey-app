library(shiny)

shinyUI(fluidPage(
  #create title panel
  titlePanel("Data Science Capstone: Next Word Prediction"),
  h4('This app predict next word that will follow the last word of the string'),
   
  textInput("text", label = h3("Text input"), value = ""),
  submitButton('Predict next Word'),
  hr(),
  
fluidRow(
  column(4, offset = 1,
       h4("Best Next Single Word Predicted"),
       verbatimTextOutput("best")
    )
  )
)
)