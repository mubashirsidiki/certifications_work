# ui.R
# Author: Mubashir Ahmed Siddiqui
# Date: 05-SEPT-2023
# Description: Shiny UI, Coursera Data Science Capstone Final Project
# GitHub: https://github.com/cidara/datasciencecoursera/tree/main/10_Data_Science_Capstone

library(shiny)
library(shinythemes)
library(markdown)
library(dplyr)
library(tm)

shinyUI(
    navbarPage("Next Word Predict",
               theme = shinytheme("spacelab"),
               tabPanel("Home",
                        fluidPage(
                            titlePanel("Home"),
                            sidebarLayout(
                                sidebarPanel(
                                    textInput("userInput",
                                              "Enter a word or phrase:",
                                              value =  "",
                                              placeholder = "Enter text here"),
                                    br(),
                                    sliderInput("numPredictions", "Number of Predictions:",
                                                value = 1.0, min = 1.0, max = 3.0, step = 1.0)
                                ),
                                mainPanel(
                                    h4("Input text"),
                                    verbatimTextOutput("userSentence"),
                                    br(),
                                    h4("Predicted words"),
                                    verbatimTextOutput("prediction1"),
                                    verbatimTextOutput("prediction2"),
                                    verbatimTextOutput("prediction3")
                                )
                            )
                        )
               ),
               tabPanel("About",
                        h3("About Next Word Predict"),
                        br(),
                        div("By : Mubashir Ahmed Siddiqui",
                            br(),
                            "Date : 05 Sept 2023",
                            br(),
                            br(),
                            "Next Word Predict is a Shiny app that uses a text
                            prediction algorithm to predict the next word(s)
                            based on text entered by a user.",
                            br(),
                            br(),
                            "The predicted next word will be shown when the app
                            detects that you have finished typing one or more
                            words. When entering text, please allow a few
                            seconds for the output to appear.",
                            br(),
                            br(),
                            "Use the slider tool to select up to three next
                            word predictions. The top prediction will be
                            shown first followed by the second and third likely
                            next words.",
                            br(),
                            br(),
                            "The source code for this application can be found
                            on GitHub:",
                            br(),
                            br(),
                            img(src = "github.png"),
                            a(target = "_blank", href = "https://github.com/cidara/datasciencecoursera/tree/main/10_Data_Science_Capstone",
                            "Next Word Predict")),
                        br())
               )
    )
