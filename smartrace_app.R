#Version 1.3 
#install.packages(c("shiny", "data.table", "bslib", "bsicons", "DT", "officer", "flextable"))
#install.packages("bsicons")
#install.packages(c("future", "future.apply", "data.table"))
#install.packages("here")
#install.packages("shinyjs")
#install.packages("htmltools")
#install.packages("officer")
#install.packages("rlang")


library(shiny)
library(future)
library(future.apply)
library(shinyFiles)
library(data.table)
library(bslib)
library(bsicons)
library(DT)
library(here)
library(officer)
library(flextable)
library(shinyjs)

print("Starting SmarTRace v1.3.0")
#script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
script_dir <- normalizePath(".")
print(script_dir)

rdata_path <- normalizePath(
  file.path(script_dir, "smartrace_env.RData"),
  winslash = "/",
  mustWork = FALSE
)
load(rdata_path)
print("rdata loaded ...")

smartrace_path <- normalizePath(
  file.path(script_dir, "smartrace.R"),
  winslash = "/",
  mustWork = FALSE
)

source(smartrace_path)
print("smartrace.R sourced ...")


smartrace_functions <- normalizePath(
  file.path(script_dir, "functions_smartrace.R"),
  winslash = "/",
  mustWork = FALSE
)

source(smartrace_functions)
print("smartrace_functions sourced ...")

exists("server")

options(shiny.launch.browser = TRUE)
shinyApp(ui, server)