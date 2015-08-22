library(shiny)

suppressWarnings(suppressMessages(library(tm)))
suppressWarnings(suppressMessages(library(RWeka)))
suppressWarnings(suppressMessages(library(Matrix)))
suppressWarnings(suppressMessages(library(data.table)))
suppressWarnings(suppressMessages(library(stringi)))
suppressWarnings(suppressMessages(library(stringr)))
suppressWarnings(suppressMessages(library(scales)))
suppressWarnings(suppressMessages(library(SnowballC)))

model <- readRDS("data/model.rds")

remove_nonprint <- function (x) gsub ("[^[:print:]]+", "", x)

create_corpus <- function (text) {
  stopifnot (is.character (text))
  stopifnot (length (text) > 0)
  
  corpus <- Corpus (VectorSource (text))
  corpus <- tm_map (corpus, content_transformer (stri_trans_tolower))
  corpus <- tm_map (corpus, content_transformer (remove_nonprint))    
  corpus <- tm_map (corpus, removePunctuation)
  corpus <- tm_map (corpus, removeNumbers)
  #corpus <- tm_map (corpus, stemDocument, language = "english")
  corpus <- tm_map (corpus, stripWhitespace)
  corpus <- tm_map (corpus, content_transformer (stri_trim_both))
  
  return (corpus)
}

predict_next_word <- function (phrase, model, n = 3) {
  
  # sanity checks
  stopifnot (is.character (phrase))
  stopifnot (length (phrase) == 1)
  
  # uses 'create_corpus' to apply all of the same pre-processing on the 
  # input phrase as was applied to the training data
  clean_phrase <- sapply (create_corpus (phrase), function (x) x$content)
  
  # break the sentence into its component words
  previous <- unlist (strsplit (clean_phrase, split = " ", fixed = TRUE))
  len <- length (previous)
  
  prediction <- NULL
  for (i in n:1) {
    
    # ensure there are enough previous words 
    # for example, a trigram model needs 2 previous words
    if (len >= i-1) {
      
      # grab the last 'i-1' words
      base <- tail (previous, i-1)
      base <- paste (base, collapse = " ")
      
      prediction <- model [prev_words == base, next_word]
      if (length (prediction) > 0) {
        #message (sprintf ("%s-gram: '%s' -> '%s'", i, base, prediction))
        break
      }
    }
  }
  
  return (prediction)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$best<-renderPrint({predict_next_word(input$text,model)})
  
 
})