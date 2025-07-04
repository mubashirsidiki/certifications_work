# server.R
# Author: Mubashir Ahmed Siddiqui
# Date: 05-SEPT-2023
# Description: Shiny Server, Coursera Data Science Capstone Final Project
# GitHub: https://github.com/cidara/datasciencecoursera/tree/main/10_Data_Science_Capstone

# load the n-gram frequencies (generated by "build-ngram-frequencies.R")
initialPrediction <- readRDS("./data/start-word-prediction.RData")
freq2ngram <- readRDS("./data/bigram.RData")
freq3ngram <- readRDS("./data/trigram.RData")
freq4ngram <- readRDS("./data/quadgram.RData")

##initialPrediction <- readRDS("./data/start-word-prediction2.RData")
##freq2ngram <- readRDS("./data/bigram2.RData")
##freq3ngram <- readRDS("./data/trigram2.RData")
##freq4ngram <- readRDS("./data/quadgram2.RData")

# load bad words file
badWordsFile <- "data/full-list-of-bad-words_text-file_2018_07_30.txt"
con <- file(badWordsFile, open = "r")
profanity <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
profanity <- iconv(profanity, "latin1", "ASCII", sub = "")
close(con)

predictionMatch <- function(userInput, ngrams) {

    # quadgram (and higher)
    if (ngrams > 3) {
        userInput3 <- paste(userInput[length(userInput) - 2],
                            userInput[length(userInput) - 1],
                            userInput[length(userInput)])
        dataTokens <- freq4ngram %>% filter(variable == userInput3)
        ##dataTokens <- freq4ngram %>% filter(token == userInput3)
        if (nrow(dataTokens) >= 1) {
            return(dataTokens$outcome[1:3])
        }
        # backoff to trigram
        return(predictionMatch(userInput, ngrams - 1))
    }

    # trigram
    if (ngrams == 3) {
        userInput1 <- paste(userInput[length(userInput)-1], userInput[length(userInput)])
        dataTokens <- freq3ngram %>% filter(variable == userInput1)
        ##dataTokens <- freq3ngram %>% filter(token == userInput1)
        if (nrow(dataTokens) >= 1) {
            return(dataTokens$outcome[1:3])
        }
        # backoff to bigram
        return(predictionMatch(userInput, ngrams - 1))
    }

    # bigram (and lower)
    if (ngrams < 3) {
        userInput1 <- userInput[length(userInput)]
        dataTokens <- freq2ngram %>% filter(variable == userInput1)
        ##dataTokens <- freq2ngram %>% filter(token == userInput1)
        return(dataTokens$outcome[1:3])
        # backoff (1-gram not implemented for enhanced performance)
        # return(match_predict(userInput, ngrams - 1))
    }

    # unigram: not implemented to enhance performance
    return(NA)
}

cleanInput <- function(input) {

    # debug
    #print(paste0("input: ", input))

    if (input == "" | is.na(input)) {
        return("")
    }

    input <- tolower(input)

    # remove URL, email addresses, Twitter handles and hash tags
    input <- gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", input, ignore.case = FALSE, perl = TRUE)
    input <- gsub("\\S+[@]\\S+", "", input, ignore.case = FALSE, perl = TRUE)
    input <- gsub("@[^\\s]+", "", input, ignore.case = FALSE, perl = TRUE)
    input <- gsub("#[^\\s]+", "", input, ignore.case = FALSE, perl = TRUE)

    # remove ordinal numbers
    input <- gsub("[0-9](?:st|nd|rd|th)", "", input, ignore.case = FALSE, perl = TRUE)

    # remove profane words
    input <- removeWords(input, profanity)

    # remove punctuation
    input <- gsub("[^\\p{L}'\\s]+", "", input, ignore.case = FALSE, perl = TRUE)

    # remove punctuation (leaving ')
    input <- gsub("[.\\-!]", " ", input, ignore.case = FALSE, perl = TRUE)

    # trim leading and trailing whitespace
    input <- gsub("^\\s+|\\s+$", "", input)
    input <- stripWhitespace(input)

    # debug
    #print(paste0("output: ", input))
    #print("---------------------------------------")

    if (input == "" | is.na(input)) {
        return("")
    }

    input <- unlist(strsplit(input, " "))

    return(input)

}

predictNextWord <- function(input, word = 0) {

    input <- cleanInput(input)

    if (input[1] == "") {
        output <- initialPrediction
    } else if (length(input) == 1) {
        output <- predictionMatch(input, ngrams = 2)
    } else if (length(input) == 2) {
        output <- predictionMatch(input, ngrams = 3)
    } else if (length(input) > 2) {
        output <- predictionMatch(input, ngrams = 4)
    }

    if (word == 0) {
        return(output)
    } else if (word == 1) {
        return(output[1])
    } else if (word == 2) {
        return(output[2])
    } else if (word == 3) {
        return(output[3])
    }

}

shinyServer(function(input, output) {

    # original sentence
    output$userSentence <- renderText({input$userInput});

    # reactive controls
    observe({
        numPredictions <- input$numPredictions
        if (numPredictions == 1) {
            output$prediction1 <- reactive({predictNextWord(input$userInput, 1)})
            output$prediction2 <- NULL
            output$prediction3 <- NULL
        } else if (numPredictions == 2) {
            output$prediction1 <- reactive({predictNextWord(input$userInput, 1)})
            output$prediction2 <- reactive({predictNextWord(input$userInput, 2)})
            output$prediction3 <- NULL
        } else if (numPredictions == 3) {
            output$prediction1 <- reactive({predictNextWord(input$userInput, 1)})
            output$prediction2 <- reactive({predictNextWord(input$userInput, 2)})
            output$prediction3 <- reactive({predictNextWord(input$userInput, 3)})
        }
    })

})
