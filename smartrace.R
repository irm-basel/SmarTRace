# CRAN Mirror 
options(download.file.method = "libcurl") #wininet
chooseCRANmirror(ind = 63)


# libraries
library(shiny)
library(data.table)
library(bslib)
library(bsicons)
library(DT)
library(here)
library(shinyFiles)
library(officer)
library(flextable)
library(shinyjs)

script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)


#get trace path for later
trace_file <- normalizePath(
  file.path(script_dir, "trace_path.txt"),
  winslash = "/",
  mustWork = FALSE
)

if (file.exists(trace_file)) {
  placeholder_text <- readLines(trace_file, warn = FALSE)
} else {
  placeholder_text <- "e.g. A:/IRM/..."
}


# Define UI
ui <- page_fluid(
  theme = bs_theme(bootswatch = "sandstone"),
  shinyjs::useShinyjs(),
  
  tags$head(
    tags$style(HTML("
      .navbar-brand {
        font-weight: bold;
        font-size: 1.3rem;
      }
      .navbar-logo {
        height: 40px;
        margin-right: 10px;
      }
      .split-peak-warning {
        color: #6f42c1;
        background-color: #e7d9f7;
        padding: 5px;
        border-radius: 3px;
        margin-bottom: 5px;
      }
      .split-peak-allele {
        color: #6f42c1;
        font-weight: bold;
      }
      .ol-warning {
        color: #b0156f;
        background-color: #fce4f0;
        padding: 5px;
        border-radius: 3px;
        margin-bottom: 5px;
      }
      .ol-allele {
        color: #b0156f;
        font-weight: bold;
      }
    ")),
    
    tags$script(HTML("
      Shiny.addCustomMessageHandler('runjs', function(message) {
        eval(message);
      });
    ")),
    
    tags$script(HTML("
      $(document).on('click', 'input[type=\"radio\"]', function() {
        var $radio = $(this);
        if ($radio.data('waschecked') == true) {
          $radio.prop('checked', false);
          $radio.data('waschecked', false);
          $radio.trigger('change');
        } else {
          $('input[name=\"' + $radio.attr('name') + '\"]').data('waschecked', false);
          $radio.data('waschecked', true);
        }
      });
    "))
  ),
  
  # Custom Navbar
  tags$nav(
    class = "navbar navbar-expand-lg bg-dark",
    `data-bs-theme` = "dark",
    tags$div(
      class = "container-fluid",
      tags$a(
        class = "navbar-brand",
        href = "#",
        tags$span(
          tags$strong("SmarTRace"),
          " - Pipeline for STR Genotype Interpretation"
        )
      ),
    )
  ),
  tags$br(),
  
  navset_card_tab(
    # INPUT TAB
    nav_panel(
      title = "Input",
      icon = icon("upload"),
      
      accordion(
        id = NULL,
        open = "Trace",
        multiple = TRUE,
        
        # TRACE PANEL
        accordion_panel(
          title = "Trace",
          icon = bsicons::bs_icon("fingerprint"),
          
          # Radio button for import method
          div(style = "max-width: 600px;",
              fluidRow(
                column(12,
                       radioButtons("trace_import_method",
                                    "Import Method:",
                                    choices = c("Upload loading plans (GM)" = "case_upload_smartDNA",
                                                "Upload individually selected traces" = "individual"),
                                    selected = "case_upload_imed")
                )
              )
          ),
          br(),
          
          # Conditional UI based on import method
          # Always-present path input, only visible for smartDNA method
          conditionalPanel(
            condition = "input.trace_import_method == 'case_upload_smartDNA'",
            div(style = "max-width: 600px;",
                fluidRow(
                  column(8,
                         textInput("smartDNA_path_input",
                                   "Base Directory:",
                                   value = "",
                                   placeholder = placeholder_text, #"e.g. A:/IRM/...",
                                   width = "100%")
                  ),
                  column(4,
                         div(style = "margin-top: 22px;",
                             actionButton("smartDNA_check_path",
                                          "Check Path",
                                          class = "btn-secondary btn-sm",
                                          icon = icon("check"))
                         )
                  )
                ),
                uiOutput("smartDNA_path_msg")
            ),
            br()
          ),
          
          # Conditional UI based on import method
          uiOutput("trace_import_ui")
        ),
        
        # PERSONS PANEL
        accordion_panel(
          title = "Persons",
          icon = bsicons::bs_icon("people"),
          
          div(style = "max-width: 600px;",
              fluidRow(
                column(6,
                       numericInput("num_persons", "Number of persons:", 
                                    value = 0, min = 0, max = 50, 
                                    width = "300px")
                )
              )
          ),
          br(),
          uiOutput("person_accordions")
        )
      ),
      
      br(),
      fluidRow(
        column(12, align = "center",
               actionButton("load_all_data", "Load All Data!", 
                            class = "btn-success btn-lg",
                            icon = icon("download"))
        )
      ),
      br()
    ),
    
    # TRACE CONSENSUS TABLE TAB
    nav_panel(
      title = "Trace Consensus Table",
      icon = icon("table"),
      
      br(),
      uiOutput("trace_consensus_accordions_display")
    ),
    
    # PERSONS TABLE TAB
    nav_panel(
      title = "Persons Table",
      icon = icon("users"),
      
      br(),
      uiOutput("persons_accordions_display")
    ),
    
    # TRACE VS PERSON COMPARISON TAB
    nav_panel(
      title = "Trace vs. Person Comparison",
      icon = icon("code-compare"),
      
      div(style = "max-width: 900px;",
          fluidRow(
            column(3,
                   textInput("expert_visum", 
                             "Expert Visum:",
                             value = "",
                             placeholder = "Enter your shortname",
                             width = "100%")
            ),
            column(3,
                   selectInput("comparison_trace_select", 
                               "Select Trace:",
                               choices = NULL,
                               width = "100%")
            ),
            column(3,
                   selectInput("comparison_person_select", 
                               "Select Person(s):",
                               choices = NULL,
                               multiple = TRUE,
                               width = "100%")
            ),
            column(3,
                   div(style = "margin-top: 32px; display: flex; gap: 5px;",
                       downloadButton("download_comparison_de", 
                                      "Word (DE)", 
                                      class = "btn-primary",
                                      style = "flex: 1;"),
                       downloadButton("download_comparison_en", 
                                      "Word (EN)", 
                                      class = "btn-info",
                                      style = "flex: 1;")
                   )
            )
          )
      ),
      br(),
      div(style = "max-width: 600px;",
          fluidRow(
            column(6,
                   selectInput("comparison_sort_kit",
                               "Sort by kit order:",
                               choices = c("ESIf", "NGMdetect", "ESXf", "Fusion6C", 
                                           "ArgusX12QS", "Y23", "Yfiler+", "NGMselect"),
                               selected = "NGMselect",
                               width = "300px")
            )
          )
      ),
      br(),
      #uiOutput("comparison_header"),
      #br(),
      uiOutput("comparison_tables_display")
    )
  )
)


# Define Server
server <- function(input, output, session) {
  # Path to trace_path.txt in same directory as this script
  script_dir <- tryCatch(
    dirname(rstudioapi::getSourceEditorContext()$path),
    error = function(e) getwd()
  )
  trace_path_file <- file.path(script_dir, "trace_path.txt")
  
  # Load saved path from txt file if it exists
  smartDNA_base_dir <- reactiveVal({
    if (file.exists(trace_path_file)) {
      stored <- trimws(readLines(trace_path_file, n = 1, warn = FALSE))
      if (nchar(stored) > 0) stored else ""
    } else {
      ""
    }
  })
  
  # Pre-fill text input with saved path on startup
  observe({
    req(input$smartDNA_path_input)
    isolate({
      if (input$smartDNA_path_input == "") {
        updateTextInput(session, "smartDNA_path_input", value = smartDNA_base_dir())
      }
    })
  })
  
  # Check path button
  observeEvent(input$smartDNA_check_path, {
    path <- input$smartDNA_path_input
    
    if (is.null(path) || path == "") {
      output$smartDNA_path_msg <- renderUI({
        tags$div(class = "invalid-feedback d-block", "Please enter a path")
      })
      return()
    }
    
    if (dir.exists(path)) {
      smartDNA_base_dir(path)
      # Overwrite trace_path.txt with new path
      writeLines(path, trace_path_file)
      output$smartDNA_path_msg <- renderUI({
        tags$div(class = "valid-feedback d-block", "✅ Path exists and saved")
      })
    } else {
      output$smartDNA_path_msg <- renderUI({
        tags$div(class = "invalid-feedback d-block", "❌ Path does not exist")
      })
    }
  })
  

  
  # Helper function to run JavaScript
  runjs <- function(code) {
    session$sendCustomMessage("runjs", code)
  }
  
  
  rv <- reactiveValues(
    trace_valid = FALSE,
    persons_valid = FALSE,
    trace_msg = NULL,
    person_msgs = list(),
    valid_pcns = data.frame(Type = character(), PCN = character(), stringsAsFactors = FALSE),
    trace_data = NULL,        
    person_data_list = list(),
    case_traces_imed = NULL,
    case_traces_smartDNA = NULL,
    individual_traces = list(),
    traces_consensus = NULL,
    consensus_updated = 0,  # Counter to trigger updates
    person_files_data = list()
  )
  
  # Function to recalculate consensus for all traces
  recalculate_all_consensus <- function() {
    if (!exists("trace_data_list", envir = .GlobalEnv)) {
      return(NULL)
    }
    
    trace_list <- get("trace_data_list", envir = .GlobalEnv)
    
    traces_results <- list()
    for (trace_name in names(trace_list)) {
      traces_results[[trace_name]] <- tryCatch({
        trace_data <- trace_list[[trace_name]]
        
        # Convert all Kit data to data.table
        for (kit_name in names(trace_data)) {
          if (kit_name %in% c("PCN", "Comments")) next
          
          kit_data <- trace_data[[kit_name]]
          if (is.data.frame(kit_data) || is.data.table(kit_data)) {
            if (!is.data.table(kit_data)) {
              trace_data[[kit_name]] <- as.data.table(kit_data)
            }
          }
        }
        
        create_trace_consensus(trace_data)
      }, error = function(e) {
        showNotification(paste("Error creating consensus for", trace_name, ":", e$message), 
                         type = "error", duration = 5)
        NULL
      })
    }
    
    return(traces_results)
  }
  
  ##  TRACE  ####################################################################
  
  # Reactive value for filtered trace names
  filtered_traces <- reactive({
    traces_data <- all_traces_consensus_data()
    if (is.null(traces_data) || length(traces_data) == 0) return(NULL)
    
    # Sort trace names intelligently
    sorted_trace_names <- sort_trace_names(names(traces_data))
    
    # Filter traces based on search input
    search_term <- input$trace_search_input
    if (!is.null(search_term) && search_term != "") {
      # Case-insensitive search
      filtered_names <- sorted_trace_names[grepl(search_term, sorted_trace_names, ignore.case = TRUE)]
    } else {
      filtered_names <- sorted_trace_names
    }
    
    list(
      all_names = sorted_trace_names,
      filtered_names = filtered_names,
      search_term = search_term
    )
  })
  
  # Render trace import UI based on method
  output$trace_import_ui <- renderUI({
    method <- input$trace_import_method
    
    if (method == "case_upload_smartDNA") {
      # OPTION B: Upload loading plans (Format B)
      tagList(
        div(style = "max-width: 600px;",
            fluidRow(
              column(6,
                     textInput("case_id_smartDNA",
                               "Case ID:",
                               value = "",
                               placeholder = "e.g., FG25-2051",
                               width = "300px")
              ),
              column(6,
                     div(style = "margin-top: 32px;",
                         actionButton("search_case_smartDNA",
                                      "Search Files",
                                      class = "btn-primary",
                                      icon = icon("search"))
                     )
              )
            )
        ),
        br(),
        uiOutput("case_search_results_smartDNA")
      )
    } else {
      # OPTION C: Individual trace import (existing code)
      tagList(
        div(style = "max-width: 600px;",
            fluidRow(
              column(6,
                     numericInput("num_traces", "Number of traces:", 
                                  value = 1, min = 1, max = 50, 
                                  width = "300px")
              )
            )
        ),
        br(),
        uiOutput("trace_accordions_individual")
      )
    }
  })
  
  # Clear all traces when import method changes
  observeEvent(input$trace_import_method, {
    # Clear all trace-related reactive values
    rv$case_traces_imed <- NULL
    rv$case_traces_smartDNA <- NULL
    rv$individual_traces <- list()
    
    # Clear valid PCNs for traces (keep person PCNs)
    if (nrow(rv$valid_pcns) > 0) {
      rv$valid_pcns <- rv$valid_pcns[!grepl("^Trace|^Case_imed|^Case_B", rv$valid_pcns$Type), , drop = FALSE]
    }
    
    # Clear trace consensus
    rv$traces_consensus <- NULL
    
    # Show notification
    showNotification(
      "Switched import method - all previous traces cleared",
      type = "warning",
      duration = 3
    )
  }, ignoreInit = TRUE)
  
  # OPTION A: Search for Case ID (Format imed)
  observeEvent(input$search_case_imed, {
    case_id <- input$case_id_imed
    
    if (is.null(case_id) || case_id == "") {
      showNotification("Please enter a Case ID", type = "warning", duration = 3)
      return()
    }
    
    # Search files with progress bar
    base_dir <- smartDNA_base_dir()
    
    # Create progress object
    progress <- Progress$new()
    on.exit(progress$close())
    
    progress$set(message = "Searching...", value = 0)
    
    result <- search_files_by_case_id(case_id, base_dir, file_format = "imed", progress = progress)
    
    if (!result$success) {
      showNotification(result$message, type = "error", duration = 5)
      return()
    }
    
    # Store traces in reactive value
    rv$case_traces_imed <- result$traces
    
    # Show success message
    showNotification(result$message, type = "message", duration = 3)
  })
  

  
  # OPTION: Search for Case ID
  observeEvent(input$search_case_smartDNA, {
    case_id <- input$case_id_smartDNA
    
    if (is.null(case_id) || case_id == "") {
      showNotification("Please enter a Case ID", type = "warning", duration = 3)
      return()
    }
    
    # Search files with progress bar
    base_dir <- smartDNA_base_dir()
    
    # Create progress object
    progress <- Progress$new()
    on.exit(progress$close())
    
    progress$set(message = "Searching...", value = 0)
    
    result <- search_files_by_case_id(case_id, base_dir, file_format = "smartDNA", progress = progress)
    
    if (!result$success) {
      showNotification(result$message, type = "error", duration = 5)
      return()
    }
    
    # Store traces in reactive value
    rv$case_traces_smartDNA <- result$traces
    
    # Show success message
    showNotification(result$message, type = "message", duration = 3)
  })
  
  # Render search results for OPTION genemapper input
  output$case_search_results_smartDNA <- renderUI({
    req(rv$case_traces_smartDNA)
    
    traces <- rv$case_traces_smartDNA
    
    tagList(
      h4(paste("Found", length(traces), "Trace(s):")),
      
      lapply(names(traces), function(trace_id) {
        trace_info <- traces[[trace_id]]
        kit_count <- length(trace_info$kits)
        
        tags$div(
          style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin-bottom: 10px;",
          tags$strong(paste("Trace ID:", trace_id)),
          tags$br(),
          tags$span(paste("Files found:", length(trace_info$files))),
          tags$br(),
          tags$span(paste("Kits:", paste(names(trace_info$kits), collapse = ", "))),
          tags$br(),
          tags$small(
            style = "color: #666;",
            paste("Files:", paste(trace_info$files, collapse = ", "))
          ),
          tags$br(),
          if (kit_count == 1) {
            tags$span(
              style = "color: #856404; background-color: #fff3cd; padding: 2px 5px; border-radius: 3px;",
              "⚠️ Warning: Only one PCR found"
            )
          },
          tags$br(),
          br(),
          # PCN input for this trace
          fluidRow(
            column(6,
                   textInput(paste0("pcn_case_trace_B_", gsub("[^[:alnum:]]", "_", trace_id)),
                             paste("PCN-No. for", trace_id, ":"),
                             value = "",
                             width = "300px")
            ),
            column(6,
                   div(style = "margin-top: 32px;",
                       actionButton(paste0("validate_case_trace_B_", gsub("[^[:alnum:]]", "_", trace_id)),
                                    "Validate",
                                    class = "btn-primary btn-sm")
                   )
            )
          ),
          uiOutput(paste0("case_trace_msg_B_", gsub("[^[:alnum:]]", "_", trace_id)))
        )
      })
    )
  })
  
  # Validate PCNs for Case Upload smartDNA traces - Observer für jeden Button separat erstellen
  observeEvent(rv$case_traces_smartDNA, {
    traces <- rv$case_traces_smartDNA
    if (is.null(traces)) return()
    
    for (trace_id in names(traces)) {
      local({
        t_id <- trace_id
        pcn_input_id <- paste0("pcn_case_trace_B_", gsub("[^[:alnum:]]", "_", t_id))
        validate_button_id <- paste0("validate_case_trace_B_", gsub("[^[:alnum:]]", "_", t_id))
        msg_output_id <- paste0("case_trace_msg_B_", gsub("[^[:alnum:]]", "_", t_id))
        
        # Observer für den Validate Button
        observeEvent(input[[validate_button_id]], {
          pcn <- input[[pcn_input_id]]
          
          if (is.null(pcn) || pcn == "") {
            output[[msg_output_id]] <- renderUI({
              runjs(paste0("$('#", pcn_input_id, "').removeClass('is-valid').addClass('is-invalid');"))
              tags$div(class = "invalid-feedback d-block", "Please enter a PCN")
            })
            return()
          }
          
          msg <- validate_pcn(pcn)
          
          if (grepl("✅", msg)) {
            # Remove old entry for this trace first (before checking duplicates)
            rv$valid_pcns <- rv$valid_pcns[rv$valid_pcns$Type != paste("Case_B", t_id), , drop = FALSE]
            
            # Check for duplicates with other traces
            existing_trace_pcns <- rv$valid_pcns$PCN[grepl("^Trace|^Case_imed|^Case_B", rv$valid_pcns$Type)]
            
            if (pcn %in% existing_trace_pcns) {
              msg <- "⚠️ Duplicate Trace PCN"
            } else {
              # Check for duplicates with persons
              person_pcns <- rv$valid_pcns$PCN[grepl("^Person", rv$valid_pcns$Type)]
              if (pcn %in% person_pcns) {
                msg <- "⚠️ Duplicate of Person PCN"
              } else {
                # Add new valid PCN
                trace_row <- data.frame(Type = paste("Case_B", t_id), 
                                        PCN = pcn, 
                                        stringsAsFactors = FALSE)
                rv$valid_pcns <- rbind(rv$valid_pcns, trace_row)
              }
            }
          }
          
          # Render message
          output[[msg_output_id]] <- renderUI({
            is_valid <- grepl("✅", msg)
            is_warning <- grepl("⚠️", msg)
            
            if (is_valid) {
              runjs(paste0("$('#", pcn_input_id, "').removeClass('is-invalid').addClass('is-valid');"))
              tags$div(class = "valid-feedback d-block", gsub("✅ ", "", msg))
            } else if (is_warning) {
              runjs(paste0("$('#", pcn_input_id, "').removeClass('is-valid').addClass('is-invalid');"))
              tags$div(class = "invalid-feedback d-block", gsub("⚠️ ", "", msg))
            } else {
              runjs(paste0("$('#", pcn_input_id, "').removeClass('is-valid').addClass('is-invalid');"))
              tags$div(class = "invalid-feedback d-block", gsub("❌ ", "", msg))
            }
          })
        }, ignoreInit = TRUE)
      })
    }
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
  
  # Render messages for Case Upload smartDNA traces
  observe({
    traces <- rv$case_traces_smartDNA
    if (is.null(traces)) return()
    
    for (trace_id in names(traces)) {
      local({
        t_id <- trace_id
        msg_output_id <- paste0("case_trace_msg_B_", gsub("[^[:alnum:]]", "_", t_id))
        pcn_input_id <- paste0("pcn_case_trace_B_", gsub("[^[:alnum:]]", "_", t_id))
        
        output[[msg_output_id]] <- renderUI({
          msg <- rv$case_trace_msgs_B[[t_id]]
          if (is.null(msg)) return(NULL)
          
          is_valid <- grepl("✅", msg)
          is_warning <- grepl("⚠️", msg)
          
          if (is_valid) {
            runjs(paste0("$('#", pcn_input_id, "').removeClass('is-invalid').addClass('is-valid');"))
            tags$div(class = "valid-feedback d-block", gsub("✅ ", "", msg))
          } else if (is_warning) {
            runjs(paste0("$('#", pcn_input_id, "').removeClass('is-valid').addClass('is-invalid');"))
            tags$div(class = "invalid-feedback d-block", gsub("⚠️ ", "", msg))
          } else {
            runjs(paste0("$('#", pcn_input_id, "').removeClass('is-valid').addClass('is-invalid');"))
            tags$div(class = "invalid-feedback d-block", gsub("❌ ", "", msg))
          }
        })
      })
    }
  }, priority = 100)
  
  # Individual trace accordions with drag & drop
  output$trace_accordions_individual <- renderUI({
    n <- input$num_traces
    if (is.null(n) || n < 1) return(NULL)
    
    tagList(
      lapply(1:n, function(i) {
        accordion_panel(
          title = paste("Trace", i),
          icon = bsicons::bs_icon("fingerprint"),
          
          # Drag & Drop File Upload
          div(style = "max-width: 600px;",
              fluidRow(
                column(12,
                       fileInput(paste0("trace_", i, "_files"),
                                 "Drag & Drop Files Here (CSV or TXT):",
                                 multiple = TRUE,
                                 accept = c(".csv", ".txt"),
                                 width = "100%",
                                 buttonLabel = "Browse...",
                                 placeholder = "Drag files here or click to browse")
                )
              )
          ),
          br(),
          
          # Display uploaded files info
          uiOutput(paste0("trace_", i, "_files_info")),
          
          br(),
          
          # PCN validation
          uiOutput(paste0("trace_", i, "_pcn_ui")),
          
          br(),
          
          # Comments field
          div(style = "max-width: 600px;",
              fluidRow(
                column(12,
                       textInput(paste0("trace_", i, "_comments"),
                                 "Comments (optional):",
                                 value = "",
                                 placeholder = "Enter additional comments...",
                                 width = "100%")
                )
              )
          )
        )
      })
    )
  })
  
  # Process uploaded files for each individual trace
  observe({
    n <- input$num_traces
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        
        observeEvent(input[[paste0("trace_", ii, "_files")]], {
          file_input <- input[[paste0("trace_", ii, "_files")]]
          
          if (is.null(file_input)) {
            rv$individual_traces[[paste0("Trace_", ii)]] <- NULL
            return()
          }
          
          # Process files
          result <- process_trace_files(file_input)
          
          if (!result$success) {
            showNotification(result$message, type = "error", duration = 5)
            rv$individual_traces[[paste0("Trace_", ii)]] <- NULL
            return()
          }
          
          # Store processed trace data
          rv$individual_traces[[paste0("Trace_", ii)]] <- result$traces
          
          showNotification(result$message, type = "message", duration = 3)
        })
      })
    }
  })
  
  # Render file info for each individual trace
  observe({
    n <- input$num_traces
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        
        output[[paste0("trace_", ii, "_files_info")]] <- renderUI({
          trace_data <- rv$individual_traces[[paste0("Trace_", ii)]]
          
          if (is.null(trace_data) || length(trace_data) == 0) {
            return(NULL)
          }
          
          # Get first (and should be only) trace
          trace_id <- names(trace_data)[1]
          trace_info <- trace_data[[trace_id]]
          
          kit_count <- length(trace_info$kits)
          kit_names <- names(trace_info$kits)
          file_names <- trace_info$files
          
          tags$div(
            style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin-bottom: 10px;",
            tags$strong(paste("Trace ID:", trace_id)),
            tags$br(),
            tags$span(paste("Files uploaded:", length(file_names))),
            tags$br(),
            tags$span(paste("Kits:", paste(kit_names, collapse = ", "))),
            tags$br(),
            tags$small(
              style = "color: #666;",
              paste("Files:", paste(file_names, collapse = ", "))
            ),
            tags$br(),
            if (kit_count == 1) {
              tags$span(
                style = "color: #856404; background-color: #fff3cd; padding: 2px 5px; border-radius: 3px;",
                "⚠️ Warning: Only one PCR uploaded"
              )
            }
          )
        })
      })
    }
  })
  
  # Process uploaded files for each person (GeneMapper)
  observe({
    n <- input$num_persons
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        
        observeEvent(input[[paste0("person_", ii, "_files")]], {
          file_input <- input[[paste0("person_", ii, "_files")]]
          
          if (is.null(file_input)) {
            rv$person_files_data[[paste0("Person_", ii)]] <- NULL
            return()
          }
          
          # Process files using the same function as traces
          result <- process_trace_files(file_input)
          
          if (!result$success) {
            showNotification(result$message, type = "error", duration = 5)
            rv$person_files_data[[paste0("Person_", ii)]] <- NULL
            return()
          }
          
          # **FÜR PERSONS: Merge all traces into ONE person object**
          if (length(result$traces) > 1) {
            # Multiple "traces" found - merge them into one person
            merged_person <- list(
              files = character(),
              kits = list()
            )
            
            # Collect all files and kits from all traces
            for (trace_name in names(result$traces)) {
              trace_info <- result$traces[[trace_name]]
              merged_person$files <- c(merged_person$files, trace_info$files)
              
              # Merge kits, handling duplicate kit names
              for (kit_name in names(trace_info$kits)) {
                if (kit_name %in% names(merged_person$kits)) {
                  # Kit already exists - add suffix
                  kit_count <- sum(grepl(paste0("^", kit_name), names(merged_person$kits)))
                  kit_name_unique <- paste0(kit_name, "_", kit_count + 1)
                } else {
                  kit_name_unique <- kit_name
                }
                merged_person$kits[[kit_name_unique]] <- trace_info$kits[[kit_name]]
              }
            }
            
            # Store as one person with generic ID
            person_id <- paste0("Person_", ii)
            rv$person_files_data[[paste0("Person_", ii)]] <- list()
            rv$person_files_data[[paste0("Person_", ii)]][[person_id]] <- merged_person
            
          } else {
            # Only one "trace" found - use it directly
            rv$person_files_data[[paste0("Person_", ii)]] <- result$traces
          }
          
          showNotification(result$message, type = "message", duration = 3)
        })
      })
    }
  })
  
  # Render file info for each person
  observe({
    n <- input$num_persons
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        
        output[[paste0("person_", ii, "_files_info")]] <- renderUI({
          person_data <- rv$person_files_data[[paste0("Person_", ii)]]
          
          if (is.null(person_data) || length(person_data) == 0) {
            return(NULL)
          }
          
          # Get first (and should be only) person
          person_id <- names(person_data)[1]
          person_info <- person_data[[person_id]]
          
          kit_count <- length(person_info$kits)
          kit_names <- names(person_info$kits)
          file_names <- person_info$files
          
          tags$div(
            style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin-bottom: 10px;",
            tags$strong("Person Files Uploaded"),
            tags$br(),
            tags$span(paste("Files uploaded:", length(file_names))),
            tags$br(),
            tags$span(paste("Kits detected:", paste(kit_names, collapse = ", "))),
            tags$br(),
            tags$small(
              style = "color: #666;",
              paste("Files:", paste(file_names, collapse = ", "))
            ),
            tags$br(),
            if (kit_count == 1) {
              tags$span(
                style = "color: #856404; background-color: #fff3cd; padding: 2px 5px; border-radius: 3px;",
                "⚠️ Warning: Only one PCR uploaded"
              )
            }
          )
        })
      })
    }
  })
  
  # Render PCN input for each individual trace
  observe({
    n <- input$num_traces
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        
        output[[paste0("trace_", ii, "_pcn_ui")]] <- renderUI({
          # WICHTIG: Warte nicht auf trace_data - zeige PCN UI immer an
          # wenn die Accordion geöffnet ist
          
          # Hole trace_id wenn verfügbar
          trace_data <- rv$individual_traces[[paste0("Trace_", ii)]]
          
          if (!is.null(trace_data) && length(trace_data) > 0) {
            trace_id <- names(trace_data)[1]
            label_text <- paste("PCN-No. for", trace_id, ":")
          } else {
            label_text <- paste("PCN-No. for Trace", ii, ":")
          }
          
          div(style = "max-width: 600px;",
              fluidRow(
                column(6,
                       textInput(paste0("pcn_trace_indiv_", ii),
                                 label_text,
                                 value = "",
                                 width = "300px"),
                       uiOutput(paste0("trace_indiv_msg_", ii))
                ),
                column(6,
                       div(style = "margin-top: 32px;",
                           actionButton(paste0("validate_trace_indiv_", ii),
                                        "Validate",
                                        class = "btn-primary btn-sm")
                       )
                )
              )
          )
        })
      })
    }
  })
  
  # GeneMapper file inputs
  output$trace_genemapper_file_inputs <- renderUI({
    n <- input$num_trace_genemapper_files
    if (is.null(n) || n < 1) n <- 1
    
    tagList(
      lapply(1:n, function(i) {
        div(style = "max-width: 600px;",
            fluidRow(
              column(6,
                     fileInput(paste0("trace_genemapper_file_", i),
                               paste0("Upload GeneMapper CSV ", i, ":"),
                               accept = ".csv",
                               multiple = FALSE,
                               width = "300px")
              )
            )
        )
      })
    )
  })
  
  # Initialize trace_msgs whenever num_traces changes
  observeEvent(input$num_traces, {
    n <- input$num_traces
    if (!is.null(n) && n >= 1) {
      rv$trace_msgs <- vector("list", n)
    }
  }, ignoreInit = FALSE)
  
  # Validate individual Trace PCNs (from individual upload)
  observe({
    n <- input$num_traces
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        observeEvent(input[[paste0("validate_trace_indiv_", ii)]], {
          pcn <- input[[paste0("pcn_trace_indiv_", ii)]]
          
          if (is.null(pcn) || pcn == "") {
            rv$trace_msgs[[ii]] <- "⚠️ Please enter a PCN"
            return()
          }
          
          msg <- validate_pcn(pcn)
          
          if (grepl("✅", msg)) {
            # Remove old entry for this trace first (before checking duplicates)
            rv$valid_pcns <- rv$valid_pcns[rv$valid_pcns$Type != paste("Trace", ii), , drop = FALSE]
            
            # Check for duplicates with other traces
            existing_trace_pcns <- rv$valid_pcns$PCN[grepl("^Trace|^Case_imed|^Case_B", rv$valid_pcns$Type)]
            
            if (pcn %in% existing_trace_pcns) {
              msg <- "⚠️ Duplicate Trace PCN"
            } else {
              # Check for duplicates with persons
              person_pcns <- rv$valid_pcns$PCN[grepl("^Person", rv$valid_pcns$Type)]
              if (pcn %in% person_pcns) {
                msg <- "⚠️ Duplicate of Person PCN"
              } else {
                # Add new valid PCN
                trace_row <- data.frame(Type = paste("Trace", ii), 
                                        PCN = pcn, 
                                        stringsAsFactors = FALSE)
                rv$valid_pcns <- rbind(rv$valid_pcns, trace_row)
                rv$trace_valid <- TRUE
              }
            }
          }
          
          rv$trace_indiv_msgs[[ii]] <- msg
        })
      })
    }
  })
  
  # Render messages for individual trace PCNs
  observe({
    n <- input$num_traces
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        output[[paste0("trace_indiv_msg_", ii)]] <- renderUI({
          msg <- rv$trace_indiv_msgs[[ii]]
          if (is.null(msg)) return(NULL)
          
          is_valid <- grepl("✅", msg)
          is_warning <- grepl("⚠️", msg)
          
          input_id <- paste0("pcn_trace_indiv_", ii)
          
          if (is_valid) {
            runjs(paste0("$('#", input_id, "').removeClass('is-invalid').addClass('is-valid');"))
          } else {
            runjs(paste0("$('#", input_id, "').removeClass('is-valid').addClass('is-invalid');"))
          }
          
          if (is_valid) {
            tags$div(class = "valid-feedback d-block", 
                     gsub("✅ ", "", msg))
          } else if (is_warning) {
            tags$div(class = "invalid-feedback d-block", 
                     gsub("⚠️ ", "", msg))
          } else {
            tags$div(class = "invalid-feedback d-block", 
                     gsub("❌ ", "", msg))
          }
        })
      })
    }
  })
  
  # Render messages for each Trace PCN with Bootstrap validation
  observe({
    req(input$num_traces)  
    n <- input$num_traces
    if (is.null(n) || n < 1) return() 
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        output[[paste0("trace_msg_", ii)]] <- renderUI({
          msg <- rv$trace_msgs[[ii]]
          if (is.null(msg)) return(NULL)
          
          is_valid <- grepl("✅", msg)
          is_warning <- grepl("⚠️", msg)
          
          input_id <- paste0("pcn_trace_", ii)
          
          if (is_valid) {
            runjs(paste0("$('#", input_id, "').removeClass('is-invalid').addClass('is-valid');"))
          } else {
            runjs(paste0("$('#", input_id, "').removeClass('is-valid').addClass('is-invalid');"))
          }
          
          if (is_valid) {
            tags$div(class = "valid-feedback d-block", 
                     gsub("✅ ", "", msg))
          } else if (is_warning) {
            tags$div(class = "invalid-feedback d-block", 
                     gsub("⚠️ ", "", msg))
          } else {
            tags$div(class = "invalid-feedback d-block", 
                     gsub("❌ ", "", msg))
          }
        })
      })
    }
  })
  
  # Initialize trace_indiv_msgs whenever num_traces changes
  observeEvent(input$num_traces, {
    n <- input$num_traces
    if (!is.null(n) && n >= 1) {
      rv$trace_indiv_msgs <- vector("list", n)
    }
  }, ignoreInit = FALSE)
  
  # Initialize person_msgs whenever num_persons changes
  observeEvent(input$num_persons, {
    rv$person_msgs <- vector("list", input$num_persons)
  }, ignoreInit = FALSE)
  
  # Show/hide validate button based on number type selection
  observe({
    n <- input$num_persons
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        output[[paste0("person_validate_button_", ii)]] <- renderUI({
          number_type <- input[[paste0("person_number_type_", ii)]]
          
          if (!is.null(number_type) && number_type == "PCN-No.") {
            div(style = "margin-top: 32px;",
                actionButton(paste0("validate_person_", ii), 
                             "Validate",
                             class = "btn-primary btn-sm")
            )
          } else {
            NULL
          }
        })
      })
    }
  })
  
  # Validate individual Person Numbers
  observe({
    n <- input$num_persons
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        
        # Auto-validate for IRM-Nr. and Ass.-Nr. - NO VALIDATION, just clear any styling
        observeEvent(list(input[[paste0("person_number_", ii)]], 
                          input[[paste0("person_number_type_", ii)]]), {
                            number <- input[[paste0("person_number_", ii)]]
                            number_type <- input[[paste0("person_number_type_", ii)]]
                            
                            # For IRM-Nr. and Ass.-Nr., clear any validation styling
                            if (!is.null(number_type) && number_type != "" && 
                                number_type != "PCN-No.") {
                              rv$person_msgs[[ii]] <- NULL
                              
                              # Clear any validation classes
                              pcn_input_id <- paste0("person_number_", ii)
                              runjs(paste0("$('#", pcn_input_id, "').removeClass('is-valid is-invalid');"))
                            }
                          })
        
        # Manual validation for PCN-Nr.
        observeEvent(input[[paste0("validate_person_", ii)]], {
          number <- input[[paste0("person_number_", ii)]]
          number_type <- input[[paste0("person_number_type_", ii)]]
          
          if (is.null(number_type) || number_type != "PCN-No.") return()
          
          if (is.null(number) || number == "") {
            rv$person_msgs[[ii]] <- "⚠️ Please enter a PCN"
            return()
          }
          
          msg <- validate_person_number(number, number_type)
          
          if (grepl("✅", msg)) {
            # Check for duplicates with traces
            existing_trace_pcns <- rv$valid_pcns$PCN[grepl("^Trace", rv$valid_pcns$Type)]
            
            if (number %in% existing_trace_pcns) {
              msg <- "⚠️ Duplicate of Trace PCN"
            } else {
              # Check for duplicates with other persons
              other_persons <- rv$valid_pcns$PCN[grepl("^Person", rv$valid_pcns$Type)]
              if (number %in% other_persons && 
                  !any(rv$valid_pcns$Type == paste("Person", ii) & rv$valid_pcns$PCN == number)) {
                msg <- "⚠️ Duplicate Person Number"
              } else {
                # Remove old entry for this person if exists
                rv$valid_pcns <- rv$valid_pcns[rv$valid_pcns$Type != paste("Person", ii), , drop = FALSE]
                
                # Add new valid number
                person_row <- data.frame(Type = paste("Person", ii), 
                                         PCN = number, 
                                         stringsAsFactors = FALSE)
                rv$valid_pcns <- rbind(rv$valid_pcns, person_row)
                rv$persons_valid <- TRUE
              }
            }
          }
          
          rv$person_msgs[[ii]] <- msg
        })
      })
    }
  })
  
  # Render messages for each Person Number with Bootstrap validation
  observe({
    n <- input$num_persons
    for (i in seq_len(n)) {
      local({
        ii <- i
        output[[paste0("person_number_msg_", ii)]] <- renderUI({
          msg <- rv$person_msgs[[ii]]
          if (is.null(msg)) return(NULL)
          
          is_valid <- grepl("✅", msg)
          is_warning <- grepl("⚠️", msg)
          
          input_id <- paste0("person_number_", ii)
          
          if (is_valid) {
            runjs(paste0("$('#", input_id, "').removeClass('is-invalid').addClass('is-valid');"))
          } else {
            runjs(paste0("$('#", input_id, "').removeClass('is-valid').addClass('is-invalid');"))
          }
          
          if (is_valid) {
            tags$div(class = "valid-feedback d-block", 
                     gsub("✅ ", "", msg))
          } else if (is_warning) {
            tags$div(class = "invalid-feedback d-block", 
                     gsub("⚠️ ", "", msg))
          } else {
            tags$div(class = "invalid-feedback d-block", 
                     gsub("❌ ", "", msg))
          }
        })
      })
    }
  })
  
  
  ##  PERSONS  ####################################################################
  # Person accordions
  output$person_accordions <- renderUI({
    n <- input$num_persons
    if (is.null(n) || n < 1) return(NULL)
    
    tagList(
      lapply(1:n, function(i) {
        accordion(
          id = paste0("person_accordion_", i),
          open = FALSE,
          accordion_panel(
            title = paste("Person", i),
            icon = bsicons::bs_icon("person"),
            
            # Zeile 1: Nummer + Radio Buttons + Validate Button
            div(style = "max-width: 900px;",
                fluidRow(
                  column(3, 
                         textInput(paste0("person_number_", i), 
                                   paste("Person", i, "Number:"), 
                                   value = "",
                                   width = "100%"),
                         uiOutput(paste0("person_number_msg_", i))
                  ),
                  column(4,
                         radioButtons(paste0("person_number_type_", i),
                                      "Number Type:",
                                      choices = c("IRM-No.", "Ass.-No.", "PCN-No."),
                                      selected = character(0),
                                      inline = TRUE)
                  ),
                  column(2,
                         uiOutput(paste0("person_validate_button_", i))
                  )
                )
            ),
            br(),
            
            # Zeile 2: Person Status + Comments
            div(style = "max-width: 900px;",
                fluidRow(
                  column(3,
                         selectInput(paste0("person_status_", i),
                                     "Person Status:",
                                     choices = c("", "Authorized Person", "Suspect", "Victim", "Staff"),
                                     selected = "",
                                     width = "100%")
                  ),
                  column(6,
                         textInput(paste0("person_comments_", i),
                                   "Comments (optional):",
                                   value = "",
                                   placeholder = "Enter any additional comments...",
                                   width = "100%")
                  )
                )
            ),
            br(),
            
            # Zeile 3: Data Source
            div(style = "max-width: 600px;",
                fluidRow(
                  column(6,
                         selectInput(paste0("person_data_type_", i),
                                     "Data Source:",
                                     choices = c("GeneMapper i/med Export" = "file", 
                                                 "Statistefix CSV" = "file_imed",
                                                 "CSV File" = "file_csv", 
                                                 "Manually add" = "manual"),
                                     selected = "file_csv",
                                     width = "300px")
                  )
                )
            ),
            uiOutput(paste0("person_data_input_", i))
          )
        )
      })
    )
  })
  
  # Person data input (GeneMapper file or CSV file or manual)
  observe({
    n <- input$num_persons
    for (i in seq_len(n)) {
      local({
        ii <- i
        output[[paste0("person_data_input_", ii)]] <- renderUI({
          data_type <- input[[paste0("person_data_type_", ii)]]
          
          if (is.null(data_type)) return(NULL)
          
          if (data_type == "file") {
            # Drag & Drop File Upload (wie bei Traces)
            tagList(
              div(style = "max-width: 600px;",
                  fluidRow(
                    column(12,
                           fileInput(paste0("person_", ii, "_files"),
                                     "Drag & Drop GeneMapper i/med Export Files Here (CSV or TXT):",
                                     multiple = TRUE,
                                     accept = c(".csv", ".txt"),
                                     width = "100%",
                                     buttonLabel = "Browse...",
                                     placeholder = "Drag files here or click to browse")
                    )
                  )
              ),
              br(),
              # Display uploaded files info
              uiOutput(paste0("person_", ii, "_files_info"))
            )
          } else if (data_type == "manual"){
            # Manual input table
            markers <- kit_expected_markers$`NGMselect`
            
            tagList(
              h5("Enter alleles manually:"),
              div(style = "max-width: 450px;",
                  lapply(1:length(markers), function(j) {
                    div(style = "display: flex; gap: 10px; align-items: center; margin-bottom: 5px;",
                        div(style = "width: 120px; font-weight: bold;", markers[j]),
                        div(style = "width: 90px;", 
                            textInput(paste0("person_", ii, "_allele1_", j), 
                                      label = NULL, 
                                      placeholder = "Allele 1",
                                      width = "90px")),
                        div(style = "width: 90px;", 
                            textInput(paste0("person_", ii, "_allele2_", j), 
                                      label = NULL, 
                                      placeholder = "Allele 2",
                                      width = "90px"))
                    )
                  })
              )
            )
          } else if (data_type == "file_csv") {
            # CSV file input
            tagList(
              div(style = "max-width: 600px;",
                  fluidRow(
                    column(6,
                           fileInput(paste0("person_", ii, "_csv_file"),
                                     "Upload CSV File:",
                                     accept = ".csv",
                                     multiple = FALSE,
                                     width = "300px")
                    )
                  )
              )
            )
          } else if (data_type == "file_imed") {
            # Statistefix CSV file input
            tagList(
              div(style = "max-width: 600px;",
                  fluidRow(
                    column(6,
                           fileInput(paste0("person_", ii, "_imed_file"),
                                     "Upload Statistefix CSV File:",
                                     accept = ".csv",
                                     multiple = FALSE,
                                     width = "300px")
                    )
                  )
              )
            )
          }
        })
      })
    }
  })  
  observe({
    n <- input$num_persons
    if (is.null(n) || n < 1) return()
    
    for (i in seq_len(n)) {
      local({
        ii <- i
        
        observeEvent(input[[paste0("person_", ii, "_csv_file")]], {
          file_input <- input[[paste0("person_", ii, "_csv_file")]]
          
          if (is.null(file_input)) return()
          
          # Extract filename without .csv
          person_name <- tools::file_path_sans_ext(file_input$name)
          
          # Automatically fill textInput
          updateTextInput(
            session,
            inputId = paste0("person_number_", ii),
            value = person_name
          )
        })
        
        #same for imed
        observeEvent(input[[paste0("person_", ii, "_imed_file")]], {
          file_input <- input[[paste0("person_", ii, "_imed_file")]]
          if (is.null(file_input)) return()
          
          person_name <- tools::file_path_sans_ext(file_input$name)
          updateTextInput(session, inputId = paste0("person_number_", ii), value = person_name)
        })
        
      })
    }
  })
  
  
  
  
  ##  LOAD DATA  ####################################################################
  # Load all data on button click
  observeEvent(input$load_all_data, {
    
    # Initialize trace_data_list
    trace_data_list <- list()
    
    # Check import method
    import_method <- input$trace_import_method
    
    if (import_method == "case_upload_imed") {
      # ===== Load traces from OPTION A =====
      if (!is.null(rv$case_traces_imed)) {
        for (trace_id in names(rv$case_traces_imed)) {
          trace_info <- rv$case_traces_imed[[trace_id]]
          
          # Get PCN
          pcn_input_id <- paste0("pcn_case_trace_imed_", gsub("[^[:alnum:]]", "_", trace_id))
          trace_pcn <- input[[pcn_input_id]]
          
          # Store trace data
          trace_name <- paste0("Trace_", trace_id)
          trace_data_list[[trace_name]] <- c(
            trace_info$kits,
            list(PCN = if (!is.null(trace_pcn) && trace_pcn != "") trace_pcn else NA)
          )
          
          # Check for single file warning
          if (length(trace_info$kits) == 1) {
            showNotification(
              paste("⚠️", trace_name, ": Only one CSV file uploaded - Cannot create consensus table"),
              type = "warning", duration = 5
            )
          }
        }
        
        # showNotification(
        #   paste("✅ Loaded", length(rv$case_traces_imed), "trace(s) from Case Upload imed"),
        #   type = "message", duration = 3
        # )
      }
      
    } else if (import_method == "case_upload_smartDNA") {
      # ===== Load traces from OPTION B =====
      if (!is.null(rv$case_traces_smartDNA)) {
        for (trace_id in names(rv$case_traces_smartDNA)) {
          trace_info <- rv$case_traces_smartDNA[[trace_id]]
          
          # Get PCN
          pcn_input_id <- paste0("pcn_case_trace_smartDNA_", gsub("[^[:alnum:]]", "_", trace_id))
          trace_pcn <- input[[pcn_input_id]]
          
          # Store trace data
          trace_name <- paste0("Trace_", trace_id)
          trace_data_list[[trace_name]] <- c(
            trace_info$kits,
            list(PCN = if (!is.null(trace_pcn) && trace_pcn != "") trace_pcn else NA)
          )
          
          # Check for single file warning
          if (length(trace_info$kits) == 1) {
            showNotification(
              paste("⚠️", trace_name, ": Only one CSV file uploaded - Cannot create consensus table"),
              type = "warning", duration = 5
            )
          }
        }
        
        # showNotification(
        #   paste("✅ Loaded", length(rv$case_traces_smartDNA), "trace(s) from Case Upload smartDNA"),
        #   type = "message", duration = 3
        # )
      }
      
    } else if (import_method == "individual") {
      # ===== OPTION C: Individual trace import =====
      if (!is.null(rv$individual_traces) && length(rv$individual_traces) > 0) {
        for (trace_key in names(rv$individual_traces)) {
          trace_data_obj <- rv$individual_traces[[trace_key]]
          
          if (is.null(trace_data_obj) || length(trace_data_obj) == 0) next
          
          # Get trace ID
          trace_id <- names(trace_data_obj)[1]
          trace_info <- trace_data_obj[[trace_id]]
          
          # Get index from trace_key (e.g., "Trace_1" -> 1)
          trace_index <- as.integer(gsub("Trace_", "", trace_key))
          
          # Get PCN
          pcn <- input[[paste0("pcn_trace_indiv_", trace_index)]]
          if (is.null(pcn) || pcn == "") pcn <- NA
          
          # Get comments
          comments <- input[[paste0("trace_", trace_index, "_comments")]]
          if (is.null(comments) || comments == "") comments <- NA
          
          # Store trace data
          trace_name <- paste0("Trace_", trace_id)
          
          # Check for duplicate trace names
          if (trace_name %in% names(trace_data_list)) {
            counter <- 2
            original_name <- trace_name
            while (trace_name %in% names(trace_data_list)) {
              trace_name <- paste0(original_name, "_", counter)
              counter <- counter + 1
            }
          }
          
          trace_data_list[[trace_name]] <- c(
            trace_info$kits,
            list(
              PCN = pcn,
              Comments = comments
            )
          )
          
          # Check for single file warning
          if (length(trace_info$kits) == 1) {
            showNotification(
              paste("⚠️", trace_name, ": Only one file uploaded - Cannot create consensus table"),
              type = "warning", duration = 5
            )
          }
          
          # showNotification(paste("✅ Loaded:", trace_name), 
          #                  type = "message", duration = 2)
        }
        
        # if (length(trace_data_list) > 0) {
        #   showNotification(paste("✅", length(trace_data_list), "Trace(s) loaded from individual upload!"),
        #                    type = "message", duration = 3)
        # }
      }
      
      n_traces <- input$num_traces
      
      if (!is.null(n_traces) && n_traces >= 1) {
        for (i in seq_len(n_traces)) {
          num_pcrs <- input[[paste0("num_trace_", i, "_pcrs")]]
          if (is.null(num_pcrs) || num_pcrs < 1) next
          
          trace_pcr_list <- list()
          kit_name_counts <- list()
          
          for (j in seq_len(num_pcrs)) {
            file_input <- input[[paste0("trace_", i, "_pcr_file_", j)]]
            
            if (!is.null(file_input)) {
              trace_dt <- tryCatch({
                dt <- fread(file_input$datapath, sep = ",", header = TRUE)
                result <- dt[Marker != ""]
                result$Marker <- sapply(result$Marker, standardize_marker_name)
                result
              }, error = function(e) {
                showNotification(paste("Error reading trace", i, "file", j, ":", e$message), 
                                 type = "error", duration = 5)
                NULL
              })
              
              if (!is.null(trace_dt) && nrow(trace_dt) > 0) {
                pcr_kit <- input[[paste0("trace_", i, "_pcr_kit_", j)]]
                
                if (pcr_kit %in% names(kit_name_counts)) {
                  kit_name_counts[[pcr_kit]] <- kit_name_counts[[pcr_kit]] + 1
                  pcr_kit_unique <- paste0(pcr_kit, "_", kit_name_counts[[pcr_kit]])
                } else {
                  kit_name_counts[[pcr_kit]] <- 1
                  pcr_kit_unique <- pcr_kit
                }
                
                trace_pcr_list[[pcr_kit_unique]] <- trace_dt
              }
            }
          }
          
          # Add Trace PCN
          trace_pcn <- input[[paste0("pcn_trace_", i)]]
          if (!is.null(trace_pcn) && trace_pcn != "") {
            trace_pcr_list[["PCN"]] <- trace_pcn
          } else {
            trace_pcr_list[["PCN"]] <- NA
          }
          
          if (length(trace_pcr_list) > 0) {
            custom_name <- input[[paste0("trace_name_", i)]]
            
            if (!is.null(custom_name) && custom_name != "") {
              trace_name <- paste0("Trace_", custom_name)
            } else {
              trace_name <- paste0("Trace_", i)
              
              for (kit_name in names(trace_pcr_list)) {
                if (kit_name != "PCN" && "Sample Name" %in% names(trace_pcr_list[[kit_name]])) {
                  sample_name <- trace_pcr_list[[kit_name]]$`Sample Name`[1]
                  if (!is.null(sample_name) && !is.na(sample_name) && sample_name != "") {
                    result <- extract_case_number(sample_name)
                    if (!is.null(result$case_number) && result$case_number != "") {
                      trace_name <- paste0("Trace_", result$case_number)
                    }
                    break
                  }
                }
              }
            }
            
            if (trace_name %in% names(trace_data_list)) {
              counter <- 2
              original_name <- trace_name
              while (trace_name %in% names(trace_data_list)) {
                trace_name <- paste0(original_name, "_", counter)
                counter <- counter + 1
              }
            }
            
            trace_data_list[[trace_name]] <- trace_pcr_list
            
            # showNotification(paste("✅ Loaded:", trace_name), 
            #                  type = "message", duration = 2)
          }
        }
        
        # CHECK FOR SINGLE FILE WARNING per trace
        for (trace_name in names(trace_data_list)) {
          kit_count <- length(trace_data_list[[trace_name]]) - 
            if("PCN" %in% names(trace_data_list[[trace_name]])) 1 else 0
          
          if (kit_count == 1) {
            showNotification(
              paste("⚠️", trace_name, ": Only one CSV file uploaded - Cannot create consensus table"),
              type = "warning", duration = 5
            )
          }
        }
        
        if (length(trace_data_list) > 0) {
          # showNotification(paste("✅", length(trace_data_list), "Trace(s) loaded!"),
          #                  type = "message", duration = 3)
        } else {
          showNotification("⚠️ No trace files found to load", 
                           type = "warning", duration = 3)
        }
      }
    }
    
    # Save trace data to global environment
    if (length(trace_data_list) > 0) {
      assign("trace_data_list", trace_data_list, envir = .GlobalEnv)
    }
    
    # Person data
    person_data_list <- list()
    n_persons <- input$num_persons
    
    if (!is.null(n_persons) && n_persons >= 1) {
      for (i in seq_len(n_persons)) {
        data_type <- input[[paste0("person_data_type_", i)]]
        
        if (is.null(data_type)) next
        
        # Get person metadata (same for all types)
        person_number <- input[[paste0("person_number_", i)]]
        person_number_type <- input[[paste0("person_number_type_", i)]]
        person_status <- input[[paste0("person_status_", i)]]
        person_comments <- input[[paste0("person_comments_", i)]]
        
        if (data_type == "file") {
          # === GeneMapper Files (Drag & Drop) ===
          person_files <- rv$person_files_data[[paste0("Person_", i)]]
          
          if (!is.null(person_files) && length(person_files) > 0) {
            # Get first (and should be only) person
            person_id <- names(person_files)[1]
            person_info <- person_files[[person_id]]
            
            person_data_list[[paste0("Person_", i)]] <- c(
              person_info$kits,
              list(
                PCN = if (!is.null(person_number) && !is.null(person_number_type) && 
                          person_number_type == "PCN-No." && person_number != "") person_number else NA,
                Number = if (!is.null(person_number) && person_number != "") person_number else NA,
                Number_Type = if (!is.null(person_number_type) && person_number_type != "") person_number_type else NA,
                Status = if (!is.null(person_status) && person_status != "") person_status else NA,
                Comments = if (!is.null(person_comments) && person_comments != "") person_comments else NA
              )
            )
          }
        } else if (data_type == "manual") {
          # === Manual Input ===
          markers <- c("D10S1248", "vWA", "D16S539", "D2S1338", "D8S1179", "D21S11", "D18S51", 
                       "D22S1045", "D19S433", "TH01", "FGA", "D2S441", "D3S1358", "D1S1656", 
                       "D12S391", "SE33", "AMEL", "TPOX", "CSF1PO", "D13S317", "D7S820", 
                       "D5S818", "PentaD", "PentaE")
          
          manual_data <- data.table(
            System = markers,
            Allele1 = character(length(markers)),
            Allele2 = character(length(markers))
          )
          
          for (j in seq_along(markers)) {
            allele1 <- input[[paste0("person_", i, "_allele1_", j)]]
            allele2 <- input[[paste0("person_", i, "_allele2_", j)]]
            manual_data$Allele1[j] <- if (is.null(allele1) || allele1 == "") "" else allele1
            manual_data$Allele2[j] <- if (is.null(allele2) || allele2 == "") "" else allele2
          }
          
          if (any(manual_data$Allele1 != "" | manual_data$Allele2 != "")) {
            person_data_list[[paste0("Person_", i)]] <- list(
              Manual = manual_data,
              PCN = if (!is.null(person_number) && !is.null(person_number_type) && 
                        person_number_type == "PCN-No." && person_number != "") person_number else NA,
              Number = if (!is.null(person_number) && person_number != "") person_number else NA,
              Number_Type = if (!is.null(person_number_type) && person_number_type != "") person_number_type else NA,
              Status = if (!is.null(person_status) && person_status != "") person_status else NA,
              Comments = if (!is.null(person_comments) && person_comments != "") person_comments else NA
            )
          }
          
        } else if (data_type == "file_csv") {
          # === CSV File ===
          file_input <- input[[paste0("person_", i, "_csv_file")]]
          
          if (!is.null(file_input)) {
            person_csv_data <- tryCatch({
              csv_data <- fread(file_input$datapath, sep = ";", header = TRUE, encoding = "UTF-8")
              
              if (ncol(csv_data) >= 3) {
                csv_data <- csv_data[, 1:3]
              }
              
              setnames(csv_data, c("Marker", "Allele1", "Allele2"))
              csv_data$Marker <- sapply(csv_data$Marker, standardize_marker_name)
              csv_data$Allele1 <- ifelse(is.na(csv_data$Allele1) | csv_data$Allele1 == "", "", as.character(csv_data$Allele1))
              csv_data$Allele2 <- ifelse(is.na(csv_data$Allele2) | csv_data$Allele2 == "", "", as.character(csv_data$Allele2))
              
              csv_data
              
            }, error = function(e) {
              showNotification(paste("Error reading CSV file for person", i, ":", e$message), 
                               type = "error", duration = 5)
              NULL
            })
            
            if (!is.null(person_csv_data) && nrow(person_csv_data) > 0) {
              
              
              person_data_list[[paste0("Person_", i)]] <- list(
                CSV = person_csv_data,
                PCN = if (!is.null(person_number) && !is.null(person_number_type) && 
                          person_number_type == "PCN-No." && person_number != "") person_number else NA,
                Number = if (!is.null(person_number) && person_number != "") person_number else NA,
                Number_Type = if (!is.null(person_number_type) && person_number_type != "") person_number_type else NA,
                Status = if (!is.null(person_status) && person_status != "") person_status else NA,
                Comments = if (!is.null(person_comments) && person_comments != "") person_comments else NA
              )
            }
          }
          
        } else if (data_type == "file_imed") {
          # === i/med CSV File ===
          file_input <- input[[paste0("person_", i, "_imed_file")]]
          
          if (!is.null(file_input)) {
            person_imed_data <- tryCatch({
              # Use read.csv instead of fread - more reliable for i/med format
              csv_data <- read.csv(file_input$datapath, 
                                   header = TRUE, 
                                   stringsAsFactors = FALSE,
                                   check.names = FALSE,
                                   encoding = "UTF-8")
              
              # Convert to data.table
              csv_data <- as.data.table(csv_data)
              
              # Clean column names (remove BOM and whitespace)
              colnames(csv_data) <- gsub("^\uFEFF", "", colnames(csv_data))
              colnames(csv_data) <- trimws(colnames(csv_data))
              
              # Check if required columns exist
              if (!"Marker" %in% colnames(csv_data)) {
                stop("Column 'Marker' not found in i/med CSV")
              }
              if (!"Allele 1" %in% colnames(csv_data)) {
                stop("Column 'Allele 1' not found in i/med CSV")
              }
              if (!"Allele 2" %in% colnames(csv_data)) {
                stop("Column 'Allele 2' not found in i/med CSV")
              }
              
              # Extract only the columns we need
              imed_data <- data.table(
                Marker = as.character(csv_data$Marker),
                Allele1 = as.character(csv_data$`Allele 1`),
                Allele2 = as.character(csv_data$`Allele 2`)
              )
              
              # Remove empty rows
              imed_data <- imed_data[!is.na(Marker) & Marker != ""]
              
              # Standardize marker names
              imed_data$Marker <- sapply(imed_data$Marker, standardize_marker_name)
              
              # Clean up alleles
              imed_data$Allele1 <- ifelse(is.na(imed_data$Allele1) | imed_data$Allele1 == "", "", imed_data$Allele1)
              imed_data$Allele2 <- ifelse(is.na(imed_data$Allele2) | imed_data$Allele2 == "", "", imed_data$Allele2)
              
              imed_data
              
            }, error = function(e) {
              showNotification(paste("Error reading i/med CSV file for person", i, ":", e$message), 
                               type = "error", duration = 10)
              NULL
            })
            
            if (!is.null(person_imed_data) && nrow(person_imed_data) > 0) {
              person_data_list[[paste0("Person_", i)]] <- list(
                I_MED = person_imed_data,
                PCN = if (!is.null(person_number) && !is.null(person_number_type) && 
                          person_number_type == "PCN-No." && person_number != "") person_number else NA,
                Number = if (!is.null(person_number) && person_number != "") person_number else NA,
                Number_Type = if (!is.null(person_number_type) && person_number_type != "") person_number_type else NA,
                Status = if (!is.null(person_status) && person_status != "") person_status else NA,
                Comments = if (!is.null(person_comments) && person_comments != "") person_comments else NA
              )
              
              # showNotification(paste("✅ i/med CSV loaded for Person", i, "with", nrow(person_imed_data), "markers"), 
              #                  type = "message", duration = 3)
            } else {
              showNotification(paste("⚠️ i/med CSV for Person", i, "is empty or failed to load"), 
                               type = "warning", duration = 5)
            }
          }
        }
      }
    }
    
    # Save person data to global environment
    if (length(person_data_list) > 0) {
      assign("person_data_list", person_data_list, envir = .GlobalEnv)
    }
    
    # Update person selection dropdown for comparison
    if (length(person_data_list) > 0) {
      updateSelectInput(session, "comparison_person_select",
                        choices = names(person_data_list),
                        selected = names(person_data_list)[1])
    }
    
    # Update trace selection dropdown for comparison
    if (length(trace_data_list) > 0) {
      sorted_trace_list <- sort_trace_names(names(trace_data_list))
      updateSelectInput(session, "comparison_trace_select",
                        choices = sorted_trace_list,
                        selected = sorted_trace_list[1])
    }
    
    # Summary notifications at the end
    traces_count <- length(trace_data_list)
    persons_count <- length(person_data_list)
    
    if (traces_count > 0) {
      showNotification(
        paste("✅", traces_count, "Trace(s) uploaded!"),
        type = "message", 
        duration = 3
      )
    }
    
    if (persons_count > 0) {
      showNotification(
        paste("✅", persons_count, "Person(s) uploaded!"),
        type = "message", 
        duration = 3
      )
    }
    
    # NEU: Calculate consensus immediately
    rv$traces_consensus <- recalculate_all_consensus()
    rv$consensus_updated <- rv$consensus_updated + 1
  })
  
  
  ##  CONSENSUS TABLE  ####################################################################
  # Create and display trace consensus table
  trace_consensus_data <- reactive({
    req(input$load_all_data)
    
    # Check if trace data exists in global environment
    if (exists("trace_data_list", envir = .GlobalEnv)) {
      trace_list <- get("trace_data_list", envir = .GlobalEnv)
      
      # Create consensus table
      consensus <- tryCatch({
        create_trace_consensus(trace_list)
      }, error = function(e) {
        showNotification(paste("Error creating consensus:", e$message), 
                         type = "error", duration = 5)
        NULL
      })
      
      return(consensus)
    }
    return(NULL)
  })
  
  # Create consensus for all traces
  all_traces_consensus_data <- reactive({
    # Trigger on Load All Data
    req(input$load_all_data)
    
    # Also trigger when consensus is manually updated
    rv$consensus_updated
    
    # Use stored consensus if available, otherwise recalculate
    if (!is.null(rv$traces_consensus)) {
      return(rv$traces_consensus)
    }
    
    # Calculate fresh consensus
    rv$traces_consensus <- recalculate_all_consensus()
    return(rv$traces_consensus)
  })
  
  # Render trace consensus accordions (similar to persons display)
  output$trace_consensus_accordions_display <- renderUI({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    
    if (length(traces_data) == 0) {
      return(tags$div(
        class = "alert alert-warning",
        "No trace data available. Please load data first."
      ))
    }
    
    # Sort trace names intelligently
    sorted_trace_names <- sort_trace_names(names(traces_data))
    
    # Search box UI (always shown, outside of reactive filtering)
    search_ui <- div(style = "max-width: 600px; margin-bottom: 15px;",
                     fluidRow(
                       column(6,
                              textInput("trace_search_input",
                                        "Search Traces:",
                                        value = "",
                                        placeholder = "Enter search term (e.g., E1, FG64, 2.1)...",
                                        width = "100%")
                       ),
                       column(6,
                              div(style = "margin-top: 32px;",
                                  uiOutput("trace_search_counter")
                              )
                       )
                     )
    )
    
    # Return search UI and placeholder for filtered results
    tagList(
      search_ui,
      uiOutput("trace_filtered_results")
    )
  })
  
  # Render search counter
  output$trace_search_counter <- renderUI({
    filter_result <- filtered_traces()
    req(filter_result)
    
    tags$span(
      style = "color: #666;",
      paste("Showing", length(filter_result$filtered_names), "of", length(filter_result$all_names), "trace(s)")
    )
  })
  
  # Render filtered trace results
  output$trace_filtered_results <- renderUI({
    filter_result <- filtered_traces()
    req(filter_result)
    
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    
    filtered_trace_names <- filter_result$filtered_names
    sorted_trace_names <- filter_result$all_names
    search_term <- filter_result$search_term
    
    # If no traces match the search
    if (length(filtered_trace_names) == 0) {
      return(tags$div(
        class = "alert alert-info",
        paste("No traces found matching '", search_term, "'")
      ))
    }
    
    # If only one trace (without search filter) show without accordion
    if (length(sorted_trace_names) == 1 && (is.null(search_term) || search_term == "")) {
      trace_name <- filtered_trace_names[1]
      trace_consensus <- traces_data[[trace_name]]
      
      if (is.null(trace_consensus)) return(NULL)
      
      # Get trace data for analysis
      trace_list <- get("trace_data_list", envir = .GlobalEnv)
      trace_data <- trace_list[[trace_name]]
      
      # Analysis (similar to existing trace_consensus_header)
      missing_info <- list()
      profile_messages <- list()
      kit_names <- setdiff(names(trace_data), c("PCN", "Comments"))
      
      for (kit_name in kit_names) {
        base_kit_name <- sub("_[0-9]+$", "", kit_name)
        kit_data <- trace_data[[kit_name]]
        
        # Skip if not a data.table
        if (!is.data.table(kit_data)) {
          next
        }
        
        # Check for missing markers
        if (base_kit_name %in% names(kit_expected_markers)) {
          expected_markers <- kit_expected_markers[[base_kit_name]]
          present_markers <- unique(kit_data[["Marker"]])
          missing_markers <- setdiff(expected_markers, present_markers)
          
          if (length(missing_markers) > 0) {
            missing_info[[paste0(kit_name, "_kit")]] <- paste0(kit_name, " missing: ", paste(missing_markers, collapse = ", "))
          }
        }
        
        # Profile type analysis
        max_alleles <- 0
        for (marker in unique(kit_data[["Marker"]])) {
          marker_row <- kit_data[Marker == marker]
          if (nrow(marker_row) > 0) {
            allele_cols <- names(marker_row)[grepl("^Allele [0-9]+$", names(marker_row))]
            if (length(allele_cols) > 0) {
              alleles <- as.character(marker_row[1, allele_cols, with = FALSE])
              alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
              if (length(alleles) > max_alleles) {
                max_alleles <- length(alleles)
              }
            }
          }
        }
        
        # Determine profile type
        if (length(kit_names) > 1) {
          if (max_alleles <= 2) {
            profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Single Profile")
          } else if (max_alleles <= 4) {
            profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
          } else {
            persons <- ceiling(max_alleles / 2)
            profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
          }
        } else {
          if (max_alleles <= 2) {
            profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Single Profile")
          } else if (max_alleles <= 4) {
            profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
          } else {
            persons <- ceiling(max_alleles / 2)
            profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
          }
        }
      }
      
      # Check Replicated_Alleles if multiple kits
      if (length(kit_names) > 1 && "Replicated_Alleles" %in% names(trace_consensus)) {
        max_replicated_alleles <- 0
        
        for (i in 1:nrow(trace_consensus)) {
          replicated_str <- trace_consensus$Replicated_Alleles[i]
          if (!is.na(replicated_str) && replicated_str != "") {
            alleles <- trimws(unlist(strsplit(replicated_str, "/")))
            alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
            if (length(alleles) > max_replicated_alleles) {
              max_replicated_alleles <- length(alleles)
            }
          }
        }
        
        if (max_replicated_alleles <= 2) {
          profile_messages[["Replicated"]] <- "<strong>Replicated_Alleles</strong>: Single Profile"
        } else if (max_replicated_alleles <= 4) {
          profile_messages[["Replicated"]] <- "<strong>Replicated_Alleles</strong>: Mixture Profile: min 2 Persons"
        } else {
          persons <- ceiling(max_replicated_alleles / 2)
          profile_messages[["Replicated"]] <- paste0("<strong>Replicated_Alleles</strong>: Complex Mixture Profile: min ", persons, " Persons")
        }
      }
      
      # Check missing in consensus columns
      all_alleles_missing <- trace_consensus$Marker[trace_consensus$All_Alleles == ""]
      if (length(all_alleles_missing) > 0) {
        missing_info[["all_alleles"]] <- paste0("All_Alleles missing: ", paste(all_alleles_missing, collapse = ", "))
      }
      
      if ("Replicated_Alleles" %in% names(trace_consensus)) {
        replicated_missing <- trace_consensus$Marker[trace_consensus$Replicated_Alleles == ""]
        if (length(replicated_missing) > 0) {
          missing_info[["replicated_alleles"]] <- paste0("Replicated_Alleles missing: ", paste(replicated_missing, collapse = ", "))
        }
      }
      
      pcn <- attr(trace_consensus, "PCN")
      pcn_text <- if (!is.null(pcn) && !is.na(pcn)) paste("PCN:", pcn) else "PCN: Not available"
      
      sort_input_id <- "trace_sort_single"
      
      return(tagList(
        # Header
        tags$div(
          style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 5px solid #94AA2A; margin-bottom: 15px;",
          tags$h4(trace_name, style = "margin-top: 0;"),
          tags$p(tags$strong(pcn_text), style = "margin-bottom: 5px;"),
          tags$p(paste("Total Markers:", nrow(trace_consensus)), style = "margin-bottom: 5px;"),
          
          if (length(missing_info) > 0) {
            tags$div(
              style = "color: #856404; background-color: #fff3cd; padding: 5px; border-radius: 3px; margin-bottom: 5px;",
              tags$div(HTML("<strong>⚠️ Incomplete profile:</strong>")),
              lapply(unlist(missing_info), function(msg) {
                tags$div(msg)
              })
            )
          } else {
            NULL
          },
          if (length(profile_messages) > 0) {
            tags$div(
              style = "color: #004085; background-color: #cce5ff; padding: 5px; border-radius: 3px;",
              lapply(unlist(profile_messages), function(msg) {
                tags$div(HTML(msg))
              })
            )
          } else {
            NULL
          },
          
          # NEU: Split Peak Warning
          if (!is.null(attr(trace_consensus, "split_peaks")) && length(attr(trace_consensus, "split_peaks")) > 0) {
            split_peaks <- attr(trace_consensus, "split_peaks")
            split_peak_warnings <- lapply(names(split_peaks), function(marker) {
              alleles <- split_peaks[[marker]]
              paste0("Possible split peak at <strong>", marker, "</strong>: ",
                     paste(alleles, collapse = ", "))
            })
            
            tags$div(
              class = "split-peak-warning",
              tags$div(HTML("<strong>⚠️ Warning: Possible split peaks detected. Check electropherogram!</strong>")),
              lapply(unlist(split_peak_warnings), function(msg) {
                tags$div(HTML(msg))
              })
            )
          } else {
            NULL
          },
          
          # NEU: OL Allele Warning hinzufügen:
          if (!is.null(attr(trace_consensus, "ol_alleles")) && length(attr(trace_consensus, "ol_alleles")) > 0) {
            ol_alleles <- attr(trace_consensus, "ol_alleles")
            ol_warnings <- lapply(names(ol_alleles), function(marker) {
              ol_count <- ol_alleles[[marker]]$count
              
              if (ol_count > 1) {
                # Multiple OLs - warning to check electropherogram
                paste0("<strong>⚠️ ", marker, ":</strong> ", ol_count, 
                       " OL alleles detected - <span style='text-decoration: underline;'>Please check electropherogram to verify if same peak or different peaks!</span>")
              } else {
                # Single OL
                paste0("OL allele detected at <strong>", marker, "</strong>")
              }
            })
            
            tags$div(
              style = "color: #b0156f; background-color: #fce4f0; padding: 5px; border-radius: 3px; margin-bottom: 5px;",
              tags$div(HTML("<strong style='color: #b0156f;'>⚠️ Warning: Off-Ladder (OL) alleles detected!</strong>")),
              lapply(unlist(ol_warnings), function(msg) {
                tags$div(HTML(msg))
              })
            )
          } else {
            NULL
          },
          
          # Show comments in gray box
          if (!is.null(trace_data$Comments) && !is.na(trace_data$Comments) && trace_data$Comments != "") {
            tags$div(
              style = "color: #383838; background-color: #e8e8e8; padding: 5px; border-radius: 3px; margin-top: 5px;",
              tags$span(tags$strong("Comments: "), style = "font-weight: bold;"),
              tags$span(trace_data$Comments)
            )
          } else {
            NULL
          }
        ),
        
        # 2. Split Peak Management (direkt nach Header)
        if (!is.null(attr(trace_consensus, "split_peaks")) && length(attr(trace_consensus, "split_peaks")) > 0) {
          tagList(
            br(),
            tags$div(
              style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; border-left: 3px solid #6f42c1;",
              tags$h5("Split Peak Management", style = "color: #6f42c1;"),
              tags$p("Select split peaks to remove from Replicated_Alleles column:", 
                     style = "font-size: 0.9em; margin-bottom: 10px;"),
              uiOutput(paste0("split_peak_controls_", gsub("[^[:alnum:]]", "_", trace_name)))
            ),
            br()
          )
        } else {
          NULL
        },
        
        # 2b. OL Allele Management (nach Split Peak Management)
        if (!is.null(attr(trace_consensus, "ol_alleles")) && length(attr(trace_consensus, "ol_alleles")) > 0) {
          tagList(
            br(),
            tags$div(
              style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; border-left: 3px solid #b0156f;",
              tags$h5("OL Allele Management", style = "color: #b0156f;"),
              tags$p("Rename or delete Off-Ladder alleles:", 
                     style = "font-size: 0.9em; margin-bottom: 10px;"),
              uiOutput(paste0("ol_controls_", gsub("[^[:alnum:]]", "_", trace_name)))
            ),
            br()
          )
        } else {
          NULL
        },
        
        # 3. Expert visum and download
        div(style = "max-width: 600px;",
            fluidRow(
              column(6,
                     textInput(paste0("trace_expert_visum_", gsub("[^[:alnum:]]", "_", trace_name)), 
                               "Expert Visum:",
                               value = "",
                               placeholder = "Enter your shortname",
                               width = "300px")
              ),
              column(6,
                     div(style = "margin-top: 32px;",
                         downloadButton(paste0("download_trace_", gsub("[^[:alnum:]]", "_", trace_name)), 
                                        "Export to Word", 
                                        class = "btn-primary")
                     )
              )
            )
        ),
        br(),
        
        # 4. Sort dropdown
        div(style = "max-width: 600px;",
            fluidRow(
              column(6,
                     selectInput(sort_input_id,
                                 "Sort by kit order:",
                                 choices = c("ESIf", "NGMdetect", "ESXf", "Fusion6C", 
                                             "ArgusX12QS", "Y23", "Yfiler+", "NGMselect"),
                                 selected = "NGMselect",
                                 width = "300px")
              )
            )
        ),
        
        # 5. Table
        DTOutput("trace_consensus_table_single")
      ))
    }
    
    # Multiple traces - show accordions
    accordion(
      id = "trace_consensus_accordion",
      open = FALSE,
      multiple = TRUE,
      
      lapply(filtered_trace_names, function(trace_name) {
        trace_consensus <- traces_data[[trace_name]]
        
        if (is.null(trace_consensus)) return(NULL)
        
        # Get trace data for analysis
        trace_list <- get("trace_data_list", envir = .GlobalEnv)
        trace_data <- trace_list[[trace_name]]
        
        # Analysis (similar to existing trace_consensus_header)
        missing_info <- list()
        profile_messages <- list()
        kit_names <- setdiff(names(trace_data), c("PCN", "Comments"))
        
        for (kit_name in kit_names) {
          base_kit_name <- sub("_[0-9]+$", "", kit_name)
          kit_data <- trace_data[[kit_name]]
          
          if (!is.data.table(kit_data)) {
            next
          }
          
          if (base_kit_name %in% names(kit_expected_markers)) {
            expected_markers <- kit_expected_markers[[base_kit_name]]
            present_markers <- unique(kit_data[["Marker"]])
            missing_markers <- setdiff(expected_markers, present_markers)
            
            if (length(missing_markers) > 0) {
              missing_info[[paste0(kit_name, "_kit")]] <- paste0(kit_name, " missing: ", paste(missing_markers, collapse = ", "))
            }
          }
          
          max_alleles <- 0
          for (marker in unique(kit_data[["Marker"]])) {
            marker_row <- kit_data[Marker == marker]
            if (nrow(marker_row) > 0) {
              allele_cols <- names(marker_row)[grepl("^Allele [0-9]+$", names(marker_row))]
              if (length(allele_cols) > 0) {
                alleles <- as.character(marker_row[1, allele_cols, with = FALSE])
                alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
                if (length(alleles) > max_alleles) {
                  max_alleles <- length(alleles)
                }
              }
            }
          }
          
          if (length(kit_names) > 1) {
            if (max_alleles <= 2) {
              profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Single Profile")
            } else if (max_alleles <= 4) {
              profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
            } else {
              persons <- ceiling(max_alleles / 2)
              profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
            }
          } else {
            if (max_alleles <= 2) {
              profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Single Profile")
            } else if (max_alleles <= 4) {
              profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
            } else {
              persons <- ceiling(max_alleles / 2)
              profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
            }
          }
        }
        
        if (length(kit_names) > 1 && "Replicated_Alleles" %in% names(trace_consensus)) {
          max_replicated_alleles <- 0
          
          for (i in 1:nrow(trace_consensus)) {
            replicated_str <- trace_consensus$Replicated_Alleles[i]
            if (!is.na(replicated_str) && replicated_str != "") {
              alleles <- trimws(unlist(strsplit(replicated_str, "/")))
              alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
              if (length(alleles) > max_replicated_alleles) {
                max_replicated_alleles <- length(alleles)
              }
            }
          }
          
          if (max_replicated_alleles <= 2) {
            profile_messages[["Replicated"]] <- "<strong>Replicated_Alleles</strong>: Single Profile"
          } else if (max_replicated_alleles <= 4) {
            profile_messages[["Replicated"]] <- "<strong>Replicated_Alleles</strong>: Mixture Profile: min 2 Persons"
          } else {
            persons <- ceiling(max_replicated_alleles / 2)
            profile_messages[["Replicated"]] <- paste0("<strong>Replicated_Alleles</strong>: Complex Mixture Profile: min ", persons, " Persons")
          }
        }
        
        all_alleles_missing <- trace_consensus$Marker[trace_consensus$All_Alleles == ""]
        if (length(all_alleles_missing) > 0) {
          missing_info[["all_alleles"]] <- paste0("All_Alleles missing: ", paste(all_alleles_missing, collapse = ", "))
        }
        
        if ("Replicated_Alleles" %in% names(trace_consensus)) {
          replicated_missing <- trace_consensus$Marker[trace_consensus$Replicated_Alleles == ""]
          if (length(replicated_missing) > 0) {
            missing_info[["replicated_alleles"]] <- paste0("Replicated_Alleles missing: ", paste(replicated_missing, collapse = ", "))
          }
        }
        
        pcn <- attr(trace_consensus, "PCN")
        pcn_text <- if (!is.null(pcn) && !is.na(pcn)) paste("PCN:", pcn) else "PCN: Not available"
        
        sort_input_id <- paste0("trace_sort_", gsub("[^[:alnum:]]", "_", trace_name))
        
        accordion_panel(
          title = trace_name,
          icon = bsicons::bs_icon("fingerprint"),
          
          tags$div(
            style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 5px solid #94AA2A; margin-bottom: 15px;",
            tags$h5(trace_name, style = "margin-top: 0;"),
            tags$p(tags$strong(pcn_text), style = "margin-bottom: 5px;"),
            tags$p(paste("Total Markers:", nrow(trace_consensus)), style = "margin-bottom: 5px;"),
            
            if (length(missing_info) > 0) {
              tags$div(
                style = "color: #856404; background-color: #fff3cd; padding: 5px; border-radius: 3px; margin-bottom: 5px;",
                tags$div(HTML("<strong>⚠️ Incomplete profile:</strong>")),
                lapply(unlist(missing_info), function(msg) {
                  tags$div(msg)
                })
              )
            } else {
              NULL
            },
            if (length(profile_messages) > 0) {
              tags$div(
                style = "color: #004085; background-color: #cce5ff; padding: 5px; border-radius: 3px;",
                lapply(unlist(profile_messages), function(msg) {
                  tags$div(HTML(msg))
                })
              )
            } else {
              NULL
            },
            
            # NEU: Split Peak Warning
            if (!is.null(attr(trace_consensus, "split_peaks")) && length(attr(trace_consensus, "split_peaks")) > 0) {
              split_peaks <- attr(trace_consensus, "split_peaks")
              split_peak_warnings <- lapply(names(split_peaks), function(marker) {
                alleles <- split_peaks[[marker]]
                paste0("Possible split peak at <strong>", marker, "</strong>: ",
                       paste(alleles, collapse = ", "))
              })
              
              tags$div(
                class = "split-peak-warning",
                tags$div(HTML("<strong>⚠️ Warning: Possible split peaks detected. Check electropherogram!</strong>")),
                lapply(unlist(split_peak_warnings), function(msg) {
                  tags$div(HTML(msg))
                })
              )
            } else {
              NULL
            },
            
            # Show comments in gray box
            if (!is.null(trace_data$Comments) && !is.na(trace_data$Comments) && trace_data$Comments != "") {
              tags$div(
                style = "color: #383838; background-color: #e8e8e8; padding: 5px; border-radius: 3px; margin-top: 5px;",
                tags$span(tags$strong("Comments: "), style = "font-weight: bold;"),
                tags$span(trace_data$Comments)
              )
            } else {
              NULL
            }
          ),
          # NEU: Split Peak Management UI
          if (!is.null(attr(trace_consensus, "split_peaks")) && length(attr(trace_consensus, "split_peaks")) > 0) {
            tagList(
              br(),
              tags$div(
                style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; border-left: 3px solid #6f42c1;",
                tags$h5("Split Peak Management", style = "color: #6f42c1;"),
                tags$p("Select split peaks to remove from Replicated_Alleles column:", 
                       style = "font-size: 0.9em; margin-bottom: 10px;"),
                uiOutput(paste0("split_peak_controls_", gsub("[^[:alnum:]]", "_", trace_name)))
              )
            )
          } else {
            NULL
          },
          
          # 2b. OL Allele Management (nach Split Peak Management)
          if (!is.null(attr(trace_consensus, "ol_alleles")) && length(attr(trace_consensus, "ol_alleles")) > 0) {
            tagList(
              br(),
              tags$div(
                style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; border-left: 3px solid #b0156f;",
                tags$h5("OL Allele Management", style = "color: #856404;"),
                tags$p("Rename or delete Off-Ladder alleles:", 
                       style = "font-size: 0.9em; margin-bottom: 10px;"),
                uiOutput(paste0("ol_controls_", gsub("[^[:alnum:]]", "_", trace_name)))
              )
            )
          } else {
            NULL
          },
          
          br(),
          # Expert visum and download
          div(style = "max-width: 600px;",
              fluidRow(
                column(6,
                       textInput(paste0("trace_expert_visum_", gsub("[^[:alnum:]]", "_", trace_name)),
                                 "Expert Visum:",
                                 value = "",
                                 placeholder = "Enter your shortname",
                                 width = "300px")
                ),
                column(6,
                       div(style = "margin-top: 32px;",
                           downloadButton(paste0("download_trace_", gsub("[^[:alnum:]]", "_", trace_name)), 
                                          "Export to Word", 
                                          class = "btn-primary")
                       )
                )
              )
          ),
          br(),
          #sort by kit order
          fluidRow(
            column(6,
                   selectInput(sort_input_id,
                               "Sort by kit order:",
                               choices = c("ESIf", "NGMdetect", "ESXf", "Fusion6C", 
                                           "ArgusX12QS", "Y23", "Yfiler+", "NGMselect"),
                               selected = "NGMselect")
            )
          ),
          
          DTOutput(paste0("trace_table_", gsub("[^[:alnum:]]", "_", trace_name)))
        )
      })
    )
  })
  
  # Render Split Peak controls for each trace
  observe({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    
    for (trace_name in names(traces_data)) {
      local({
        t_name <- trace_name
        
        output[[paste0("split_peak_controls_", gsub("[^[:alnum:]]", "_", t_name))]] <- renderUI({
          trace_consensus <- traces_data[[t_name]]
          split_peaks <- attr(trace_consensus, "split_peaks")
          
          if (is.null(split_peaks) || length(split_peaks) == 0) {
            return(NULL)
          }
          
          # Create checkboxes for each split peak
          controls <- lapply(names(split_peaks), function(marker) {
            alleles <- split_peaks[[marker]]
            
            # Create individual checkbox for EACH allele
            allele_checkboxes <- lapply(alleles, function(allele) {
              checkbox_id <- paste0("remove_split_", 
                                    gsub("[^[:alnum:]]", "_", t_name), 
                                    "_", marker, 
                                    "_", gsub("\\.", "_", allele))  # Replace dots in allele names
              
              div(style = "margin-left: 20px; margin-bottom: 5px;",
                  checkboxInput(
                    checkbox_id,
                    label = HTML(paste0(
                      "<span class='split-peak-allele'>", allele, "</span>"
                    )),
                    value = FALSE
                  )
              )
            })
            
            div(style = "margin-bottom: 15px;",
                tags$strong(paste0("Marker: ", marker)),
                allele_checkboxes
            )
          })
          
          tagList(
            controls,
            br(),
            actionButton(
              paste0("apply_split_changes_", gsub("[^[:alnum:]]", "_", t_name)),
              "Apply Changes",
              class = "btn-secondary",
              icon = icon("sync")
            )
          )
        })
      })
    }
  })
  
  # Render OL controls for each trace
  observe({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    
    for (trace_name in names(traces_data)) {
      local({
        t_name <- trace_name
        
        output[[paste0("ol_controls_", gsub("[^[:alnum:]]", "_", t_name))]] <- renderUI({
          trace_consensus <- traces_data[[t_name]]
          ol_alleles <- attr(trace_consensus, "ol_alleles")
          
          if (is.null(ol_alleles) || length(ol_alleles) == 0) {
            return(NULL)
          }
          
          # Create input fields for each marker with OL
          controls <- lapply(names(ol_alleles), function(marker) {
            ol_count <- ol_alleles[[marker]]$count
            
            # Warning if multiple OLs
            if (ol_count > 1) {
              warning_msg <- tags$div(
                style = "background-color: #fce4f0; padding: 8px; margin-bottom: 10px; border-left: 3px solid #b0156f;",
                tags$strong(style = "color: #b0156f;", paste0("⚠️ ", marker, ": ", ol_count, " OL alleles detected")),
                tags$br(),
                tags$span(
                  style = "color: #8a0d57; font-size: 0.9em;",
                  "Please check electropherogram to verify if this is the same peak appearing in multiple kits or different peaks. Only rename if you are certain."
                )
              )
            } else {
              warning_msg <- NULL
            }
            
            # Create input field and buttons
            input_id <- paste0("rename_ol_", 
                               gsub("[^[:alnum:]]", "_", t_name), 
                               "_", marker)
            
            allele_input <- div(style = "margin-bottom: 15px;",
                                fluidRow(
                                  column(2,
                                         tags$span(
                                           class = "ol-allele",
                                           style = "display: block; padding-top: 7px;",
                                           paste0("OL at ", marker, ":")
                                         )
                                  ),
                                  column(2,
                                         textInput(
                                           input_id,
                                           label = NULL,
                                           value = "",
                                           placeholder = "e.g., 12.3, 15.2",
                                           width = "100%"
                                         )
                                  ),
                                  column(8,
                                         div(style = "padding-top: 0px; padding-left: 0px;",
                                             actionButton(
                                               paste0("rename_ol_btn_", gsub("[^[:alnum:]]", "_", t_name), "_", marker),
                                               "Rename",
                                               class = "btn-sm",
                                               style = "background-color: #b0156f; border-color: #b0156f; color: white; margin-right: 10px;",
                                               icon = icon("exchange-alt")
                                             ),
                                             actionButton(
                                               paste0("delete_ol_", gsub("[^[:alnum:]]", "_", t_name), "_", marker),
                                               "Delete",
                                               class = "btn-sm",
                                               style = "background-color: #b0156f; border-color: #b0156f; color: white;",
                                               icon = icon("trash")
                                             )
                                         )
                                  )
                                )
            )
            
            div(style = "margin-bottom: 15px;",
                warning_msg,
                allele_input
            )
          })
          
          tagList(
            controls
          )
        })
      })
    }
  })
  
  # Render individual trace tables - for single trace display
  output$trace_consensus_table_single <- renderDT({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    req(length(traces_data) == 1)
    
    trace_consensus <- traces_data[[1]]
    req(trace_consensus)
    
    # Sort by selected kit
    trace_consensus_sorted <- trace_consensus
    selected_kit <- input$trace_sort_single
    if (!is.null(selected_kit)) {
      trace_consensus_sorted <- sort_by_kit_order(trace_consensus_sorted, selected_kit)
    }
    
    # Check if single kit
    has_replicated <- "Replicated_Alleles" %in% names(trace_consensus_sorted)
    
    # Build columnDefs conditionally
    column_defs <- list(
      list(width = '100px', targets = 0),
      list(width = '200px', targets = 1)
    )
    
    if (has_replicated) {
      column_defs[[3]] <- list(width = '150px', targets = 2)
    }
    
    # Get OL and split peak info
    ol_alleles <- attr(trace_consensus, "ol_alleles")
    split_peaks <- attr(trace_consensus, "split_peaks")
    
    # Mark OL and Split Peaks in ALL relevant columns
    needs_html <- FALSE
    
    # **MARK ALL_ALLELES COLUMN**
    if (!is.null(ol_alleles) && length(ol_alleles) > 0) {
      for (i in 1:nrow(trace_consensus_sorted)) {
        marker <- trace_consensus_sorted$Marker[i]
        
        if (marker %in% names(ol_alleles)) {
          all_alleles_text <- trace_consensus_sorted$All_Alleles[i]
          
          if (!is.na(all_alleles_text) && all_alleles_text != "") {
            # Mark "OL" in pink
            all_alleles_text <- gsub(
              "\\bOL\\b",
              '<span style="color: #b0156f; font-weight: bold;">OL</span>',
              all_alleles_text
            )
            
            # Mark renamed values in pink
            renamed_vals <- ol_alleles[[marker]]$renamed_values
            if (!is.null(renamed_vals) && length(renamed_vals) > 0) {
              for (renamed_val in renamed_vals) {
                renamed_escaped <- gsub("\\.", "\\\\.", renamed_val)
                all_alleles_text <- gsub(
                  paste0("\\b", renamed_escaped, "\\b"),
                  paste0('<span style="color: #b0156f; font-weight: bold;">', renamed_val, '</span>'),
                  all_alleles_text
                )
              }
            }
            
            trace_consensus_sorted$All_Alleles[i] <- all_alleles_text
            needs_html <- TRUE
          }
        }
      }
    }
    
    # **MARK REPLICATED_ALLELES COLUMN**
    if (has_replicated) {
      # Mark Split Peaks in purple
      if (!is.null(split_peaks) && length(split_peaks) > 0) {
        for (i in 1:nrow(trace_consensus_sorted)) {
          marker <- trace_consensus_sorted$Marker[i]
          
          if (marker %in% names(split_peaks)) {
            replicated_text <- trace_consensus_sorted$Replicated_Alleles[i]
            
            if (!is.na(replicated_text) && replicated_text != "") {
              split_alleles <- split_peaks[[marker]]
              
              for (allele in split_alleles) {
                allele_escaped <- gsub("\\.", "\\\\.", allele)
                replicated_text <- gsub(
                  paste0("\\b", allele_escaped, "\\b"),
                  paste0('<span style="color: #6f42c1; font-weight: bold;">', allele, '</span>'),
                  replicated_text
                )
              }
              
              trace_consensus_sorted$Replicated_Alleles[i] <- replicated_text
              needs_html <- TRUE
            }
          }
        }
      }
      
      # Mark OL alleles in pink
      if (!is.null(ol_alleles) && length(ol_alleles) > 0) {
        for (i in 1:nrow(trace_consensus_sorted)) {
          marker <- trace_consensus_sorted$Marker[i]
          
          if (marker %in% names(ol_alleles)) {
            replicated_text <- trace_consensus_sorted$Replicated_Alleles[i]
            
            if (!is.na(replicated_text) && replicated_text != "") {
              # Mark "OL" text in pink
              replicated_text <- gsub(
                "\\bOL\\b",
                '<span style="color: #b0156f; font-weight: bold;">OL</span>',
                replicated_text
              )
              
              # Mark renamed values in pink
              renamed_vals <- ol_alleles[[marker]]$renamed_values
              if (!is.null(renamed_vals) && length(renamed_vals) > 0) {
                for (renamed_val in renamed_vals) {
                  renamed_escaped <- gsub("\\.", "\\\\.", renamed_val)
                  replicated_text <- gsub(
                    paste0("\\b", renamed_escaped, "\\b"),
                    paste0('<span style="color: #b0156f; font-weight: bold;">', renamed_val, '</span>'),
                    replicated_text
                  )
                }
              }
              
              trace_consensus_sorted$Replicated_Alleles[i] <- replicated_text
              needs_html <- TRUE
            }
          }
        }
      }
    }
    
    # Create datatable with HTML rendering if needed
    dt <- datatable(
      trace_consensus_sorted,
      options = list(
        paging = FALSE,
        pageLength = -1,
        scrollX = TRUE,
        autoWidth = TRUE,
        columnDefs = column_defs
      ),
      rownames = FALSE,
      class = 'cell-border stripe',
      filter = 'top',
      escape = if(needs_html) FALSE else TRUE  # Only disable escaping if we added HTML
    ) %>%
      formatStyle(
        'Marker',
        fontWeight = 'bold'
      )
    
    if (has_replicated) {
      dt <- dt %>%
        formatStyle(
          'Replicated_Alleles',
          backgroundColor = styleEqual('', c('white'), default = '#d4edda'),
          color = '#155724'
        )
    }
    
    return(dt)
  })
  
  # Handle Split Peak removal
  observe({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    
    for (trace_name in names(traces_data)) {
      local({
        t_name <- trace_name
        button_id <- paste0("apply_split_changes_", gsub("[^[:alnum:]]", "_", t_name))
        
        observeEvent(input[[button_id]], {
          # Get current trace data
          if (!exists("trace_data_list", envir = .GlobalEnv)) {
            showNotification("Trace data not found", type = "error", duration = 3)
            return()
          }
          
          trace_list <- get("trace_data_list", envir = .GlobalEnv)
          
          if (!t_name %in% names(trace_list)) {
            showNotification("Selected trace not found", type = "error", duration = 3)
            return()
          }
          
          trace_data <- trace_list[[t_name]]
          
          # Get current consensus from reactive value
          if (is.null(rv$traces_consensus) || !t_name %in% names(rv$traces_consensus)) {
            showNotification("Consensus data not found. Please load data first.", type = "error", duration = 3)
            return()
          }
          
          trace_consensus <- rv$traces_consensus[[t_name]]
          split_peaks <- attr(trace_consensus, "split_peaks")
          
          if (is.null(split_peaks) || length(split_peaks) == 0) {
            showNotification("No split peaks detected", type = "warning", duration = 3)
            return()
          }
          
          # Collect which split peaks to remove (per marker and allele)
          to_remove <- list()
          
          for (marker in names(split_peaks)) {
            alleles <- split_peaks[[marker]]
            
            selected_alleles <- c()
            for (allele in alleles) {
              checkbox_id <- paste0("remove_split_", 
                                    gsub("[^[:alnum:]]", "_", t_name), 
                                    "_", marker, 
                                    "_", gsub("\\.", "_", allele))
              
              if (!is.null(input[[checkbox_id]]) && input[[checkbox_id]]) {
                selected_alleles <- c(selected_alleles, allele)
              }
            }
            
            if (length(selected_alleles) > 0) {
              to_remove[[marker]] <- selected_alleles
            }
          }
          
          if (length(to_remove) == 0) {
            # showNotification(
            #   "No split peaks selected for removal",
            #   type = "warning",
            #   duration = 3
            # )
            return()
          }
          
          # Show progress
          withProgress(message = 'Removing split peaks...', value = 0, {
            
            # Process each kit in trace_data to remove ONE occurrence of the split peak allele
            kit_names <- setdiff(names(trace_data), c("PCN", "Comments"))
            total_kits <- length(kit_names)
            
            for (kit_idx in seq_along(kit_names)) {
              kit_name <- kit_names[kit_idx]
              
              incProgress(1/total_kits, detail = paste("Processing", kit_name))
              
              kit_data <- trace_data[[kit_name]]
              
              if (!is.data.table(kit_data)) {
                kit_data <- as.data.table(kit_data)
              }
              
              if (!"Marker" %in% names(kit_data)) next
              
              # For each marker with split peaks to remove
              for (marker in names(to_remove)) {
                alleles_to_remove <- to_remove[[marker]]
                
                # Find the row with this marker
                marker_rows <- which(kit_data$Marker == marker)
                
                if (length(marker_rows) > 0) {
                  marker_row_idx <- marker_rows[1]
                  
                  # Get all allele columns
                  allele_cols <- names(kit_data)[grepl("^Allele [0-9]+$", names(kit_data))]
                  
                  # For each allele to remove
                  for (allele_to_remove in alleles_to_remove) {
                    # Find which allele columns contain this value
                    removed <- FALSE
                    
                    for (allele_col in allele_cols) {
                      current_value <- kit_data[[allele_col]][marker_row_idx]
                      
                      # If this column contains the split peak allele, remove it (set to empty)
                      if (!is.na(current_value) && as.character(current_value) == as.character(allele_to_remove) && !removed) {
                        # Remove ONLY the first occurrence
                        kit_data[[allele_col]][marker_row_idx] <- ""
                        removed <- TRUE
                        break  # Only remove one occurrence per allele
                      }
                    }
                  }
                  
                  # Clean up: shift remaining alleles to the left (remove gaps)
                  alleles_in_row <- c()
                  for (col in allele_cols) {
                    val <- kit_data[[col]][marker_row_idx]
                    if (!is.na(val) && val != "" && val != "NA") {
                      alleles_in_row <- c(alleles_in_row, as.character(val))
                    }
                    # Clear all allele columns first
                    kit_data[[col]][marker_row_idx] <- ""
                  }
                  
                  # Put non-empty alleles back in order
                  for (i in seq_along(alleles_in_row)) {
                    if (i <= length(allele_cols)) {
                      kit_data[[allele_cols[i]]][marker_row_idx] <- alleles_in_row[i]
                    }
                  }
                }
              }
              
              # Update kit data in trace_data
              trace_data[[kit_name]] <- kit_data
            }
            
            # Update trace_data in global environment
            trace_list[[t_name]] <- trace_data
            assign("trace_data_list", trace_list, envir = .GlobalEnv)
            
            # Recalculate consensus for this specific trace
            incProgress(0.2, detail = "Recalculating consensus...")
            
            updated_consensus <- tryCatch({
              create_trace_consensus(trace_data)
            }, error = function(e) {
              showNotification(paste("Error recalculating consensus:", e$message), 
                               type = "error", duration = 5)
              NULL
            })
            
            if (!is.null(updated_consensus)) {
              # Update the reactive value
              rv$traces_consensus[[t_name]] <- updated_consensus
              rv$consensus_updated <- rv$consensus_updated + 1
              
              # Show success notification
              removal_details <- sapply(names(to_remove), function(m) {
                paste0("<strong>", m, "</strong>: ", paste(to_remove[[m]], collapse = ", "))
              })
              
              showNotification(
                HTML(paste0(
                  "✓ Successfully removed ", sum(sapply(to_remove, length)), " split peak allele(s):<br/>",
                  paste(removal_details, collapse = "<br/>"),
                  "<br/><br/><strong>Table updated automatically!</strong>"
                )),
                type = "message",
                duration = 5
              )
              
              # Uncheck all checkboxes
              for (marker in names(to_remove)) {
                for (allele in to_remove[[marker]]) {
                  checkbox_id <- paste0("remove_split_", 
                                        gsub("[^[:alnum:]]", "_", t_name), 
                                        "_", marker, 
                                        "_", gsub("\\.", "_", allele))
                  updateCheckboxInput(session, checkbox_id, value = FALSE)
                }
              }
            }
          })
        })
      })
    }
  })
  
  # Handle individual OL Allele renaming (NEW - individual rename buttons)
  observe({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    
    for (trace_name in names(traces_data)) {
      local({
        t_name <- trace_name
        
        # Get OL alleles to create handlers for each rename button
        trace_consensus <- traces_data[[t_name]]
        ol_alleles <- attr(trace_consensus, "ol_alleles")
        
        if (!is.null(ol_alleles) && length(ol_alleles) > 0) {
          for (marker in names(ol_alleles)) {
            local({
              m <- marker
              rename_button_id <- paste0("rename_ol_btn_", gsub("[^[:alnum:]]", "_", t_name), "_", m)
              
              observeEvent(input[[rename_button_id]], {
                # Get current trace data
                if (!exists("trace_data_list", envir = .GlobalEnv)) {
                  showNotification("Trace data not found", type = "error", duration = 3)
                  return()
                }
                
                trace_list <- get("trace_data_list", envir = .GlobalEnv)
                
                if (!t_name %in% names(trace_list)) {
                  showNotification("Selected trace not found", type = "error", duration = 3)
                  return()
                }
                
                trace_data <- trace_list[[t_name]]
                
                # Get input value
                input_id <- paste0("rename_ol_", 
                                   gsub("[^[:alnum:]]", "_", t_name), 
                                   "_", m)
                
                new_value <- input[[input_id]]
                
                if (is.null(new_value) || new_value == "") {
                  showNotification(
                    paste("Please enter a value for", m),
                    type = "warning",
                    duration = 3
                  )
                  return()
                }
                
                # Validate input (should be numeric or decimal)
                if (!grepl("^[0-9]+(\\.[0-9]+)?$", new_value)) {
                  showNotification(
                    paste("Invalid input for", m, ": Please enter a numeric value (e.g., 12.3)"),
                    type = "warning",
                    duration = 5
                  )
                  return()
                }
                
                # **NEU: Initialisiere renamed_values Liste falls nicht vorhanden**
                if (is.null(trace_data$OL_renamed_values)) {
                  trace_data$OL_renamed_values <- list()
                }
                if (is.null(trace_data$OL_renamed_values[[m]])) {
                  trace_data$OL_renamed_values[[m]] <- character(0)
                }
                
                # **NEU: Speichere den umbenannten Wert**
                trace_data$OL_renamed_values[[m]] <- unique(c(trace_data$OL_renamed_values[[m]], new_value))
                
                # Get OL count for this marker
                ol_count <- 1  # Default
                if (!is.null(rv$traces_consensus) && t_name %in% names(rv$traces_consensus)) {
                  temp_consensus <- rv$traces_consensus[[t_name]]
                  ol_alleles_attr <- attr(temp_consensus, "ol_alleles")
                  if (!is.null(ol_alleles_attr) && m %in% names(ol_alleles_attr)) {
                    ol_count <- ol_alleles_attr[[m]]$count
                  }
                }
                
                # Show progress
                withProgress(message = paste('Renaming OL at', m, '...'), value = 0, {
                  
                  # Process each kit in trace_data to rename OL
                  kit_names <- setdiff(names(trace_data), c("PCN", "Comments", "OL_renamed_values"))
                  total_kits <- length(kit_names)
                  
                  for (kit_idx in seq_along(kit_names)) {
                    kit_name <- kit_names[kit_idx]
                    
                    incProgress(1/total_kits, detail = paste("Processing", kit_name))
                    
                    kit_data <- trace_data[[kit_name]]
                    
                    if (!is.data.table(kit_data)) {
                      kit_data <- as.data.table(kit_data)
                    }
                    
                    if (!"Marker" %in% names(kit_data)) next
                    
                    # Find the row with this marker
                    marker_rows <- which(kit_data$Marker == m)
                    
                    if (length(marker_rows) > 0) {
                      marker_row_idx <- marker_rows[1]
                      
                      # Get all allele columns
                      allele_cols <- names(kit_data)[grepl("^Allele [0-9]+$", names(kit_data))]
                      
                      # Replace ALL occurrences of "OL" with new value
                      for (allele_col in allele_cols) {
                        current_value <- kit_data[[allele_col]][marker_row_idx]
                        
                        if (!is.na(current_value) && toupper(as.character(current_value)) == "OL") {
                          kit_data[[allele_col]][marker_row_idx] <- new_value
                        }
                      }
                    }
                    
                    # Update kit data in trace_data
                    trace_data[[kit_name]] <- kit_data
                  }
                  
                  # Update trace_data in global environment
                  trace_list[[t_name]] <- trace_data
                  assign("trace_data_list", trace_list, envir = .GlobalEnv)
                  
                  # Recalculate consensus
                  incProgress(0.2, detail = "Recalculating consensus...")
                  
                  updated_consensus <- tryCatch({
                    create_trace_consensus(trace_data)
                  }, error = function(e) {
                    showNotification(paste("Error recalculating consensus:", e$message), 
                                     type = "error", duration = 5)
                    NULL
                  })
                  
                  if (!is.null(updated_consensus)) {
                    # Update the reactive value
                    rv$traces_consensus[[t_name]] <- updated_consensus
                    rv$consensus_updated <- rv$consensus_updated + 1
                    
                    # Show success notification
                    count_text <- if (ol_count > 1) paste0(" (", ol_count, " occurrences)") else ""
                    
                    showNotification(
                      HTML(paste0(
                        "✓ Successfully renamed OL at <strong>", m, "</strong>: OL → ", new_value, count_text,
                        "<br/><br/><strong>Table updated automatically!</strong>"
                      )),
                      type = "message",
                      duration = 5
                    )
                    
                    # Clear input field
                    updateTextInput(session, input_id, value = "")
                  }
                })
              })
            })
          }
        }
      })
    }
  })
  
  # Handle OL Allele deletion
  observe({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    
    for (trace_name in names(traces_data)) {
      local({
        t_name <- trace_name
        
        # Get OL alleles to create handlers for each delete button
        trace_consensus <- traces_data[[t_name]]
        ol_alleles <- attr(trace_consensus, "ol_alleles")
        
        if (!is.null(ol_alleles) && length(ol_alleles) > 0) {
          for (marker in names(ol_alleles)) {
            local({
              m <- marker
              button_id <- paste0("delete_ol_", gsub("[^[:alnum:]]", "_", t_name), "_", m)
              
              observeEvent(input[[button_id]], ignoreInit = TRUE, {
                # Get current trace data
                if (!exists("trace_data_list", envir = .GlobalEnv)) {
                  showNotification("Trace data not found", type = "error", duration = 3)
                  return()
                }
                
                trace_list <- get("trace_data_list", envir = .GlobalEnv)
                
                if (!t_name %in% names(trace_list)) {
                  showNotification("Selected trace not found", type = "error", duration = 3)
                  return()
                }
                
                trace_data <- trace_list[[t_name]]
                
                # Show confirmation dialog
                showModal(modalDialog(
                  title = HTML(paste0("<span style='color: #b0156f;'>Delete OL Allele</span>")),
                  HTML(paste0("Are you sure you want to delete all OL alleles from <strong>", m, "</strong>?<br/><br/>",
                              "<span style='color: #b0156f;'>This will remove the OL allele from all kits.</span>")),
                  footer = tagList(
                    modalButton("Cancel"),
                    actionButton(paste0("confirm_delete_ol_", gsub("[^[:alnum:]]", "_", t_name), "_", m), 
                                 "Delete", 
                                 class = "btn-danger",
                                 style = "background-color: #b0156f; border-color: #b0156f;")
                  )
                ))
              })
              
              # Handle confirmation
              observeEvent(input[[paste0("confirm_delete_ol_", gsub("[^[:alnum:]]", "_", t_name), "_", m)]], ignoreInit = TRUE, {
                removeModal()
                
                # Get trace data
                trace_list <- get("trace_data_list", envir = .GlobalEnv)
                trace_data <- trace_list[[t_name]]
                
                # Show progress
                withProgress(message = 'Deleting OL alleles...', value = 0, {
                  
                  # Process each kit in trace_data to delete OL
                  kit_names <- setdiff(names(trace_data), c("PCN", "Comments"))
                  total_kits <- length(kit_names)
                  
                  for (kit_idx in seq_along(kit_names)) {
                    kit_name <- kit_names[kit_idx]
                    
                    incProgress(1/total_kits, detail = paste("Processing", kit_name))
                    
                    kit_data <- trace_data[[kit_name]]
                    
                    if (!is.data.table(kit_data)) {
                      kit_data <- as.data.table(kit_data)
                    }
                    
                    if (!"Marker" %in% names(kit_data)) next
                    
                    # Find the row with this marker
                    marker_rows <- which(kit_data$Marker == m)
                    
                    if (length(marker_rows) > 0) {
                      marker_row_idx <- marker_rows[1]
                      
                      # Get all allele columns
                      allele_cols <- names(kit_data)[grepl("^Allele [0-9]+$", names(kit_data))]
                      
                      # Delete ALL occurrences of "OL"
                      for (allele_col in allele_cols) {
                        current_value <- kit_data[[allele_col]][marker_row_idx]
                        
                        if (!is.na(current_value) && toupper(as.character(current_value)) == "OL") {
                          kit_data[[allele_col]][marker_row_idx] <- ""
                        }
                      }
                      
                      # Clean up: shift remaining alleles to the left (remove gaps)
                      alleles_in_row <- c()
                      for (col in allele_cols) {
                        val <- kit_data[[col]][marker_row_idx]
                        if (!is.na(val) && val != "" && val != "NA") {
                          alleles_in_row <- c(alleles_in_row, as.character(val))
                        }
                        # Clear all allele columns first
                        kit_data[[col]][marker_row_idx] <- ""
                      }
                      
                      # Put non-empty alleles back in order
                      for (i in seq_along(alleles_in_row)) {
                        if (i <= length(allele_cols)) {
                          kit_data[[allele_cols[i]]][marker_row_idx] <- alleles_in_row[i]
                        }
                      }
                    }
                    
                    # Update kit data in trace_data
                    trace_data[[kit_name]] <- kit_data
                  }
                  
                  # Update trace_data in global environment
                  trace_list[[t_name]] <- trace_data
                  assign("trace_data_list", trace_list, envir = .GlobalEnv)
                  
                  # Recalculate consensus
                  incProgress(0.2, detail = "Recalculating consensus...")
                  
                  updated_consensus <- tryCatch({
                    create_trace_consensus(trace_data)
                  }, error = function(e) {
                    showNotification(paste("Error recalculating consensus:", e$message), 
                                     type = "error", duration = 5)
                    NULL
                  })
                  
                  if (!is.null(updated_consensus)) {
                    # Update the reactive value
                    rv$traces_consensus[[t_name]] <- updated_consensus
                    rv$consensus_updated <- rv$consensus_updated + 1
                    
                    # Show success notification
                    showNotification(
                      HTML(paste0(
                        "✓ Successfully deleted OL allele from <strong>", m, "</strong><br/>",
                        "<br/><strong>Table updated automatically!</strong>"
                      )),
                      type = "message",
                      duration = 5
                    )
                  }
                })
              })
            })
          }
        }
      })
    }
  })
  
  # Render individual trace tables - for multiple traces in accordions
  observe({
    traces_data <- all_traces_consensus_data()
    req(traces_data)
    req(length(traces_data) > 1)
    
    for (trace_name in names(traces_data)) {
      local({
        t_name <- trace_name
        trace_consensus <- traces_data[[t_name]]
        sort_input_id <- paste0("trace_sort_", gsub("[^[:alnum:]]", "_", t_name))
        
        output[[paste0("trace_table_", gsub("[^[:alnum:]]", "_", t_name))]] <- renderDT({
          req(trace_consensus)
          
          # Sort by THIS trace's selected kit
          trace_consensus_sorted <- trace_consensus
          selected_kit <- input[[sort_input_id]]
          if (!is.null(selected_kit)) {
            trace_consensus_sorted <- sort_by_kit_order(trace_consensus_sorted, selected_kit)
          }
          
          has_replicated <- "Replicated_Alleles" %in% names(trace_consensus_sorted)
          
          column_defs <- list(
            list(width = '100px', targets = 0),
            list(width = '200px', targets = 1)
          )
          
          if (has_replicated) {
            column_defs[[3]] <- list(width = '150px', targets = 2)
          }
          
          # Get OL and split peak info
          ol_alleles <- attr(trace_consensus, "ol_alleles")
          split_peaks <- attr(trace_consensus, "split_peaks")
          
          # Mark OL and Split Peaks in ALL relevant columns
          needs_html <- FALSE
          
          # **MARK ALL_ALLELES COLUMN**
          if (!is.null(ol_alleles) && length(ol_alleles) > 0) {
            for (i in 1:nrow(trace_consensus_sorted)) {
              marker <- trace_consensus_sorted$Marker[i]
              
              if (marker %in% names(ol_alleles)) {
                all_alleles_text <- trace_consensus_sorted$All_Alleles[i]
                
                if (!is.na(all_alleles_text) && all_alleles_text != "") {
                  # Mark "OL" in pink
                  all_alleles_text <- gsub(
                    "\\bOL\\b",
                    '<span style="color: #b0156f; font-weight: bold;">OL</span>',
                    all_alleles_text
                  )
                  
                  # Mark renamed values in pink
                  renamed_vals <- ol_alleles[[marker]]$renamed_values
                  if (!is.null(renamed_vals) && length(renamed_vals) > 0) {
                    for (renamed_val in renamed_vals) {
                      renamed_escaped <- gsub("\\.", "\\\\.", renamed_val)
                      all_alleles_text <- gsub(
                        paste0("\\b", renamed_escaped, "\\b"),
                        paste0('<span style="color: #b0156f; font-weight: bold;">', renamed_val, '</span>'),
                        all_alleles_text
                      )
                    }
                  }
                  
                  trace_consensus_sorted$All_Alleles[i] <- all_alleles_text
                  needs_html <- TRUE
                }
              }
            }
          }
          
          # **MARK REPLICATED_ALLELES COLUMN**
          if (has_replicated) {
            # Mark Split Peaks in purple
            if (!is.null(split_peaks) && length(split_peaks) > 0) {
              for (i in 1:nrow(trace_consensus_sorted)) {
                marker <- trace_consensus_sorted$Marker[i]
                
                if (marker %in% names(split_peaks)) {
                  replicated_text <- trace_consensus_sorted$Replicated_Alleles[i]
                  
                  if (!is.na(replicated_text) && replicated_text != "") {
                    split_alleles <- split_peaks[[marker]]
                    
                    for (allele in split_alleles) {
                      allele_escaped <- gsub("\\.", "\\\\.", allele)
                      replicated_text <- gsub(
                        paste0("\\b", allele_escaped, "\\b"),
                        paste0('<span style="color: #6f42c1; font-weight: bold;">', allele, '</span>'),
                        replicated_text
                      )
                    }
                    
                    trace_consensus_sorted$Replicated_Alleles[i] <- replicated_text
                    needs_html <- TRUE
                  }
                }
              }
            }
            
            # Mark OL alleles in pink
            if (!is.null(ol_alleles) && length(ol_alleles) > 0) {
              for (i in 1:nrow(trace_consensus_sorted)) {
                marker <- trace_consensus_sorted$Marker[i]
                
                if (marker %in% names(ol_alleles)) {
                  replicated_text <- trace_consensus_sorted$Replicated_Alleles[i]
                  
                  if (!is.na(replicated_text) && replicated_text != "") {
                    # Mark "OL" text in pink
                    replicated_text <- gsub(
                      "\\bOL\\b",
                      '<span style="color: #b0156f; font-weight: bold;">OL</span>',
                      replicated_text
                    )
                    
                    # Mark renamed values in pink
                    renamed_vals <- ol_alleles[[marker]]$renamed_values
                    if (!is.null(renamed_vals) && length(renamed_vals) > 0) {
                      for (renamed_val in renamed_vals) {
                        renamed_escaped <- gsub("\\.", "\\\\.", renamed_val)
                        replicated_text <- gsub(
                          paste0("\\b", renamed_escaped, "\\b"),
                          paste0('<span style="color: #b0156f; font-weight: bold;">', renamed_val, '</span>'),
                          replicated_text
                        )
                      }
                    }
                    
                    trace_consensus_sorted$Replicated_Alleles[i] <- replicated_text
                    needs_html <- TRUE
                  }
                }
              }
            }
          }
          
          # Create datatable with HTML rendering if needed
          dt <- datatable(
            trace_consensus_sorted,
            options = list(
              paging = FALSE,
              pageLength = -1,
              scrollX = TRUE,
              autoWidth = TRUE,
              columnDefs = column_defs
            ),
            rownames = FALSE,
            class = 'cell-border stripe',
            filter = 'top',
            escape = if(needs_html) FALSE else TRUE
          ) %>%
            formatStyle(
              'Marker',
              fontWeight = 'bold'
            )
          
          if (has_replicated) {
            dt <- dt %>%
              formatStyle(
                'Replicated_Alleles',
                backgroundColor = styleEqual('', c('white'), default = '#d4edda'),
                color = '#155724'
              )
          }
          
          return(dt)
        })
      })
    }
  })
  
  # Header with PCN information
  output$trace_consensus_header <- renderUI({
    consensus <- trace_consensus_data()
    req(consensus)
    
    pcn <- attr(consensus, "PCN")
    pcn_text <- if (!is.null(pcn)) paste("PCN:", pcn) else "PCN: Not available"
    
    # Get trace data to analyze each kit
    trace_list <- get("trace_data_list", envir = .GlobalEnv)
    kit_names <- setdiff(names(trace_list), c("PCN", "Comments"))
    
    # Check for missing markers per kit AND in consensus columns
    missing_info <- list()
    
    # Analyze profile type for each kit
    profile_messages <- list()
    
    for (kit_name in kit_names) {
      # Remove any _1, _2 suffixes to get base kit name
      base_kit_name <- sub("_[0-9]+$", "", kit_name)
      
      kit_data <- trace_list[[kit_name]]
      
      # Check for missing markers in individual kit
      if (base_kit_name %in% names(kit_expected_markers)) {
        expected_markers <- kit_expected_markers[[base_kit_name]]
        present_markers <- unique(kit_data[["Marker"]])
        missing_markers <- setdiff(expected_markers, present_markers)
        
        if (length(missing_markers) > 0) {
          missing_info[[paste0(kit_name, "_kit")]] <- paste0(kit_name, " missing: ", paste(missing_markers, collapse = ", "))
        }
      }
      
      # Profile type analysis
      max_alleles <- 0
      for (marker in unique(kit_data[["Marker"]])) {
        marker_row <- kit_data[Marker == marker]
        if (nrow(marker_row) > 0) {
          alleles <- as.character(marker_row[1, paste0("Allele ", 1:12), with = FALSE])
          alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
          if (length(alleles) > max_alleles) {
            max_alleles <- length(alleles)
          }
        }
      }
      
      # Determine profile type
      if (length(kit_names) > 1) {
        # Multiple kits - show kit name in BOLD
        if (max_alleles <= 2) {
          profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Single Profile")
        } else if (max_alleles <= 4) {
          profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
        } else {
          persons <- ceiling(max_alleles / 2)
          profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
        }
      } else {
        # Single kit - no kit name
        if (max_alleles <= 2) {
          profile_messages[[1]] <-  paste0("<strong>", kit_name, "</strong>: Single Profile")
        } else if (max_alleles <= 4) {
          profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
        } else {
          persons <- ceiling(max_alleles / 2)
          profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
        }
      }
    }
    
    # ANALYZE REPLICATED_ALLELES PROFILE TYPE (only for multiple kits)
    if (length(kit_names) > 1 && "Replicated_Alleles" %in% names(consensus)) {
      max_replicated_alleles <- 0
      
      for (i in 1:nrow(consensus)) {
        replicated_str <- consensus$Replicated_Alleles[i]
        if (!is.na(replicated_str) && replicated_str != "") {
          alleles <- trimws(unlist(strsplit(replicated_str, "/")))
          alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
          if (length(alleles) > max_replicated_alleles) {
            max_replicated_alleles <- length(alleles)
          }
        }
      }
      
      # Determine profile type for Replicated_Alleles - BOLD label
      if (max_replicated_alleles <= 2) {
        profile_messages[["Replicated"]] <- "<strong>Replicated_Alleles</strong>: Single Profile"
      } else if (max_replicated_alleles <= 4) {
        profile_messages[["Replicated"]] <- "<strong>Replicated_Alleles</strong>: Mixture Profile: min 2 Persons"
      } else {
        persons <- ceiling(max_replicated_alleles / 2)
        profile_messages[["Replicated"]] <- paste0("<strong>Replicated_Alleles</strong>: Complex Mixture Profile: min ", persons, " Persons")
      }
    }
    
    # Check for missing markers in All_Alleles column
    all_alleles_missing <- consensus$Marker[consensus$All_Alleles == ""]
    if (length(all_alleles_missing) > 0) {
      missing_info[["all_alleles"]] <- paste0("All_Alleles missing: ", paste(all_alleles_missing, collapse = ", "))
    }
    
    # Check for missing markers in Replicated_Alleles column (only if column exists)
    if ("Replicated_Alleles" %in% names(consensus)) {
      replicated_missing <- consensus$Marker[consensus$Replicated_Alleles == ""]
      if (length(replicated_missing) > 0) {
        missing_info[["replicated_alleles"]] <- paste0("Replicated_Alleles missing: ", paste(replicated_missing, collapse = ", "))
      }
    }
    
    tags$div(
      style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 5px solid #94AA2A;",
      tags$h4("Trace Consensus Analysis", style = "margin-top: 0;"),
      tags$p(tags$strong(pcn_text), style = "margin-bottom: 5px;"),
      tags$p(paste("Total Markers:", nrow(consensus)), style = "margin-bottom: 5px;"),
      
      if (length(missing_info) > 0) {
        tags$div(
          style = "color: #856404; background-color: #fff3cd; padding: 5px; border-radius: 3px; margin-bottom: 5px;",
          tags$div(HTML("<strong>⚠️ Incomplete profile:</strong>")),
          lapply(unlist(missing_info), function(msg) {
            tags$div(msg)
          })
        )
      } else {
        NULL
      },
      if (length(profile_messages) > 0) {
        tags$div(
          style = "color: #004085; background-color: #cce5ff; padding: 5px; border-radius: 3px;",
          lapply(unlist(profile_messages), function(msg) {
            tags$div(HTML(msg))  # Use HTML() to render the <strong> tags
          })
        )
      } else {
        NULL
      }
    )
  })
  
  # Render consensus table
  output$trace_consensus_table <- renderDT({
    consensus <- trace_consensus_data()
    req(consensus)
    
    # Sort by selected kit
    if (!is.null(input$trace_sort_kit)) {
      consensus <- sort_by_kit_order(consensus, input$trace_sort_kit)
    }
    
    # Check if single kit (only Marker and All_Alleles columns)
    has_replicated <- "Replicated_Alleles" %in% names(consensus)
    
    # Build columnDefs conditionally
    column_defs <- list(
      list(width = '100px', targets = 0),  # Marker column
      list(width = '200px', targets = 1)   # All_Alleles column
    )
    
    if (has_replicated) {
      column_defs[[3]] <- list(width = '150px', targets = 2)  # Replicated_Alleles column
    }
    
    dt <- datatable(
      consensus,
      options = list(
        paging = FALSE,
        pageLength = -1,
        scrollX = TRUE,
        autoWidth = TRUE,
        columnDefs = column_defs
      ),
      rownames = FALSE,
      class = 'cell-border stripe',
      filter = 'top'
    ) %>%
      formatStyle(
        'Marker',
        fontWeight = 'bold'
      )
    
    # Only apply Replicated_Alleles formatting if column exists
    if (has_replicated) {
      dt <- dt %>%
        formatStyle(
          'Replicated_Alleles',
          backgroundColor = styleEqual('', c('white'), default = '#d4edda'),
          color = styleEqual('', c('black'), default = '#155724')
        )
    }
    
    return(dt)
  })
  
  # Create persons consensus/display tables
  persons_consensus_data <- reactive({
    req(input$load_all_data)
    
    # Check if person data exists in global environment
    if (exists("person_data_list", envir = .GlobalEnv)) {
      person_list <- get("person_data_list", envir = .GlobalEnv)
      
      # Create consensus for each person
      persons_results <- list()
      for (person_name in names(person_list)) {
        consensus <- tryCatch({
          create_person_consensus(person_list[[person_name]])
        }, error = function(e) {
          showNotification(paste("Error creating consensus for", person_name, ":", e$message), 
                           type = "error", duration = 5)
          NULL
        })
        
        # Add metadata as attributes if consensus was created successfully
        if (!is.null(consensus)) {
          person_data <- person_list[[person_name]]
          
          if (!is.null(person_data$Number) && !is.na(person_data$Number)) {
            setattr(consensus, "Number", person_data$Number)
          }
          if (!is.null(person_data$Number_Type) && !is.na(person_data$Number_Type)) {
            setattr(consensus, "Number_Type", person_data$Number_Type)
          }
          if (!is.null(person_data$Status) && !is.na(person_data$Status)) {
            setattr(consensus, "Status", person_data$Status)
          }
          if (!is.null(person_data$Comments) && !is.na(person_data$Comments)) {
            setattr(consensus, "Comments", person_data$Comments)
          }
        }
        
        persons_results[[person_name]] <- consensus
      }
      
      return(persons_results)
    }
    return(NULL)
  })
  
  # Render persons accordions with tables - WITH INDIVIDUAL SORT DROPDOWNS
  output$persons_accordions_display <- renderUI({
    persons_data <- persons_consensus_data()
    req(persons_data)
    
    if (length(persons_data) == 0) {
      return(tags$div(
        class = "btn btn-outline-warning",
        "No person data available. Please load data first."
      ))
    }
    
    # Create accordion with one panel per person
    accordion(
      id = "persons_display_accordion",
      open = FALSE,
      multiple = TRUE,
      
      lapply(names(persons_data), function(person_name) {
        person_consensus <- persons_data[[person_name]]
        
        if (is.null(person_consensus)) return(NULL)
        
        # Get person data to check profile type
        person_list <- get("person_data_list", envir = .GlobalEnv)
        person_data <- person_list[[person_name]]
        
        # Get person metadata
        person_pcn <- attr(person_consensus, "PCN")
        person_number <- attr(person_consensus, "Number")
        person_number_type <- attr(person_consensus, "Number_Type")
        person_status <- attr(person_consensus, "Status")
        person_comments <- attr(person_consensus, "Comments")
        
        # Build PCN/Number text - only show one
        number_display_text <- NULL
        
        if (!is.null(person_number_type) && !is.na(person_number_type) && person_number_type != "") {
          if (!is.null(person_number) && !is.na(person_number) && person_number != "") {
            number_display_text <- paste0(person_number_type, ": ", person_number)
          }
        } else if (!is.null(person_pcn) && !is.na(person_pcn) && person_pcn != "") {
          number_display_text <- paste0("PCN: ", person_pcn)
        }
        
        # Check for missing markers per kit
        missing_info <- list()
        
        # Analyze profile type
        profile_messages <- list()
        
        if (("Manual" %in% names(person_data) || "CSV" %in% names(person_data) || "I_MED" %in% names(person_data)) && 
            length(setdiff(names(person_data), c("PCN", "Number", "Number_Type", "Status", "Comments"))) == 1) {
          # Manual, CSV, or I_MED data - single profile only
          if ("Manual" %in% names(person_data)) {
            simple_dt <- person_data$Manual
          } else if ("CSV" %in% names(person_data)) {
            simple_dt <- person_data$CSV
          } else {
            simple_dt <- person_data$I_MED
          }
          
          max_alleles <- 0
          
          for (i in 1:nrow(simple_dt)) {
            alleles <- c(simple_dt$Allele1[i], simple_dt$Allele2[i])
            alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
            if (length(alleles) > max_alleles) {
              max_alleles <- length(alleles)
            }
          }
          
          if (max_alleles <= 2) {
            profile_messages[[1]] <- "Single Profile"
          } else if (max_alleles <= 4) {
            profile_messages[[1]] <- "Mixture Profile: min 2 Persons"
          } else {
            persons <- ceiling(max_alleles / 2)
            profile_messages[[1]] <- paste0("Complex Mixture Profile: min ", persons, " Persons")
          }
          
        } else {
          # File data - analyze each kit
          kit_names <- setdiff(names(person_data), c("PCN", "Number", "Number_Type", "Status", "Comments"))
          
          for (kit_name in kit_names) {
            # Remove any _1, _2 suffixes to get base kit name
            base_kit_name <- sub("_[0-9]+$", "", kit_name)
            
            kit_data <- person_data[[kit_name]]
            
            # Check for missing markers
            if (base_kit_name %in% names(kit_expected_markers)) {
              expected_markers <- kit_expected_markers[[base_kit_name]]
              present_markers <- unique(kit_data[["Marker"]])
              missing_markers <- setdiff(expected_markers, present_markers)
              
              if (length(missing_markers) > 0) {
                missing_info[[paste0(kit_name, "_kit")]] <- paste0(kit_name, " missing: ", paste(missing_markers, collapse = ", "))
              }
            }
            
            # Profile type analysis
            max_alleles <- 0
            for (marker in unique(kit_data[["Marker"]])) {
              marker_row <- kit_data[Marker == marker]
              if (nrow(marker_row) > 0) {
                alleles <- as.character(marker_row[1, paste0("Allele ", 1:12), with = FALSE])
                alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
                if (length(alleles) > max_alleles) {
                  max_alleles <- length(alleles)
                }
              }
            }
            
            # Determine profile type
            if (length(kit_names) > 1) {
              # Multiple kits - show kit name in BOLD
              if (max_alleles <= 2) {
                profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Single Profile")
              } else if (max_alleles <= 4) {
                profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
              } else {
                persons <- ceiling(max_alleles / 2)
                profile_messages[[kit_name]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
              }
            } else {
              # Single kit - show kit name with bold
              if (max_alleles <= 2) {
                profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Single Profile")
              } else if (max_alleles <= 4) {
                profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Mixture Profile: min 2 Persons")
              } else {
                persons <- ceiling(max_alleles / 2)
                profile_messages[[1]] <- paste0("<strong>", kit_name, "</strong>: Complex Mixture Profile: min ", persons, " Persons")
              }
            }
          }
        }
        
        # Check for missing markers in All_Alleles column
        all_alleles_missing <- person_consensus$Marker[person_consensus$All_Alleles == ""]
        
        # For Manual/CSV data, exclude optional markers from warning
        if (("Manual" %in% names(person_data) || "CSV" %in% names(person_data)) && 
            length(setdiff(names(person_data), c("PCN", "Number", "Number_Type", "Status", "Comments"))) == 1) {
          optional_markers <- c("TPOX", "CSF1PO", "D13S317", "D7S820", "D5S818", "PentaD", "PentaE")
          all_alleles_missing <- setdiff(all_alleles_missing, optional_markers)
        }
        
        if (length(all_alleles_missing) > 0) {
          missing_info[["all_alleles"]] <- paste0("All_Alleles missing: ", paste(all_alleles_missing, collapse = ", "))
        }
        
        # Check for missing markers in Replicated_Alleles column (only if column exists)
        if ("Replicated_Alleles" %in% names(person_consensus)) {
          replicated_missing <- person_consensus$Marker[person_consensus$Replicated_Alleles == ""]
          if (length(replicated_missing) > 0) {
            missing_info[["replicated_alleles"]] <- paste0("Replicated_Alleles missing: ", paste(replicated_missing, collapse = ", "))
          }
        }
        
        # Determine if it's manual (only 2 columns) or file-based (more columns)
        is_manual <- ncol(person_consensus) == 2
        
        # Create unique sort input ID for this person
        sort_input_id <- paste0("person_sort_", gsub("[^[:alnum:]]", "_", person_name))
        
        accordion_panel(
          title = person_name,
          icon = bsicons::bs_icon("person-badge"),
          
          # Header
          tags$div(
            style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 5px solid #C56824; margin-bottom: 15px;",
            tags$h5(person_name, style = "margin-top: 0;"),
            
            # Show number/PCN
            if (!is.null(number_display_text)) {
              tags$p(tags$strong(number_display_text), style = "margin-bottom: 5px;")
            } else {
              NULL
            },
            
            # Show status
            if (!is.null(person_status) && !is.na(person_status) && person_status != "") {
              tags$p(tags$strong(paste("Status:", person_status)), style = "margin-bottom: 5px;")
            } else {
              NULL
            },
            
            # Show comments in gray box
            if (!is.null(person_comments) && !is.na(person_comments) && person_comments != "") {
              tags$div(
                style = "color: #383838; background-color: #e8e8e8; padding: 5px; border-radius: 3px; margin-bottom: 5px; margin-top: 5px;",
                tags$span(tags$strong("Comments: "), style = "font-weight: bold;"),
                tags$span(person_comments)
              )
            } else {
              NULL
            },
            
            tags$p(paste("Total Markers:", nrow(person_consensus)), style = "margin-bottom: 5px;"),
            
            if (length(missing_info) > 0) {
              tags$div(
                style = "color: #856404; background-color: #fff3cd; padding: 5px; border-radius: 3px; margin-bottom: 5px;",
                tags$div(HTML("<strong>⚠️ Incomplete profile:</strong>")),
                lapply(unlist(missing_info), function(msg) {
                  tags$div(msg)
                })
              )
            } else {
              NULL
            },
            if (length(profile_messages) > 0) {
              tags$div(
                style = "color: #004085; background-color: #cce5ff; padding: 5px; border-radius: 3px;",
                lapply(unlist(profile_messages), function(msg) {
                  tags$div(HTML(msg))
                })
              )
            } else {
              NULL
            }
          ),
          
          # Sort dropdown for THIS person
          br(),
          fluidRow(
            column(2,
                   selectInput(sort_input_id,
                               "Sort by kit order:",
                               choices = c("ESIf", "NGMdetect", "ESXf", "Fusion6C", 
                                           "ArgusX12QS", "Y23", "Yfiler+", "NGMselect"),
                               selected = "NGMselect")
            )
          ),
          
          # Table
          DTOutput(paste0("person_table_", gsub("[^[:alnum:]]", "_", person_name)))
        )
      })
    )
  })
  
  # Render individual person tables - USING INDIVIDUAL SORT INPUTS
  observe({
    persons_data <- persons_consensus_data()
    req(persons_data)
    
    for (person_name in names(persons_data)) {
      local({
        p_name <- person_name
        person_consensus <- persons_data[[p_name]]
        sort_input_id <- paste0("person_sort_", gsub("[^[:alnum:]]", "_", p_name))
        
        output[[paste0("person_table_", gsub("[^[:alnum:]]", "_", p_name))]] <- renderDT({
          req(person_consensus)
          
          # Sort by THIS person's selected kit
          person_consensus_sorted <- person_consensus
          selected_kit <- input[[sort_input_id]]
          if (!is.null(selected_kit)) {
            person_consensus_sorted <- sort_by_kit_order(person_consensus_sorted, selected_kit)
          }
          
          datatable(
            person_consensus_sorted,
            options = list(
              paging = FALSE,
              pageLength = -1,
              scrollX = TRUE,
              autoWidth = TRUE,
              columnDefs = list(
                list(width = '100px', targets = 0),  # Marker column
                list(width = '200px', targets = 1)   # All_Alleles column
              )
            ),
            rownames = FALSE,
            class = 'cell-border stripe',
            filter = 'top'
          ) %>%
            formatStyle(
              'Marker',
              fontWeight = 'bold'
            ) %>%
            {
              # Only add Replicated_Alleles styling if column exists
              if ("Replicated_Alleles" %in% names(person_consensus)) {
                formatStyle(
                  .,
                  'Replicated_Alleles',
                  backgroundColor = styleInterval(0, c('white', '#d4edda')),
                  color = styleInterval(0, c('black', '#155724'))
                )
              } else {
                .
              }
            }
        })
      })
    }
  })
  
  
  ##  TRACE VS PERSON COMPARISON  ####################################################################
  # Create comparison data for all persons that were selected
  comparison_data_list <- reactive({
    req(input$comparison_trace_select)
    req(input$comparison_person_select)
    req(length(input$comparison_person_select) > 0)
    req(input$load_all_data)
    
    traces_consensus <- all_traces_consensus_data()
    persons_consensus <- persons_consensus_data()
    
    req(traces_consensus, persons_consensus)
    
    selected_trace <- input$comparison_trace_select
    selected_persons <- input$comparison_person_select
    
    trace_consensus <- traces_consensus[[selected_trace]]
    req(trace_consensus)
    
    # Get PCNs
    trace_pcn <- attr(trace_consensus, "PCN")
    
    # Create comparison for each selected person
    comparisons <- list()
    
    for (person_name in selected_persons) {
      if (person_name %in% names(persons_consensus)) {
        person_consensus <- persons_consensus[[person_name]]
        person_pcn <- attr(person_consensus, "PCN")
        
        # Create comparison
        comparison <- create_comparison_table(trace_consensus, person_consensus, trace_pcn, person_pcn)
        
        # Add metadata
        setattr(comparison, "Trace_Name", selected_trace)
        setattr(comparison, "Person_Name", person_name)
        setattr(comparison, "Trace_PCN", trace_pcn)
        setattr(comparison, "Person_PCN", person_pcn)
        setattr(comparison, "Person_Number", attr(person_consensus, "Number"))
        setattr(comparison, "Person_Number_Type", attr(person_consensus, "Number_Type"))
        setattr(comparison, "Person_Status", attr(person_consensus, "Status"))
        setattr(comparison, "Person_Comments", attr(person_consensus, "Comments"))
        
        if (exists("trace_data_list", envir = .GlobalEnv)) {
          trace_list <- get("trace_data_list", envir = .GlobalEnv)
          if (selected_trace %in% names(trace_list)) {
            trace_data <- trace_list[[selected_trace]]
            kit_names <- setdiff(names(trace_data), c("PCN", "Comments"))
            setattr(comparison, "Trace_Kit_Names", kit_names)
          }
        }
        
        comparisons[[person_name]] <- comparison
      }
    }
    
    return(comparisons)
  })
  
  
  output$comparison_tables_display <- renderUI({
    comparisons <- comparison_data_list()
    req(comparisons)
    req(length(comparisons) > 0)
    
    if (length(comparisons) == 0) {
      return(NULL)
    }
    
    # Create one section per person
    table_sections <- lapply(names(comparisons), function(person_name) {
      comparison <- comparisons[[person_name]]
      
      tagList(
        # Person header
        tags$div(
          style = "background-color: #e7f3ff; padding: 10px; border-left: 4px solid #0066cc; margin-bottom: 10px; margin-top: 20px;",
          tags$h4(paste("Person:", person_name), style = "margin: 0; color: #0066cc;")
        ),
        
        # Comparison header
        uiOutput(paste0("comp_header_", gsub("[^[:alnum:]]", "_", person_name))),
        
        br(),
        
        # Sort dropdown
        div(style = "max-width: 600px;",
            fluidRow(
              column(6,
                     selectInput(paste0("comp_sort_kit_", gsub("[^[:alnum:]]", "_", person_name)),
                                 "Sort by kit order:",
                                 choices = c("ESIf", "NGMdetect", "ESXf", "Fusion6C", 
                                             "ArgusX12QS", "Y23", "Yfiler+", "NGMselect"),
                                 selected = "NGMselect",
                                 width = "300px")
              )
            )
        ),
        
        br(),
        
        # Table
        DTOutput(paste0("comp_table_", gsub("[^[:alnum:]]", "_", person_name))),
        
        br(),
        hr(),
        br()
      )
    })
    
    tagList(table_sections)
  })
  
  # Render individual comparison headers
  observe({
    comparisons <- comparison_data_list()
    req(comparisons)
    
    for (person_name in names(comparisons)) {
      local({
        p_name <- person_name
        comparison <- comparisons[[p_name]]
        
        output[[paste0("comp_header_", gsub("[^[:alnum:]]", "_", p_name))]] <- renderUI({
          trace_pcn <- attr(comparison, "Trace_PCN")
          person_pcn <- attr(comparison, "Person_PCN")
          trace_name <- attr(comparison, "Trace_Name")
          person_number <- attr(comparison, "Person_Number")
          person_number_type <- attr(comparison, "Person_Number_Type")
          person_status <- attr(comparison, "Person_Status")
          
          # Build trace display
          trace_display <- if (!is.null(trace_name)) {
            if (!is.null(trace_pcn) && !is.na(trace_pcn)) {
              paste0("<strong>Trace:</strong> ", trace_name, " (PCN-No. ", trace_pcn, ")")
            } else {
              paste0("<strong>Trace:</strong> ", trace_name)
            }
          } else {
            if (!is.null(trace_pcn) && !is.na(trace_pcn)) {
              paste0("<strong>Trace PCN-No.:</strong> ", trace_pcn)
            } else {
              "<strong>Trace:</strong> Not available"
            }
          }
          
          # Build person display
          person_display <- if (!is.null(p_name)) {
            person_text <- p_name
            if (!is.null(person_number_type) && !is.na(person_number_type) && person_number_type != "") {
              if (!is.null(person_number) && !is.na(person_number) && person_number != "") {
                person_text <- paste0(person_text, " (", person_number_type, " ", person_number, ")")
              }
            }
            paste0("<strong>Person:</strong> ", person_text)
          } else {
            "<strong>Person:</strong> Not selected"
          }
          
          # Count red and orange alleles
          red_count <- 0
          orange_count <- 0
          
          for (i in 1:nrow(comparison)) {
            person_text <- comparison$Person[i]
            trace_text <- comparison$Trace[i]
            
            if (!is.na(person_text) && person_text != "" && !is.na(trace_text) && trace_text != "") {
              trace_all_text <- gsub(" /…", "", trace_text)
              trace_alleles <- trimws(unlist(strsplit(trace_all_text, "/")))
              
              trace_regular <- trace_alleles[!grepl("^\\(.*\\)$", trace_alleles)]
              trace_parentheses <- gsub("[()]", "", trace_alleles[grepl("^\\(.*\\)$", trace_alleles)])
              
              person_alleles <- trimws(unlist(strsplit(person_text, "/")))
              
              for (allele in person_alleles) {
                if (allele %in% trace_regular) {
                  # Normal
                } else if (allele %in% trace_parentheses) {
                  orange_count <- orange_count + 1
                } else {
                  red_count <- red_count + 1
                }
              }
            }
          }
          
          color_messages <- list()
          if (red_count > 0 || orange_count > 0) {
            if (red_count > 0) {
              color_messages[["red"]] <- paste0("<span style='color: red;'>Absent alleles</span>: ", red_count)
            }
            if (orange_count > 0) {
              color_messages[["orange"]] <- paste0("<span style='color: orange;'>Single-copy alleles</span>: ", orange_count)
            }
          }
          
          tags$div(
            style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 5px solid #7EB5A6;",
            tags$p(tags$strong(HTML(trace_display)), style = "margin-bottom: 5px;"),
            tags$p(tags$strong(HTML(person_display)), style = "margin-bottom: 5px;"),
            tags$p(paste("Total Markers:", nrow(comparison)), style = "margin-bottom: 15px;"),
            
            if (length(color_messages) > 0) {
              tags$div(
                style = "color: #004085; background-color: #cce5ff; padding: 5px; border-radius: 3px;",
                lapply(unlist(color_messages), function(msg) {
                  tags$div(HTML(msg))
                })
              )
            } else {
              NULL
            }
          )
        })
      })
    }
  })
  
  # Render individual comparison tables
  observe({
    comparisons <- comparison_data_list()
    req(comparisons)
    
    for (person_name in names(comparisons)) {
      local({
        p_name <- person_name
        comparison <- comparisons[[p_name]]
        sort_input_id <- paste0("comp_sort_kit_", gsub("[^[:alnum:]]", "_", p_name))
        
        output[[paste0("comp_table_", gsub("[^[:alnum:]]", "_", p_name))]] <- renderDT({
          req(comparison)
          
          # Sort by selected kit for THIS person
          comparison_sorted <- copy(comparison)
          selected_kit <- input[[sort_input_id]]
          if (!is.null(selected_kit)) {
            temp_for_sort <- copy(comparison_sorted)
            temp_for_sort$Marker <- temp_for_sort$System
            temp_for_sort <- sort_by_kit_order(temp_for_sort, selected_kit)
            comparison_sorted <- temp_for_sort[, .(System, Trace, Person, Reproduced_Match)]
          }
          
          # Get PCNs for column headers
          trace_pcn <- attr(comparison, "Trace_PCN")
          person_pcn <- attr(comparison, "Person_PCN")
          
          # Create formatted display
          comparison_display <- copy(comparison_sorted)
          
          for (i in 1:nrow(comparison_display)) {
            reproduced_match <- comparison_display$Reproduced_Match[i]
            trace_text <- comparison_display$Trace[i]
            person_text <- comparison_display$Person[i]
            
            # Format Trace column
            if (!is.na(trace_text) && trace_text != "") {
              if (!is.na(person_text) && person_text != "") {
                person_alleles_list <- trimws(unlist(strsplit(person_text, "/")))
                
                for (allele in person_alleles_list) {
                  allele_escaped <- gsub("\\.", "\\\\.", allele)
                  
                  trace_text <- gsub(paste0("(?<![0-9.(])\\b", allele_escaped, "\\b(?![0-9.)])"), 
                                     paste0("<b>", allele, "</b>"), 
                                     trace_text, perl = TRUE)
                  
                  trace_text <- gsub(paste0("\\(", allele_escaped, "\\)"), 
                                     paste0("<b>(", allele, ")</b>"), 
                                     trace_text, perl = TRUE)
                }
                comparison_display$Trace[i] <- trace_text
              }
            }
            
            # Format Person column
            if (!is.na(person_text) && person_text != "" && !is.na(trace_text) && trace_text != "") {
              trace_all_text <- comparison_sorted$Trace[i]
              trace_all_text <- gsub(" /…", "", trace_all_text)
              trace_alleles <- trimws(unlist(strsplit(trace_all_text, "/")))
              
              trace_regular <- trace_alleles[!grepl("^\\(.*\\)$", trace_alleles)]
              trace_parentheses <- gsub("[()]", "", trace_alleles[grepl("^\\(.*\\)$", trace_alleles)])
              
              person_alleles <- trimws(unlist(strsplit(person_text, "/")))
              
              person_parts <- c()
              for (allele in person_alleles) {
                if (allele %in% trace_regular) {
                  person_parts <- c(person_parts, allele)
                } else if (allele %in% trace_parentheses) {
                  person_parts <- c(person_parts, paste0("<span style='color: orange;'>", allele, "</span>"))
                } else {
                  person_parts <- c(person_parts, paste0("<span style='color: red;'>", allele, "</span>"))
                }
              }
              
              comparison_display$Person[i] <- paste(person_parts, collapse = " / ")
            }
          }
          
          # Prepare display table
          display_table <- comparison_display[, .(System, Trace, Person)]
          
          # Column headers
          trace_header <- if (!is.null(trace_pcn) && !is.na(trace_pcn)) {
            paste0("Trace<br/><span style='font-weight:normal;'>PCN-No. ", trace_pcn, "</span>")
          } else {
            "Trace"
          }
          
          person_header <- "Person"
          if (!is.null(person_pcn) && !is.na(person_pcn)) {
            person_header <- paste0("Person<br/><span style='font-weight:normal;'>PCN: ", person_pcn, "</span>")
          }
          
          datatable(
            display_table,
            options = list(
              paging = FALSE,
              pageLength = -1,
              scrollX = TRUE,
              autoWidth = TRUE,
              columnDefs = list(
                list(width = '120px', targets = 0),
                list(width = '300px', targets = 1),
                list(width = '300px', targets = 2)
              )
            ),
            colnames = c("System", trace_header, person_header),
            rownames = FALSE,
            class = 'cell-border stripe',
            filter = 'top',
            escape = FALSE
          ) %>%
            formatStyle('System', fontWeight = 'bold')
        })
      })
    }
  })
  
  
  
  # Translation helper functions
  translate_person_status_to_german <- function(status) {
    if (is.null(status) || is.na(status) || status == "") return("")
    
    translations <- c(
      "Suspect" = "Tatverdächtige(r)",
      "Authorized Person" = "Tatortberechtigte(r)",
      "Staff" = "Staff",
      "Victim" = "Geschädigte(r)"
    )
    
    if (status %in% names(translations)) {
      return(translations[[status]])
    }
    return(status)  # Fallback to original if not found
  }
  
  translate_number_type_to_german <- function(number_type) {
    if (is.null(number_type) || is.na(number_type) || number_type == "") return("")
    
    translations <- c(
      "IRM-No." = "IRM-Nr.",
      "Ass.-No." = "Ass.-Nr.",
      "PCN-No." = "PCN-Nr."
    )
    
    if (number_type %in% names(translations)) {
      return(translations[[number_type]])
    }
    return(number_type)  # Fallback to original if not found
  }
  
  # Download handler for Word export
  # german
  output$download_comparison_de <- downloadHandler(
    filename = function() {
      case_number <- NULL
      selected_trace <- input$comparison_trace_select
      
      if (!is.null(selected_trace) && exists("trace_data_list", envir = .GlobalEnv)) {
        trace_list <- get("trace_data_list", envir = .GlobalEnv)
        
        if (selected_trace %in% names(trace_list)) {
          trace_data <- trace_list[[selected_trace]]
          kit_names <- setdiff(names(trace_data), c("PCN", "Comments"))
          
          if (length(kit_names) > 0) {
            first_kit <- trace_data[[kit_names[1]]]
            if ("Sample Name" %in% names(first_kit)) {
              sample_name <- first_kit$`Sample Name`[1]
              if (!is.null(sample_name) && !is.na(sample_name) && sample_name != "") {
                result <- extract_case_number(sample_name)
                case_number <- result$case_number
              }
            }
          }
        }
      }
      
      if (is.null(case_number) && !is.null(selected_trace)) {
        case_number <- gsub("^Trace_", "", selected_trace)
      }
      
      expert_visum <- input$expert_visum
      if (is.null(expert_visum)) expert_visum <- ""
      expert_visum <- trimws(expert_visum)
      
      selected_kit <- input$comparison_sort_kit
      if (is.null(selected_kit)) selected_kit <- "NGMselect"
      
      num_persons <- length(input$comparison_person_select)
      person_suffix <- if (num_persons > 1) "Alle" else input$comparison_person_select[1]
      
      filename_parts <- c()
      if (!is.null(case_number) && case_number != "") {
        filename_parts <- c(filename_parts, case_number)
      }
      filename_parts <- c(filename_parts, "Vergleich", person_suffix)
      if (expert_visum != "") {
        filename_parts <- c(filename_parts, expert_visum)
      }
      
      if (length(filename_parts) > 0) {
        paste0(paste(filename_parts, collapse = "-"), ".docx")
      } else {
        paste0("Spur_vs_Person_Vergleich.docx")
      }
    },
    
    content = function(file) {
      create_multi_person_word_document(
        file = file,
        comparison_data_list = comparison_data_list(),
        input = input,
        language = "de",
        translate_status_fn = translate_person_status_to_german,
        translate_type_fn = translate_number_type_to_german
      )
    },
    contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  )
  
  # Download handler for English Word export
  output$download_comparison_en <- downloadHandler(
    filename = function() {
      case_number <- NULL
      selected_trace <- input$comparison_trace_select
      
      if (!is.null(selected_trace) && exists("trace_data_list", envir = .GlobalEnv)) {
        trace_list <- get("trace_data_list", envir = .GlobalEnv)
        
        if (selected_trace %in% names(trace_list)) {
          trace_data <- trace_list[[selected_trace]]
          kit_names <- setdiff(names(trace_data), c("PCN", "Comments"))
          
          if (length(kit_names) > 0) {
            first_kit <- trace_data[[kit_names[1]]]
            if ("Sample Name" %in% names(first_kit)) {
              sample_name <- first_kit$`Sample Name`[1]
              if (!is.null(sample_name) && !is.na(sample_name) && sample_name != "") {
                result <- extract_case_number(sample_name)
                case_number <- result$case_number
              }
            }
          }
        }
      }
      
      if (is.null(case_number) && !is.null(selected_trace)) {
        case_number <- gsub("^Trace_", "", selected_trace)
      }
      
      expert_visum <- input$expert_visum
      if (is.null(expert_visum)) expert_visum <- ""
      expert_visum <- trimws(expert_visum)
      
      selected_kit <- input$comparison_sort_kit
      if (is.null(selected_kit)) selected_kit <- "NGMselect"
      
      num_persons <- length(input$comparison_person_select)
      person_suffix <- if (num_persons > 1) "All" else input$comparison_person_select[1]
      
      filename_parts <- c()
      if (!is.null(case_number) && case_number != "") {
        filename_parts <- c(filename_parts, case_number)
      }
      filename_parts <- c(filename_parts, "Comparison", person_suffix)
      if (expert_visum != "") {
        filename_parts <- c(filename_parts, expert_visum)
      }
      
      if (length(filename_parts) > 0) {
        paste0(paste(filename_parts, collapse = "-"), ".docx")
      } else {
        paste0("Trace_vs_Person_Comparison.docx")
      }
    },
    
    content = function(file) {
      create_multi_person_word_document(
        file = file,
        comparison_data_list = comparison_data_list(),
        input = input,
        language = "en",
        translate_status_fn = function(x) x,
        translate_type_fn = function(x) x
      )
    },
    contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  )
  
  # Create download handlers immediately when traces are loaded
  observe({
    traces_data <- all_traces_consensus_data()
    if (is.null(traces_data)) return()
    
    # Check if we have only one trace (single display)
    if (length(traces_data) == 1) {
      trace_name <- names(traces_data)[1]
      handler_id <- paste0("download_trace_", gsub("[^[:alnum:]]", "_", trace_name))
      
      # Create handler for single trace
      output[[handler_id]] <- downloadHandler(
        filename = function() {
          case_number <- gsub("^Trace_", "", trace_name)
          expert_visum <- input[["trace_expert_visum_single"]]
          if (is.null(expert_visum)) expert_visum <- ""
          expert_visum <- trimws(expert_visum)
          
          filename_parts <- c()
          if (!is.null(case_number) && case_number != "") {
            filename_parts <- c(filename_parts, case_number)
          }
          filename_parts <- c(filename_parts, "TraceConsensus")
          if (expert_visum != "") {
            filename_parts <- c(filename_parts, expert_visum)
          }
          
          paste0(paste(filename_parts, collapse = "-"), ".docx")
        },
        
        content = function(file) {
          traces_data <- all_traces_consensus_data()
          consensus <- traces_data[[trace_name]]
          req(consensus)
          
          selected_kit <- input$trace_sort_single
          if (is.null(selected_kit)) selected_kit <- "ESIf"
          
          consensus <- copy(consensus)
          consensus <- sort_by_kit_order(consensus, selected_kit)
          
          trace_pcn <- attr(consensus, "PCN")
          export_table <- copy(consensus)
          
          # Create flextable
          ft <- flextable(export_table)
          
          if ("Replicated_Alleles" %in% names(export_table)) {
            ft <- set_header_labels(ft,
                                    Marker = "Marker",
                                    All_Alleles = "All Alleles",
                                    Replicated_Alleles = "Replicated Alleles")
          } else {
            ft <- set_header_labels(ft,
                                    Marker = "Marker",
                                    All_Alleles = "All Alleles")
          }
          
          ft <- bold(ft, part = "header")
          ft <- bold(ft, j = 1)
          ft <- align(ft, align = "left", part = "all")
          ft <- width(ft, j = 1, width = 1.2, unit = "in")
          ft <- width(ft, j = 2, width = 2.5, unit = "in")
          if ("Replicated_Alleles" %in% names(export_table)) {
            ft <- width(ft, j = 3, width = 1.8, unit = "in")
          }
          ft <- font(ft, fontname = "Arial", part = "all")
          ft <- fontsize(ft, size = 11, part = "all")
          
          doc <- read_docx()
          
          case_number <- gsub("^Trace_", "", trace_name)
          expert_visum <- input[["trace_expert_visum_single"]]
          if (is.null(expert_visum)) expert_visum <- ""
          expert_visum <- trimws(expert_visum)
          
          fp_normal <- fp_text(font.family = "Arial", font.size = 11)
          fp_heading <- fp_text(font.family = "Arial", font.size = 11, bold = TRUE)
          
          doc <- body_add_fpar(doc, fpar(ftext("SmarTRace: Trace Consensus Table", prop = fp_heading)))
          doc <- body_add_fpar(doc, fpar(ftext(paste("Generated:", Sys.Date()), prop = fp_normal)))
          
          if (!is.null(trace_name)) {
            doc <- body_add_fpar(doc, fpar(ftext(paste("Trace:", trace_name), prop = fp_normal)))
          }
          
          if (!is.null(case_number) && case_number != "") {
            doc <- body_add_fpar(doc, fpar(ftext(paste("Case Number:", case_number), prop = fp_normal)))
          }
          
          if (expert_visum != "") {
            doc <- body_add_fpar(doc, fpar(ftext(paste("Expert Visum:", expert_visum), prop = fp_normal)))
          }
          
          if (!is.null(trace_pcn) && !is.na(trace_pcn)) {
            doc <- body_add_fpar(doc, fpar(ftext(paste("Trace PCN:", trace_pcn), prop = fp_normal)))
          }
          
          doc <- body_add_fpar(doc, fpar(ftext(paste("Sorted by:", selected_kit, "kit"), prop = fp_normal)))
          doc <- body_add_par(doc, "", style = "Normal")
          doc <- body_add_flextable(doc, ft)
          
          print(doc, target = file)
        },
        contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      )
    }
  })
  
  # Dynamic download handlers for all traces - OPTIMIZED
  observeEvent(all_traces_consensus_data(), {
    traces_data <- all_traces_consensus_data()
    if (is.null(traces_data)) return()
    
    # DEBUG OUTPUT
    cat("=== TRACES LOADED ===\n")
    cat("Number of traces:", length(traces_data), "\n")
    cat("Trace names:", paste(names(traces_data), collapse = ", "), "\n")
    
    for (trace_name in names(traces_data)) {
      local({
        t_name <- trace_name
        
        handler_id <- paste0("download_trace_", gsub("[^[:alnum:]]", "_", t_name))
        cat("Creating handler:", handler_id, "for trace:", t_name, "\n")
        
        output[[handler_id]] <- downloadHandler(
          filename = function() {
            # Get case number
            case_number <- gsub("^Trace_", "", t_name)
            
            # Get expert visum for THIS trace
            expert_visum_input_id <- paste0("trace_expert_visum_", gsub("[^[:alnum:]]", "_", t_name))
            expert_visum <- input[[expert_visum_input_id]]
            if (is.null(expert_visum)) expert_visum <- ""
            expert_visum <- trimws(expert_visum)
            
            # Build filename
            filename_parts <- c()
            if (!is.null(case_number) && case_number != "") {
              filename_parts <- c(filename_parts, case_number)
            }
            filename_parts <- c(filename_parts, "TraceConsensus")
            if (expert_visum != "") {
              filename_parts <- c(filename_parts, expert_visum)
            }
            
            paste0(paste(filename_parts, collapse = "-"), ".docx")
          },
          
          content = function(file) {
            # Get fresh data when download is triggered
            traces_data <- all_traces_consensus_data()
            consensus <- traces_data[[t_name]]
            req(consensus)
            
            # Get sort kit for THIS trace
            sort_input_id <- if (length(traces_data) == 1) {
              "trace_sort_single"
            } else {
              paste0("trace_sort_", gsub("[^[:alnum:]]", "_", t_name))
            }
            
            selected_kit <- input[[sort_input_id]]
            if (is.null(selected_kit)) selected_kit <- "ESIf"
            
            consensus <- copy(consensus)
            consensus <- sort_by_kit_order(consensus, selected_kit)
            
            # Get PCN
            trace_pcn <- attr(consensus, "PCN")
            
            # Prepare export table
            export_table <- copy(consensus)
            
            # Create flextable
            ft <- flextable(export_table)
            
            # Set column headers
            if ("Replicated_Alleles" %in% names(export_table)) {
              ft <- set_header_labels(ft,
                                      Marker = "Marker",
                                      All_Alleles = "All Alleles",
                                      Replicated_Alleles = "Replicated Alleles")
            } else {
              ft <- set_header_labels(ft,
                                      Marker = "Marker",
                                      All_Alleles = "All Alleles")
            }
            
            # Style the table
            ft <- bold(ft, part = "header")
            ft <- bold(ft, j = 1)
            ft <- align(ft, align = "left", part = "all")
            ft <- width(ft, j = 1, width = 1.2, unit = "in")
            ft <- width(ft, j = 2, width = 2.5, unit = "in")
            if ("Replicated_Alleles" %in% names(export_table)) {
              ft <- width(ft, j = 3, width = 1.8, unit = "in")
              
              num_unique_cols <- ncol(export_table) - 3
              if (num_unique_cols > 0) {
                unique_col_width <- 1.0
                for (col_idx in 4:(3 + num_unique_cols)) {
                  ft <- width(ft, j = col_idx, width = unique_col_width, unit = "in")
                }
              }
            }
            ft <- font(ft, fontname = "Arial", part = "all")
            ft <- fontsize(ft, size = 11, part = "all")
            ft <- fontsize(ft, size = 11, part = "header")
            
            # Create Word document
            doc <- read_docx()
            
            # Get case number and expert visum
            case_number <- gsub("^Trace_", "", t_name)
            
            expert_visum_input_id <- paste0("trace_expert_visum_", gsub("[^[:alnum:]]", "_", t_name))
            expert_visum <- input[[expert_visum_input_id]]
            if (is.null(expert_visum)) expert_visum <- ""
            expert_visum <- trimws(expert_visum)
            
            # Define font properties
            fp_normal <- fp_text(font.family = "Arial", font.size = 11)
            fp_heading <- fp_text(font.family = "Arial", font.size = 11, bold = TRUE)
            
            # Add title
            doc <- body_add_fpar(doc, fpar(ftext("SmarTRace: Trace Consensus Table", prop = fp_heading)))
            doc <- body_add_fpar(doc, fpar(ftext(paste("Generated:", Sys.Date()), prop = fp_normal)))
            
            # Add trace name
            if (!is.null(t_name)) {
              doc <- body_add_fpar(doc, fpar(ftext(paste("Trace:", t_name), prop = fp_normal)))
            }
            
            # Add case number if available
            if (!is.null(case_number) && case_number != "") {
              doc <- body_add_fpar(doc, fpar(ftext(paste("Case Number:", case_number), prop = fp_normal)))
            }
            
            # Add expert visum if provided
            if (expert_visum != "") {
              doc <- body_add_fpar(doc, fpar(ftext(paste("Expert Visum:", expert_visum), prop = fp_normal)))
            }
            
            # Add PCN info
            if (!is.null(trace_pcn) && !is.na(trace_pcn)) {
              doc <- body_add_fpar(doc, fpar(ftext(paste("Trace PCN:", trace_pcn), prop = fp_normal)))
            }
            
            # Add sorting info
            doc <- body_add_fpar(doc, fpar(ftext(paste("Sorted by:", selected_kit, "kit"), prop = fp_normal)))
            
            doc <- body_add_par(doc, "", style = "Normal")
            
            # Add table
            doc <- body_add_flextable(doc, ft)
            
            # Save document
            print(doc, target = file)
          },
          contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        )
        
        cat("  -> Handler created successfully!\n")
      })
    }
    cat("=====================\n")
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
}


# Run the App
#shinyApp(ui, server)
