APP_VERSION <- "1.3.0"


# PCR Kits and their Markers
amplification_choices <- c("ESIf", "NGMdetect", "ESXf", "Fusion6C", "ArgusX12QS", "Y23", "Yfiler+", "NGMselect")

# Define expected markers for each kit
kit_expected_markers <- list(
  "ESIf" = c("AMEL", "D3S1358", "D19S433", "D2S1338", "D22S1045", "D16S539", "D18S51", "D1S1656", "D10S1248", "D2S441", "TH01", "vWA", 
             "D21S11", "D12S391", "D8S1179", "FGA", "SE33"), #17
  
  "NGMdetect" = c("D2S1338", "SE33", "D16S539", "D18S51", "TH01", "D12S391", "D3S1358", "FGA", "AMEL", "vWA", "D21S11", "D1S1656","D2S441",
                  "D8S1179", "D19S433", "D22S1045", "D10S1248"), #17 + 3 quality marker, that are not included here
  
  "ESXf" = c("AMEL", "D3S1358", "TH01", "D21S11", "D18S51",  "D10S1248", "D1S1656", "D2S1338", "D16S539", "D22S1045", "vWA", "D8S1179", "FGA",
             "D2S441", "D12S391", "D19S433", "SE33"), #17
  
  "Fusion6C" = c("AMEL", "D3S1358", "D1S1656", "D2S441", "D10S1248", "D13S317", "PentaE", "D16S539", "D18S51", "D2S1338", "CSF1PO", "PentaD",
                 "TH01", "vWA", "D21S11", "D7S820", "D5S818", "TPOX", "D8S1179", "D12S391", "D19S433", "SE33", "D22S1045", "DYS391", "FGA",
                 "DYS576", "DYS570"), #27
  
  "ArgusX12QS" = c("QS1", "AMEL", "DXS10103", "DXS8378", "DXS10101", "DXS10134", "DXS10074", "DXS7132", "DXS10135", "DXS7423", "DXS10146",
                   "DXS10079", "HPRTB", "DXS10148", "D21S11"), #15
  
  "Y23" = c("DYS576", "DYS389I", "DYS448", "DYS389II", "DYS19", "DYS391", "DYS481", "DYS549", "DYS533", "DYS438", "DYS437", "DYS570", "DYS635",
            "DYS390", "DYS439", "DYS392", "DYS643", "DYS393", "DYS458", "DYS385", "DYS456", "YGATAH4"), #22
  
  "Yfiler+" = c("DYS576", "DYS389I", "DYS635", "DYS389II", "DYS627", "DYS460", "DYS458", "DYS19", "YGATAH4", "DYS448", "DYS391", "DYS456",
                "DYS390", "DYS438", "DYS392", "DYS518", "DYS570", "DYS437", "DYS385", "DYS449", "DYS393", "DYS439", "DYS481", "DYF387S1",
                "DYS533"), #25
  
  "NGMselect" = c("D10S1248", "vWA", "D16S539", "D2S1338", "D8S1179", "D21S11", "D18S51", "D22S1045", "D19S433", "TH01", 
                  "FGA", "D2S441", "D3S1358", "D1S1656", "D12S391", "SE33", "AMEL", "TPOX", "CSF1PO", "D13S317", "D7S820", "D5S818", 
                  "PentaD", "PentaE") #24
)

# Repeat unit sizes for each marker
marker_repeat_units <- list(
  "AMEL" = NA,
  "D10S1248" = 4,
  "D12S391" = 4,
  "D16S539" = 4,
  "D18S51" = 4,
  "D19S433" = 4,
  "D1S1656" = 4,
  "D21S11" = 5,
  "D22S1045" = 3,
  "D2S1338" = 4,
  "D2S441" = 4,
  "D3S1358" = 4,
  "D8S1179" = 4,
  "FGA" = 4,
  "SE33" = 4,
  "TH01" = 4,
  "vWA" = 4
)

# All possible alleles per marker (from uploaded file)
all_alleles_per_marker <- list(
  AMEL = c("X", "Y"),
  D10S1248 = c("8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"),
  D12S391 = c("14", "15", "16", "17", "17.3", "18", "18.3", "19", "19.3", "20", "21", "22", "23", "24", "25", "26", "27"),
  D16S539 = c("4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"),
  D18S51 = c("7", "8", "9", "10", "10.2", "11", "12", "13", "13.2", "14", "14.2", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27"),
  D19S433 = c("5.2", "6", "6.2", "7", "8", "9", "10", "11", "12", "12.2", "13", "13.2", "14", "14.2", "15", "15.2", "16", "16.2", "17", "17.2", "18", "18.2", "19.2"),
  D1S1656 = c("9", "10", "11", "12", "13", "14", "14.3", "15", "15.3", "16", "16.3", "17", "17.3", "18", "18.3", "19", "19.3", "20.3"),
  D21S11 = c("24", "24.2", "25", "25.2", "26", "27", "28", "28.2", "29", "29.2", "30", "30.2", "31", "31.2", "32", "32.2", "33", "33.2", "34", "34.2", "35", "35.2", "36", "37", "38"),
  D22S1045 = c("7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"),
  D2S1338 = c("10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28"),
  D2S441 = c("8", "9", "10", "11", "11.3", "12", "13", "14", "15", "16", "17"),
  D3S1358 = c("9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"),
  D8S1179 = c("5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"),
  FGA = c("13", "14", "15", "16", "17", "18", "18.2", "19", "19.2", "20", "20.2", "21", "21.2", "22", "22.2", "23", "23.2", "24", "24.2", "25", "25.2", "26", "27", "28", "29", "30", "30.2", "31.2", "32.2", "33.2", "42.2", "43.2", "44.2", "45.2", "46.2", "47.2", "48.2", "50.2", "51.2"),
  SE33 = c("4.2", "6.3", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "20.2", "21", "21.2", "22", "22.2", "23.2", "24.2", "25.2", "26.2", "27.2", "28.2", "29.2", "30.2", "31.2", "32.2", "33.2", "34.2", "35", "35.2", "36", "37", "38", "39", "42"),
  TH01 = c("3", "4", "5", "6", "7", "8", "9", "9.3", "10", "11", "12", "13", "13.3"),
  vWA = c("10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24")
)


# Validation of PCN Number
validate_pcn <- function(pcn_input) {
  if (!grepl("^[0-9]+ [0-9]+$", pcn_input)) {
    return("invalid input!")
  }
  
  parts <- strsplit(pcn_input, " ")[[1]]
  if (length(parts) != 2 || nchar(parts[1]) != 8) {
    return("invalid input! Only numbers in this format are allowed: xxxxxxxx xx")
  }
  
  ctrl <- c(9:2)
  ctrl_sum <- sum(as.integer(strsplit(parts[1], "")[[1]]) * ctrl)
  ctrl_nr <- 97 - (ctrl_sum %% 97)
  
  if (as.integer(parts[2]) != ctrl_nr) {
    return("invalid input! The checksum does not match.")
  }
  
  return("valid PCN")
}

# Validation of Person Number (IRM, Ass., or PCN)
validate_person_number <- function(number_input, number_type) {
  # If PCN type, use existing PCN validation
  if (number_type == "PCN-No.") {
    return(validate_pcn(number_input))
  }
  
  # For IRM-Nr. and Ass.-Nr., no validation
  return(NULL)
}

# Standardize marker names across different kits
standardize_marker_name <- function(marker) {
  marker <- trimws(marker)  # Remove whitespace
  
  # Convert to uppercase for comparison
  marker_upper <- toupper(marker)
  
  if (marker_upper == "AMELOGENIN") return("AMEL")
  if (marker_upper == "DYS389 I") return("DYS389I")
  if (marker_upper == "DYS389 II") return("DYS389II")
  if (marker_upper == "Penta D") return("PentaD")
  if (marker_upper == "Penta E") return("PentaE")
  if (marker_upper == "VWA") return("vWA")
  # if (marker_upper == "ANOTHER_VARIANT") return("STANDARD_NAME")
  
  return(marker)  # Return original if no match
}

# Standardize Kit Names to handle typos and variations
standardize_kit_name <- function(kit_string) {
  kit_string <- trimws(kit_string)
  
  # NGMdetect variants (ERWEITERT)
  if (grepl("NGMdetect", kit_string, ignore.case = TRUE) || 
      grepl("NGMd", kit_string, ignore.case = TRUE) || 
      grepl("NGMD", kit_string, ignore.case = TRUE) || 
      grepl("NGMdet", kit_string, ignore.case = TRUE) || 
      grepl("NGMex", kit_string, ignore.case = TRUE)) {
    return("NGMdetect")
  }
  
  # ESIf variants
  if (grepl("ESIf", kit_string, ignore.case = TRUE) || 
      grepl("ESIfast", kit_string, ignore.case = TRUE)) {
    return("ESIf")
  }
  
  # ESXf variants
  if (grepl("ESXf", kit_string, ignore.case = TRUE) || 
      grepl("ESXfast", kit_string, ignore.case = TRUE)) {
    return("ESXf")
  }
  
  # Fusion6C variants
  if (grepl("Fusion6C", kit_string, ignore.case = TRUE) || 
      grepl("FUSION6C", kit_string, ignore.case = TRUE) || 
      grepl("Fusion", kit_string, ignore.case = TRUE) || 
      grepl("PPFusion6C", kit_string, ignore.case = TRUE)) {
    return("Fusion6C")
  }
  
  # ArgusX12QS variants
  if (grepl("ArgusX12QS", kit_string, ignore.case = TRUE) || 
      grepl("ArgusX12", kit_string, ignore.case = TRUE)) {
    return("ArgusX12QS")
  }
  
  # Y23 variants
  if (grepl("Y23", kit_string, ignore.case = TRUE) || 
      grepl("y23", kit_string, ignore.case = TRUE)) {
    return("Y23")
  }
  
  # Yfiler+ variants
  if (grepl("Yfiler+", kit_string, ignore.case = TRUE) || 
      grepl("YFILER", kit_string, ignore.case = TRUE) || 
      grepl("YF", kit_string, ignore.case = TRUE) || 
      grepl("YFiler", kit_string, ignore.case = TRUE) || 
      grepl("Yfiler", kit_string, ignore.case = TRUE) || 
      grepl("Yfil", kit_string, ignore.case = TRUE) || 
      grepl("YFil", kit_string, ignore.case = TRUE) || 
      grepl("YfilerPlus", kit_string, ignore.case = TRUE)) {
    return("Yfiler+")
  }
  
  # Return original if no match found (with warning)
  warning(paste("Unknown kit name:", kit_string))
  return(kit_string)
}

# Extract Kit Name from Filename
extract_kit_from_filename <- function(filename) {
  print("3")
  # Remove path and extension
  basename <- tools::file_path_sans_ext(basename(filename))
  
  # Try to find kit name in filename
  # Pattern: SP-KITNAME-... or similar
  for (kit in amplification_choices) {
    # Create pattern to find kit name (case-insensitive)
    kit_pattern <- gsub(" ", "[-_ ]?", kit)
    
    if (grepl(kit_pattern, basename, ignore.case = TRUE)) {
      match_pos <- regexpr(kit_pattern, basename, ignore.case = TRUE)
      kit_found <- substr(basename, match_pos, match_pos + attr(match_pos, "match.length") - 1)
      return(standardize_kit_name(kit_found))
    }
  }
  
  # If no kit found, return NULL
  return(NULL)
}

# Search for files containing Case ID in specified directory
search_files_by_case_id <- function(case_id, base_dir, file_format = c("imed", "smartDNA"), progress = NULL) {
  # Validate inputs
  print("search files by case id")
  if (is.null(case_id) || case_id == "") {
    return(list(success = FALSE, message = "Case ID is empty"))
  }
  
  if (!dir.exists(base_dir)) {
    return(list(success = FALSE, message = paste("Directory does not exist:", base_dir)))
  }
  
  # WICHTIG: Globale Verfolgung aller bereits verarbeiteten raw_ids
  processed_raw_ids <- character()  # Vektor statt Liste für einfacheren Vergleich
  
  all_files <- list.files(base_dir, 
                          pattern = "\\.(csv|txt)$", 
                          recursive = TRUE, 
                          full.names = TRUE,
                          ignore.case = TRUE)
  
  if (length(all_files) == 0) {
    return(list(success = FALSE, message = "No CSV or TXT files found in directory"))
  }
  
  total_files <- length(all_files)
  
  # Store results by Trace ID
  traces <- list()
  
  # Process each file
  for (file_idx in seq_along(all_files)) {
    file_path <- all_files[file_idx]
    
    # Update progress bar
    if (!is.null(progress)) {
      progress$set(value = file_idx / total_files, 
                   message = paste("Searching...", file_idx, "of", total_files, "files"))
    }
    
    tryCatch({
      # Determine separator based on file extension
      file_ext <- tolower(tools::file_ext(file_path))
      separator <- if (file_ext == "txt") "\t" else ","
      
      file_data <- data.table::fread(
        file_path,
        sep = separator,
        header = TRUE
      )
      
      # Check if Sample Name column exists
      if (!"Sample Name" %in% names(file_data)) {
        next
      }
      
      # Filter rows containing the Case ID (case-insensitive)
      matching_rows <- file_data[grepl(case_id, `Sample Name`, ignore.case = TRUE)]
      
      if (nrow(matching_rows) == 0) {
        next
      }
      
      # VERBESSERTE FILTERUNG: Nur offensichtlich ungültige Zeilen entfernen
      matching_rows <- matching_rows[
        !grepl("^(ESXf|ESIf|NGM|Fusion|Y23|Yfiler|ArgusX)[-_]?[0-9]*$", `Sample Name`, ignore.case = TRUE) &
          !grepl("^[0-9]+\\.[0-9]+ul$", `Sample Name`, ignore.case = TRUE)
      ]
      
      if (nrow(matching_rows) == 0) {
        next
      }
      
      # Extract unique Trace IDs (Sample Names)
      raw_trace_ids <- unique(matching_rows$`Sample Name`)
      print("starten!")
      
      
      # NEUE LOGIK: Filtere raw_trace_ids, die bereits verarbeitet wurden
      raw_trace_ids_new <- raw_trace_ids[!raw_trace_ids %in% processed_raw_ids]
      
      if (length(raw_trace_ids_new) == 0) {
        print(paste("SKIP: Alle raw_trace_ids aus Datei", basename(file_path), "wurden bereits verarbeitet"))
        next
      }
      
      # Falls einige IDs bereits verarbeitet wurden, gib Warnung aus
      raw_trace_ids_duplicate <- raw_trace_ids[raw_trace_ids %in% processed_raw_ids]
      if (length(raw_trace_ids_duplicate) > 0) {
        print(paste("WARNING: Folgende IDs waren bereits vorhanden und werden übersprungen:"))
        print(raw_trace_ids_duplicate)
      }
      
      # Verwende nur die neuen raw_trace_ids
      raw_trace_ids <- raw_trace_ids_new
      
      # Gruppiere nach bereinigter Trace ID
      trace_groups <- list()
      
      # Aktualisiere processed_raw_ids mit allen neuen raw_trace_ids
      processed_raw_ids <- c(processed_raw_ids, raw_trace_ids)
      print("*!!!")
      
      
      for (raw_id in raw_trace_ids) {
        
        clean_id <- extract_clean_trace_id(raw_id)
        if (is.null(clean_id)) {
          clean_id <- raw_id  # Fallback
        }
        
        if (!clean_id %in% names(trace_groups)) {
          trace_groups[[clean_id]] <- list()
        }
        trace_groups[[clean_id]] <- c(trace_groups[[clean_id]], raw_id)
      }
      
      # Extract kit name from filename
      kit_name <- extract_kit_from_filename(file_path)
      
      if (is.null(kit_name)) {
        sample_name_example <- raw_trace_ids[1]
        result <- extract_case_number(sample_name_example)
        if (!is.null(result$kit_name)) {
          kit_name <- result$kit_name
        } else {
          warning(paste("Could not extract kit name from:", basename(file_path)))
          next
        }
      }
      
      # AUTOMATISCHE FORMAT-ERKENNUNG
      has_size_columns <- "Size 1" %in% names(matching_rows)
      
      if (has_size_columns) {
        actual_format <- "smartDNA"
        allele_cols <- paste0("Allele ", 1:12)
      } else {
        actual_format <- "imed"
        allele_cols <- paste0("Allele ", 1:20)
      }
      
      # WICHTIG: Prüfe ob Marker-Spalte vorhanden ist
      if (!"Marker" %in% names(matching_rows)) {
        warning(paste("File", basename(file_path), "has no 'Marker' column - skipping"))
        next
      }
      
      # Find which allele columns actually exist
      available_allele_cols <- allele_cols[allele_cols %in% names(matching_rows)]
      
      # Select columns that exist
      cols_to_select <- c("Sample Name", "Marker", available_allele_cols)
      cols_to_select <- cols_to_select[cols_to_select %in% names(matching_rows)]
      
      if (!"Marker" %in% cols_to_select) {
        warning(paste("File", basename(file_path), "- Marker column missing after selection - skipping"))
        next
      }
      
      processed_data <- matching_rows[, cols_to_select, with = FALSE]
      
      if (!"Marker" %in% names(processed_data)) {
        warning(paste("File", basename(file_path), "- Marker column lost during processing - skipping"))
        print(paste("Available columns:", paste(names(processed_data), collapse=", ")))
        next
      }
      
      # Füge fehlende Allele-Spalten hinzu
      for (col in allele_cols) {
        if (!col %in% names(processed_data)) {
          processed_data[[col]] <- character(nrow(processed_data))
        }
      }
      
      # Für smartDNA Format auch Size und Height Spalten hinzufügen
      if (has_size_columns) {
        size_cols <- paste0("Size ", 1:12)
        height_cols <- paste0("Height ", 1:12)
        
        for (col in size_cols) {
          if (!col %in% names(processed_data)) {
            processed_data[[col]] <- numeric(nrow(processed_data))
          }
        }
        
        for (col in height_cols) {
          if (!col %in% names(processed_data)) {
            processed_data[[col]] <- numeric(nrow(processed_data))
          }
        }
      }
      
      # Standardize marker names
      if ("Marker" %in% names(processed_data)) {
        processed_data$Marker <- sapply(processed_data$Marker, standardize_marker_name)
      }
      
      # Store data by CLEAN Trace ID (grouped)
      for (clean_trace_id in names(trace_groups)) {
        raw_ids_in_group <- trace_groups[[clean_trace_id]]
        
        # Kombiniere Daten aus allen rohen IDs
        trace_data <- processed_data[`Sample Name` %in% raw_ids_in_group]
        
        # Remove Sample Name column
        trace_data <- trace_data[, -"Sample Name"]
        
        # Finale Prüfung
        if (!"Marker" %in% names(trace_data)) {
          warning(paste("CRITICAL ERROR: Marker column missing in trace_data for", clean_trace_id, "kit", kit_name))
          print(paste("Available columns:", paste(names(trace_data), collapse=", ")))
          next
        }
        
        # Initialize trace if not exists
        if (is.null(traces[[clean_trace_id]])) {
          traces[[clean_trace_id]] <- list(
            files = character(),
            kits = list()
          )
        }
        
        # Add file info
        traces[[clean_trace_id]]$files <- unique(c(traces[[clean_trace_id]]$files, basename(file_path)))
        
        # Handle duplicate kit names
        print("duplicate kit names")
        if (kit_name %in% names(traces[[clean_trace_id]]$kits)) {
          print("_")
          print(kit_name)
          kit_count <- sum(grepl(paste0("^", kit_name), names(traces[[clean_trace_id]]$kits)))
          kit_name_unique <- paste0(kit_name, "_", kit_count + 1)
        } else {
          kit_name_unique <- kit_name
        }
        
        # Store kit data
        traces[[clean_trace_id]]$kits[[kit_name_unique]] <- trace_data
      }
      
    }, error = function(e) {
      warning(paste("Error reading file", basename(file_path), ":", e$message))
    })
  }
  
  if (length(traces) == 0) {
    return(list(
      success = FALSE, 
      message = paste("No traces found for Case ID:", case_id)
    ))
  }
  
  return(list(
    success = TRUE,
    traces = traces,
    message = paste("Found", length(traces), "trace(s) for Case ID:", case_id)
  ))
}


# Sort Data by Kit Marker Order
# Function to sort data by kit marker order
sort_by_kit_order <- function(data, kit_name) {
  print("3")
  if (is.null(kit_name) || !kit_name %in% names(kit_expected_markers)) {
    kit_name <- "ESIf"  # Default to ESIf
  }
  
  # Check if data has Marker column, if not return as-is
  if (!"Marker" %in% names(data)) {
    return(data)
  }
  
  # Create a working copy
  result <- copy(data)
  
  kit_order <- kit_expected_markers[[kit_name]]
  
  # Create ordering: markers in kit order first, then others alphabetically
  order_index <- match(result$Marker, kit_order)
  order_index[is.na(order_index)] <- 9999  # Put unmatched at end
  marker_name <- result$Marker  # For secondary sort
  
  # Sort by order_index, then alphabetically by marker name
  result <- result[order(order_index, marker_name), ]
  
  return(result)
}

# Highlight Split Peaks in DataTable
highlight_split_peaks_in_dt <- function(dt_object, consensus_data) {
  print("4")
  split_peaks <- attr(consensus_data, "split_peaks")
  
  if (is.null(split_peaks) || length(split_peaks) == 0) {
    return(dt_object)
  }
  
  # For each marker with split peaks, highlight those alleles in purple
  for (marker in names(split_peaks)) {
    split_alleles <- split_peaks[[marker]]
    
    # Find row index
    row_idx <- which(consensus_data$Marker == marker)
    
    if (length(row_idx) > 0 && "Replicated_Alleles" %in% names(consensus_data)) {
      # Apply custom formatting for this specific cell
      dt_object <- dt_object %>%
        formatStyle(
          'Replicated_Alleles',
          target = 'row',
          backgroundColor = styleEqual(marker, '#e7d9f7', default = NULL),
          color = styleEqual(marker, '#6f42c1', default = NULL)
        )
    }
  }
  
  return(dt_object)
}

# Extract Trace ID and Kit Name from Sample Name
extract_case_number <- function(sample_name) {
  print("5")
  if (is.null(sample_name) || is.na(sample_name) || sample_name == "") {
    return(list(case_number = NULL, kit_name = NULL))
  }
  
  # Try to find kit name in the sample name
  found_kit <- NULL
  trace_id <- NULL
  
  # Check each known kit name
  for (kit in amplification_choices) {
    # Create pattern to find kit name (case-insensitive)
    kit_pattern <- gsub(" ", "[-_ ]?", kit)  # Allow spaces, dashes, underscores
    
    if (grepl(kit_pattern, sample_name, ignore.case = TRUE)) {
      # Extract the position where kit name starts
      match_pos <- regexpr(kit_pattern, sample_name, ignore.case = TRUE)
      
      if (match_pos > 1) {
        # Everything before the kit name is the trace ID
        trace_id <- substr(sample_name, 1, match_pos - 1)
        # Remove trailing dash or underscore
        trace_id <- gsub("[-_]+$", "", trace_id)
        
        # Extract kit name and standardize it
        kit_found <- substr(sample_name, match_pos, match_pos + attr(match_pos, "match.length") - 1)
        found_kit <- standardize_kit_name(kit_found)
        break
      }
    }
  }
  
  # If no kit found, try to standardize any potential kit name in the string
  if (is.null(found_kit)) {
    # Split by common delimiters
    parts <- unlist(strsplit(sample_name, "[-_.]"))
    for (part in parts) {
      tryCatch({
        standardized <- standardize_kit_name(part)
        if (standardized %in% amplification_choices) {
          found_kit <- standardized
          # Trace ID is everything before this part
          kit_pos <- regexpr(part, sample_name, fixed = TRUE)
          trace_id <- substr(sample_name, 1, kit_pos - 1)
          trace_id <- gsub("[-_]+$", "", trace_id)
          break
        }
      }, warning = function(w) {
        # Ignore warnings for parts that aren't kit names
      })
    }
  }
  
  return(list(case_number = trace_id, kit_name = found_kit))
}

# Extract clean Trace ID (without kit name and volume info)
extract_clean_trace_id <- function(sample_name) {
  print("6")
  if (is.null(sample_name) || is.na(sample_name) || sample_name == "") {
    return(NULL)
  }
  
  # Remove kit names and everything after them
  for (kit in amplification_choices) {
    kit_pattern <- paste0("[-_]", gsub(" ", "[-_ ]?", kit), ".*$")
    sample_name <- gsub(kit_pattern, "", sample_name, ignore.case = TRUE)
  }
  
  # Remove volume information (e.g., _25ul_17.5ul)
  sample_name <- gsub("[-_][0-9.]+ul.*$", "", sample_name, ignore.case = TRUE)
  
  # Clean up any trailing dashes or underscores
  sample_name <- gsub("[-_]+$", "", sample_name)
  
  return(sample_name)
}

# Process uploaded trace files from drag & drop
process_trace_files <- function(file_list) {
  print("7")
  if (is.null(file_list) || nrow(file_list) == 0) {
    return(list(success = FALSE, message = "No files uploaded"))
  }
  
  traces <- list()
  all_trace_ids <- character()
  
  # Process each uploaded file
  for (i in 1:nrow(file_list)) {
    file_path <- file_list$datapath[i]
    file_name <- file_list$name[i]
    
    tryCatch({
      # Determine separator based on file extension
      file_ext <- tolower(tools::file_ext(file_name))
      separator <- if (file_ext == "txt") "\t" else ","
      
      # Read file
      file_data <- suppressWarnings(
        fread(file_path, 
              sep = separator, 
              header = TRUE, 
              encoding = "UTF-8",
              fill = TRUE,
              blank.lines.skip = TRUE)
      )
      
      # Check if Sample Name column exists
      if (!"Sample Name" %in% names(file_data)) {
        warning(paste("File", file_name, "has no 'Sample Name' column - skipping"))
        next
      }
      
      # Check if Marker column exists
      if (!"Marker" %in% names(file_data)) {
        warning(paste("File", file_name, "has no 'Marker' column - skipping"))
        next
      }
      
      # Get unique Sample Names (should be only one trace per file in Option C)
      sample_names <- unique(file_data$`Sample Name`)
      sample_names <- sample_names[!is.na(sample_names) & sample_names != ""]
      
      if (length(sample_names) == 0) {
        warning(paste("File", file_name, "has no valid Sample Names - skipping"))
        next
      }
      
      # Extract clean trace ID from first sample name
      raw_trace_id <- sample_names[1]
      clean_trace_id <- extract_clean_trace_id(raw_trace_id)
      
      if (is.null(clean_trace_id) || clean_trace_id == "") {
        clean_trace_id <- raw_trace_id
      }
      
      all_trace_ids <- c(all_trace_ids, clean_trace_id)
      
      # Extract kit name from filename
      kit_name <- extract_kit_from_filename(file_name)
      
      if (is.null(kit_name)) {
        # Fallback: try to extract from sample name
        result <- extract_case_number(raw_trace_id)
        if (!is.null(result$kit_name)) {
          kit_name <- result$kit_name
        } else {
          warning(paste("Could not extract kit name from:", file_name))
          next
        }
      }
      
      # Filter out empty markers
      file_data <- file_data[!is.na(Marker) & Marker != ""]
      
      if (nrow(file_data) == 0) {
        warning(paste("File", file_name, "has no valid markers - skipping"))
        next
      }
      
      # WICHTIG: Bestimme Format basierend auf vorhandenen Spalten
      # Check if Size 1 exists -> smartDNA format (max 12 alleles)
      # Otherwise -> imed format (max 20 alleles)
      has_size_columns <- "Size 1" %in% names(file_data)
      max_alleles <- if (has_size_columns) 12 else 20
      
      # Select allele columns based on detected format
      allele_cols <- paste0("Allele ", 1:max_alleles)
      available_allele_cols <- allele_cols[allele_cols %in% names(file_data)]
      
      # Select relevant columns - make sure Marker is included
      # WICHTIG: Für smartDNA Format auch Size und Height Spalten einschließen
      if (has_size_columns) {
        # smartDNA Format: Marker + Alleles + Sizes + Heights
        size_cols <- paste0("Size ", 1:12)
        height_cols <- paste0("Height ", 1:12)
        available_size_cols <- size_cols[size_cols %in% names(file_data)]
        available_height_cols <- height_cols[height_cols %in% names(file_data)]
        
        cols_to_select <- c("Marker", available_allele_cols, available_size_cols, available_height_cols)
      } else {
        # imed Format: nur Marker + Alleles
        cols_to_select <- c("Marker", available_allele_cols)
      }
      cols_to_select <- cols_to_select[cols_to_select %in% names(file_data)]
      
      # WICHTIG: Prüfe ob Marker-Spalte vorhanden ist
      if (!"Marker" %in% cols_to_select) {
        warning(paste("File", file_name, "has no 'Marker' column in selection - skipping"))
        next
      }
      
      # Create processed data WITHOUT Sample Name column
      processed_data <- file_data[, cols_to_select, with = FALSE]
      
      # Zusätzliche Prüfung: Stelle sicher, dass Marker-Spalte nicht leer ist
      if (nrow(processed_data) == 0 || !"Marker" %in% names(processed_data)) {
        warning(paste("File", file_name, "has no valid data after processing - skipping"))
        next
      }
      
      # Add missing allele columns with empty values (basierend auf max_alleles)
      # Verwende character() um sicherzustellen, dass es character bleibt
      for (col in allele_cols) {
        if (!col %in% names(processed_data)) {
          processed_data[[col]] <- character(nrow(processed_data))
        }
      }
      
      # Für smartDNA Format auch Size und Height Spalten hinzufügen falls fehlend
      if (has_size_columns) {
        size_cols <- paste0("Size ", 1:12)
        height_cols <- paste0("Height ", 1:12)
        
        for (col in size_cols) {
          if (!col %in% names(processed_data)) {
            processed_data[[col]] <- numeric(nrow(processed_data))
          }
        }
        
        for (col in height_cols) {
          if (!col %in% names(processed_data)) {
            processed_data[[col]] <- numeric(nrow(processed_data))
          }
        }
      }
      
      # Standardize marker names
      processed_data$Marker <- sapply(processed_data$Marker, standardize_marker_name)
      
      # Finale Prüfung vor dem Speichern
      if (!"Marker" %in% names(processed_data)) {
        warning(paste("ERROR: Marker column missing in processed_data for file", file_name))
        print(paste("Available columns:", paste(names(processed_data), collapse=", ")))
        next
      }
      
      # Initialize trace if not exists
      if (is.null(traces[[clean_trace_id]])) {
        traces[[clean_trace_id]] <- list(
          files = character(),
          kits = list(),
          raw_trace_ids = character()
        )
      }
      
      # Add file info
      traces[[clean_trace_id]]$files <- c(traces[[clean_trace_id]]$files, file_name)
      traces[[clean_trace_id]]$raw_trace_ids <- unique(c(traces[[clean_trace_id]]$raw_trace_ids, raw_trace_id))
      
      # Handle duplicate kit names
      if (kit_name %in% names(traces[[clean_trace_id]]$kits)) {
        kit_count <- sum(grepl(paste0("^", kit_name), names(traces[[clean_trace_id]]$kits)))
        kit_name_unique <- paste0(kit_name, "_", kit_count + 1)
      } else {
        kit_name_unique <- kit_name
      }
      
      # Store kit data
      traces[[clean_trace_id]]$kits[[kit_name_unique]] <- processed_data
      
    }, error = function(e) {
      warning(paste("Error reading file", file_name, ":", e$message))
    })
  }
  
  if (length(traces) == 0) {
    return(list(success = FALSE, message = "No valid traces found in uploaded files"))
  }
  
  return(list(
    success = TRUE,
    traces = traces,
    all_trace_ids = all_trace_ids,  # Gebe auch die trace IDs zurück
    message = paste("Successfully processed", nrow(file_list), "file(s)")
  ))
}

# Sort trace names intelligently (numeric and alphabetic)
sort_trace_names <- function(trace_names) {
  print("8")
  if (length(trace_names) == 0) return(trace_names)
  
  # Create a data frame with trace names and their sort keys
  trace_df <- data.frame(
    name = trace_names,
    stringsAsFactors = FALSE
  )
  
  # Extract sort components from trace names
  # Pattern: Trace_FG25-64-1.1-E1 or similar
  trace_df$sort_key <- sapply(trace_names, function(name) {
    # Remove "Trace_" prefix if present
    clean_name <- gsub("^Trace_", "", name)
    
    # Split by dashes and dots to get components
    # e.g., "FG25-64-1.1-E1" becomes components we can sort
    parts <- strsplit(clean_name, "[-.]")[[1]]
    
    # Create sortable key: pad numbers with zeros for proper sorting
    sort_parts <- sapply(parts, function(part) {
      # Check if part is purely numeric
      if (grepl("^[0-9]+$", part)) {
        # Pad with zeros to 10 digits for proper numeric sorting
        sprintf("%010d", as.numeric(part))
      } else if (grepl("^[A-Z]+[0-9]+$", part)) {
        # Handle cases like "FG25" or "E1" - split letter and number
        letter_part <- gsub("[0-9]+$", "", part)
        number_part <- gsub("^[A-Z]+", "", part)
        if (number_part != "") {
          paste0(letter_part, sprintf("%010d", as.numeric(number_part)))
        } else {
          part
        }
      } else {
        # Keep as is for pure text
        part
      }
    })
    
    paste(sort_parts, collapse = "-")
  })
  
  # Sort by the sort key
  trace_df <- trace_df[order(trace_df$sort_key), ]
  
  return(trace_df$name)
}

# Consensus Table for multiple PCR kits 
create_consensus_table <- function(data_list, pcn = NULL) {
  print("9")
  
  # Extract PCN if it exists in the list
  if (is.null(pcn) && "PCN" %in% names(data_list)) {
    pcn <- data_list$PCN
    data_list$PCN <- NULL
  }
  
  # Get all kit names
  kit_names <- setdiff(names(data_list), c("PCN", "Comments"))
  
  if (length(kit_names) == 0) {
    warning("No kit data found in data_list")
    return(NULL)
  }
  
  # QC Markers und QC Check (unverändert)
  qc_markers <- c("IQCS", "IQCL", "Yindel")
  
  for (kit_name in kit_names) {
    dt <- data_list[[kit_name]]
    if (!is.data.frame(dt) && !is.data.table(dt)) {
      warning(paste("Kit", kit_name, "is not a data frame - skipping"))
      next
    }
    if (!is.data.table(dt)) {
      dt <- as.data.table(dt)
      data_list[[kit_name]] <- dt
    }
    if (!"Marker" %in% names(dt)) {
      warning(paste("Kit", kit_name, "has no Marker column - skipping"))
      next
    }
    
    for (qc_marker in qc_markers) {
      qc_row <- dt[Marker == qc_marker]
      if (nrow(qc_row) > 0) {
        allele1_val <- qc_row[["Allele 1"]][1]
        if (!is.na(allele1_val) && !(allele1_val %in% c("","1", "2"))) {
          warning(paste0("QC FAILED for ", kit_name, ": ", qc_marker, 
                         " Allele 1 is '", allele1_val, "' (should be empty, 1 or 2) (PCN: ", 
                         ifelse(is.null(pcn), "N/A", pcn), ")"))
        }
      }
    }
  }
  
  # Remove QC markers
  for (kit_name in kit_names) {
    dt <- data_list[[kit_name]]
    if (is.data.frame(dt) || is.data.table(dt)) {
      if (!is.data.table(dt)) {
        dt <- as.data.table(dt)
      }
      data_list[[kit_name]] <- dt[!(Marker %in% qc_markers)]
    }
  }
  
  # Get all unique markers
  all_markers <- unique(unlist(lapply(kit_names, function(kit_name) {
    cat("\n--- Kit:", kit_name, "---\n") #
    
    dt <- data_list[[kit_name]]
    if (is.data.frame(dt) || is.data.table(dt)) {
      if (!is.data.table(dt)) {
        dt <- as.data.table(dt)
      }
      if ("Marker" %in% names(dt)) {
        return(unique(dt[["Marker"]]))
      }
    }
    return(character(0))
  })))
  
  if (length(all_markers) == 0) {
    warning("No markers found in any kit")
    return(NULL)
  }
  
  single_kit <- length(kit_names) == 1
  consensus_list <- list()
  
  # **NEU: Speichere Split Peak Informationen**
  split_peak_info <- list()
  
  # Process each marker
  for (marker in all_markers) {
    kit_alleles <- list()
    
    for (kit_name in kit_names) {
      dt <- data_list[[kit_name]]
      if (!is.data.frame(dt) && !is.data.table(dt)) next
      if (!is.data.table(dt)) {
        dt <- as.data.table(dt)
      }
      if (!"Marker" %in% names(dt)) next
      
      marker_row <- dt[Marker == marker]
      
      if (nrow(marker_row) > 0) {
        allele_cols <- names(marker_row)[grepl("^Allele [0-9]+$", names(marker_row))]
        if (length(allele_cols) > 0) {
          alleles <- as.character(marker_row[1, allele_cols, with = FALSE])
        } else {
          alleles <- character(0)
        }
        alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
        kit_alleles[[kit_name]] <- alleles
      } else {
        kit_alleles[[kit_name]] <- character(0)
      }
    }
    
    all_alleles <- unique(unlist(kit_alleles))
    all_alleles <- all_alleles[!is.na(all_alleles) & all_alleles != "NA"]
    
    # Sort all_alleles
    if (length(all_alleles) > 0) {
      numeric_alleles <- all_alleles[!is.na(suppressWarnings(as.numeric(all_alleles)))]
      non_numeric_alleles <- all_alleles[is.na(suppressWarnings(as.numeric(all_alleles)))]
      all_alleles <- c(as.character(sort(as.numeric(numeric_alleles))), sort(non_numeric_alleles))
    }
    
    if (single_kit) {
      consensus_row <- data.table(
        Marker = marker,
        All_Alleles = if(length(all_alleles) > 0) paste(all_alleles, collapse = " / ") else ""
      )
    } else {
      # Find replicated alleles
      allele_counts <- table(unlist(kit_alleles))
      message("Allele counts:")
      message(paste(capture.output(print(allele_counts)), collapse = "\n")) #
      ##
      replicated_alleles <- names(allele_counts[allele_counts > 1])
      replicated_alleles <- replicated_alleles[!is.na(replicated_alleles) & replicated_alleles != "NA"]
      
      # EXCLUDE OL from replicated alleles - OL should never be in Replicated_Alleles** --> but we need the OL to mark it pink
      #replicated_alleles <- replicated_alleles[!grepl("^OL$", replicated_alleles, ignore.case = TRUE)]
      
      # Ein Split Peak liegt vor, wenn ein Allel >1x gezählt wird, aber nur in EINEM Kit vorkommt
      potential_split_peaks <- c()
      
      for (allele in replicated_alleles) {
        # Zähle in wie vielen verschiedenen Kits das Allel vorkommt
        kits_with_allele <- sum(sapply(kit_alleles, function(x) allele %in% x))
        
        if (kits_with_allele == 1) {
          # Dieses Allel kommt mehrfach vor, aber nur in EINEM Kit -> Split Peak!
          potential_split_peaks <- c(potential_split_peaks, allele)
        }
      }
      
      # Sort replicated_alleles
      if (length(replicated_alleles) > 0) {
        numeric_alleles <- replicated_alleles[!is.na(suppressWarnings(as.numeric(replicated_alleles)))]
        non_numeric_alleles <- replicated_alleles[is.na(suppressWarnings(as.numeric(replicated_alleles)))]
        replicated_alleles <- c(as.character(sort(as.numeric(numeric_alleles))), sort(non_numeric_alleles))
      }
      
      # Find unique alleles per kit
      unique_per_kit <- list()
      for (kit_name in kit_names) {
        kit_specific <- setdiff(kit_alleles[[kit_name]], unlist(kit_alleles[names(kit_alleles) != kit_name]))
        kit_specific <- kit_specific[!is.na(kit_specific) & kit_specific != "NA"]
        unique_per_kit[[kit_name]] <- if (length(kit_specific) > 0) paste(kit_specific, collapse = " / ") else ""
      }
      
      consensus_row <- data.table(
        Marker = marker,
        All_Alleles = if(length(all_alleles) > 0) paste(all_alleles, collapse = " / ") else "",
        Replicated_Alleles = if(length(replicated_alleles) > 0) paste(replicated_alleles, collapse = " / ") else ""
      )
      
      for (kit_name in kit_names) {
        consensus_row[[paste0("Unique_", kit_name)]] <- unique_per_kit[[kit_name]]
      }
      
      # **NEU: Speichere Split Peak Info**
      if (length(potential_split_peaks) > 0) {
        split_peak_info[[marker]] <- potential_split_peaks
      }
    }
    
    consensus_list[[marker]] <- consensus_row
  }
  
  consensus_table <- rbindlist(consensus_list, fill = TRUE)
  
  if (!is.null(pcn)) {
    setattr(consensus_table, "PCN", pcn)
  }
  
  # Füge Split Peak Info als Attribut hinzu**
  if (length(split_peak_info) > 0) {
    setattr(consensus_table, "split_peaks", split_peak_info)
  }
  
  # Tracke OL (Off-Ladder) Alleles**
  ol_alleles_info <- list()
  
  for (marker in all_markers) {
    # Count how many times "OL" appears at this marker across all kits
    ol_count <- 0
    ol_found <- FALSE
    
    for (kit_name in kit_names) {
      dt <- data_list[[kit_name]]
      if (!is.data.frame(dt) && !is.data.table(dt)) next
      if (!is.data.table(dt)) {
        dt <- as.data.table(dt)
      }
      if (!"Marker" %in% names(dt)) next
      
      marker_row <- dt[Marker == marker]
      
      if (nrow(marker_row) > 0) {
        allele_cols <- names(marker_row)[grepl("^Allele [0-9]+$", names(marker_row))]
        if (length(allele_cols) > 0) {
          alleles <- as.character(marker_row[1, allele_cols, with = FALSE])
          alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
          
          # Count OL occurrences
          ol_in_kit <- sum(toupper(alleles) == "OL")
          if (ol_in_kit > 0) {
            ol_count <- ol_count + ol_in_kit
            ol_found <- TRUE
          }
        }
      }
    }
    
    # If OL found at this marker, store info
    if (ol_found) {
      ol_alleles_info[[marker]] <- list(
        count = ol_count,
        renamed_values = character(0)
      )
      
      # Hole renamed values aus data_list falls vorhanden
      if (!is.null(data_list$OL_renamed_values) && 
          !is.null(data_list$OL_renamed_values[[marker]])) {
        ol_alleles_info[[marker]]$renamed_values <- data_list$OL_renamed_values[[marker]]
      }
    }
  }
  
  # Füge OL Allele Info als Attribut hinzu
  if (length(ol_alleles_info) > 0) {
    setattr(consensus_table, "ol_alleles", ol_alleles_info)
  }
  
  return(consensus_table)
}

# Function to create consensus for trace data
create_trace_consensus <- function(trace_data_list) {
  print("10")
  return(create_consensus_table(trace_data_list))
}

# Function to create consensus for person data
create_person_consensus <- function(person_data) {
  print("11")
  # person_data is e.g. person_data_list$Person_1
  
  # Define metadata field names to exclude
  metadata_fields <- c("PCN", "Number", "Number_Type", "Status", "Comments")
  
  # Check if it's manual OR CSV data (simple format)
  if (("Manual" %in% names(person_data) || "CSV" %in% names(person_data) || "I_MED" %in% names(person_data)) && 
      length(setdiff(names(person_data), metadata_fields)) == 1) {
    # Only Manual/CSV/I_MED + metadata, no files
    if ("Manual" %in% names(person_data)) {
      simple_dt <- person_data$Manual
      marker_col <- "System"
    } else if ("CSV" %in% names(person_data)) {
      simple_dt <- person_data$CSV
      marker_col <- "Marker"
      person_nr_file <- person_data$file_name
      print(person_nr_file)
      
      
    } else {
      simple_dt <- person_data$I_MED
      marker_col <- "Marker"
    }
    
    # Create simple table with Marker | All_Alleles
    result <- data.table(
      Marker = simple_dt[[marker_col]],
      All_Alleles = sapply(1:nrow(simple_dt), function(i) {
        alleles <- c(simple_dt$Allele1[i], simple_dt$Allele2[i])
        alleles <- alleles[!is.na(alleles) & alleles != "" & alleles != "NA"]
        if (length(alleles) > 0) {
          # Sort alleles
          numeric_alleles <- alleles[!is.na(suppressWarnings(as.numeric(alleles)))]
          non_numeric_alleles <- alleles[is.na(suppressWarnings(as.numeric(alleles)))]
          sorted_alleles <- c(as.character(sort(as.numeric(numeric_alleles))), sort(non_numeric_alleles))
          paste(sorted_alleles, collapse = " / ")
        } else {
          ""
        }
      })
    )
    
    # Add person metadata as attributes
    if (!is.null(person_data$Number) && !is.na(person_data$Number)) {
      setattr(result, "Number", person_data$Number)
    }
    if (!is.null(person_data$Number_Type) && !is.na(person_data$Number_Type)) {
      setattr(result, "Number_Type", person_data$Number_Type)
    }
    if (!is.null(person_data$Status) && !is.na(person_data$Status)) {
      setattr(result, "Status", person_data$Status)
    }
    if (!is.null(person_data$Comments) && !is.na(person_data$Comments)) {
      setattr(result, "Comments", person_data$Comments)
    }
    
    return(result)
  }
  
  # Otherwise it's file data - create consensus like trace
  if ("Manual" %in% names(person_data)) {
    # Handle manual data - convert to same format
    manual_dt <- copy(person_data$Manual)
    setnames(manual_dt, old = c("System", "Allele1", "Allele2"), 
             new = c("Marker", "Allele 1", "Allele 2"))
    
    # Add empty columns for Allele 3-12
    for (i in 3:12) {
      manual_dt[[paste0("Allele ", i)]] <- ""
    }
    
    person_data$Manual <- manual_dt
  }
  
  # Remove metadata fields before creating consensus
  person_data_clean <- person_data[!names(person_data) %in% metadata_fields]
  
  result <- create_consensus_table(person_data_clean)
  
  # Add metadata as attributes for file-based data
  if (!is.null(person_data$Number) && !is.na(person_data$Number)) {
    setattr(result, "Number", person_data$Number)
  }
  if (!is.null(person_data$Number_Type) && !is.na(person_data$Number_Type)) {
    setattr(result, "Number_Type", person_data$Number_Type)
  }
  if (!is.null(person_data$Status) && !is.na(person_data$Status)) {
    setattr(result, "Status", person_data$Status)
  }
  if (!is.null(person_data$Comments) && !is.na(person_data$Comments)) {
    setattr(result, "Comments", person_data$Comments)
  }
  
  return(result)
}

# Trace vs Person Comparison Function (WITH Result Column for Shiny Interface)
create_comparison_table <- function(trace_consensus, person_consensus, trace_pcn = NULL, person_pcn = NULL) {
  print("12")
  # Get all unique markers from both datasets
  all_markers <- unique(c(trace_consensus$Marker, person_consensus$Marker))
  
  # Initialize result list
  comparison_list <- list()
  
  for (marker in all_markers) {
    # Get trace alleles from BOTH Replicated_Alleles and All_Alleles
    trace_row <- trace_consensus[Marker == marker]
    trace_replicated <- character(0)
    trace_all <- character(0)
    
    if (nrow(trace_row) > 0) {
      # Get replicated alleles (reproduced)
      if ("Replicated_Alleles" %in% names(trace_consensus) && trace_row$Replicated_Alleles != "") {
        trace_replicated <- trimws(unlist(strsplit(trace_row$Replicated_Alleles, "/")))
      }
      # Get all alleles
      if (trace_row$All_Alleles != "") {
        trace_all <- trimws(unlist(strsplit(trace_row$All_Alleles, "/")))
      }
    }
    
    # Non-reproduced alleles in trace
    trace_non_reproduced <- setdiff(trace_all, trace_replicated)
    
    # Get person alleles (use Replicated_Alleles if available, otherwise All_Alleles)
    person_row <- person_consensus[Marker == marker]
    if (nrow(person_row) > 0) {
      if ("Replicated_Alleles" %in% names(person_consensus) && person_row$Replicated_Alleles != "") {
        person_alleles_str <- person_row$Replicated_Alleles
      } else {
        person_alleles_str <- person_row$All_Alleles
      }
    } else {
      person_alleles_str <- ""
    }
    
    person_alleles <- if (person_alleles_str != "") {
      trimws(unlist(strsplit(person_alleles_str, "/")))
    } else {
      character(0)
    }
    
    # Sort alleles - numeric first, then non-numeric (like X, Y)
    if (length(trace_replicated) > 0) {
      numeric_alleles <- trace_replicated[!is.na(suppressWarnings(as.numeric(trace_replicated)))]
      non_numeric_alleles <- trace_replicated[is.na(suppressWarnings(as.numeric(trace_replicated)))]
      trace_replicated <- c(as.character(sort(as.numeric(numeric_alleles))), sort(non_numeric_alleles))
    }
    if (length(person_alleles) > 0) {
      numeric_alleles <- person_alleles[!is.na(suppressWarnings(as.numeric(person_alleles)))]
      non_numeric_alleles <- person_alleles[is.na(suppressWarnings(as.numeric(person_alleles)))]
      person_alleles <- c(as.character(sort(as.numeric(numeric_alleles))), sort(non_numeric_alleles))
    }
    
    # Find which reproduced alleles match the person (recalculate after sorting)
    reproduced_and_match_person <- intersect(trace_replicated, person_alleles)
    
    # Check if non-reproduced alleles match person (for parentheses)
    non_reproduced_match_person <- intersect(trace_non_reproduced, person_alleles)
    
    # Sort non_reproduced_match_person - numeric first, then non-numeric
    if (length(non_reproduced_match_person) > 0) {
      numeric_alleles <- non_reproduced_match_person[!is.na(suppressWarnings(as.numeric(non_reproduced_match_person)))]
      non_numeric_alleles <- non_reproduced_match_person[is.na(suppressWarnings(as.numeric(non_reproduced_match_person)))]
      non_reproduced_match_person <- c(as.character(sort(as.numeric(numeric_alleles))), sort(non_numeric_alleles))
    }
    
    # Format trace display: merge reproduced and non-reproduced (in parentheses), then sort all together
    trace_display_parts <- c()
    
    # Combine all alleles with their formatting
    all_trace_alleles <- list()
    
    if (length(trace_replicated) > 0) {
      for (allele in trace_replicated) {
        all_trace_alleles[[length(all_trace_alleles) + 1]] <- list(value = allele, display = allele)
      }
    }
    
    # Add non-reproduced alleles that match person in parentheses
    if (length(non_reproduced_match_person) > 0) {
      for (allele in non_reproduced_match_person) {
        all_trace_alleles[[length(all_trace_alleles) + 1]] <- list(value = allele, display = paste0("(", allele, ")"))
      }
    }
    
    # Sort by numeric value
    if (length(all_trace_alleles) > 0) {
      numeric_items <- all_trace_alleles[sapply(all_trace_alleles, function(x) !is.na(suppressWarnings(as.numeric(x$value))))]
      non_numeric_items <- all_trace_alleles[sapply(all_trace_alleles, function(x) is.na(suppressWarnings(as.numeric(x$value))))]
      
      # Sort numeric items
      if (length(numeric_items) > 0) {
        numeric_items <- numeric_items[order(as.numeric(sapply(numeric_items, function(x) x$value)))]
      }
      
      # Sort non-numeric items alphabetically
      if (length(non_numeric_items) > 0) {
        non_numeric_items <- non_numeric_items[order(sapply(non_numeric_items, function(x) x$value))]
      }
      
      # Combine sorted items
      all_trace_alleles <- c(numeric_items, non_numeric_items)
      trace_display_parts <- sapply(all_trace_alleles, function(x) x$display)
    }
    
    # Check if there are non-reproduced alleles that are NOT shown in parentheses
    non_reproduced_not_shown <- setdiff(trace_non_reproduced, non_reproduced_match_person)
    
    if (length(non_reproduced_not_shown) > 0) {
      if (length(trace_display_parts) > 0) {
        # There are some displayed alleles + additional ones
        trace_display <- paste(trace_display_parts, collapse=" / ")
        trace_display <- paste0(trace_display, " /…")
      } else {
        # No displayed alleles, only hidden ones
        trace_display <- "…"
      }
    } else {
      # All alleles are shown
      if (length(trace_display_parts) > 0) {
        trace_display <- paste(trace_display_parts, collapse=" / ")
      } else {
        trace_display <- ""
      }
    }
    
    # Format person display: just show all person alleles normally
    person_display <- if (length(person_alleles) > 0) {
      paste(person_alleles, collapse=" / ")
    } else {
      ""
    }
    
    # Build Result column with symbols
    result_symbols <- character(0)
    if (length(person_alleles) > 0) {
      for (allele in person_alleles) {
        if (allele %in% trace_replicated) {
          result_symbols <- c(result_symbols, "\u2713")  # ✓ reproduced (black/normal)
        } else if (allele %in% non_reproduced_match_person) {
          result_symbols <- c(result_symbols, "~")  # ~ single-copy (orange/parentheses)
        } else {
          result_symbols <- c(result_symbols, "\u2205")  # ∅ absent (red)
        }
      }
    }
    result_display <- if (length(result_symbols) > 0) {
      paste(result_symbols, collapse = " ")
    } else {
      ""
    }
    
    # Create comparison row - NOW WITH Result column
    comparison_row <- data.table(
      System = marker,
      Trace = trace_display,
      Person = person_display,
      Result = result_display,
      Reproduced_Match = paste(reproduced_and_match_person, collapse=" / ")
    )
    
    comparison_list[[marker]] <- comparison_row
  }
  
  # Combine all rows
  comparison_table <- rbindlist(comparison_list, fill = TRUE)
  
  # Add PCNs as attributes
  if (!is.null(trace_pcn)) {
    setattr(comparison_table, "Trace_PCN", trace_pcn)
  }
  if (!is.null(person_pcn)) {
    setattr(comparison_table, "Person_PCN", person_pcn)
  }
  
  # Add person metadata as attributes
  if (!is.null(attr(person_consensus, "Number"))) {
    setattr(comparison_table, "Person_Number", attr(person_consensus, "Number"))
  }
  if (!is.null(attr(person_consensus, "Number_Type"))) {
    setattr(comparison_table, "Person_Number_Type", attr(person_consensus, "Number_Type"))
  }
  if (!is.null(attr(person_consensus, "Status"))) {
    setattr(comparison_table, "Person_Status", attr(person_consensus, "Status"))
  }
  if (!is.null(attr(person_consensus, "Comments"))) {
    setattr(comparison_table, "Person_Comments", attr(person_consensus, "Comments"))
  }
  
  return(comparison_table)
}

# Detect OL alleles in consensus table
detect_ol_alleles <- function(consensus_table) {
  print("13")
  ol_info <- list()
  
  if (is.null(consensus_table) || nrow(consensus_table) == 0) {
    return(ol_info)
  }
  
  # Check All_Alleles column
  for (i in 1:nrow(consensus_table)) {
    marker <- consensus_table$Marker[i]
    all_alleles_str <- consensus_table$All_Alleles[i]
    
    if (!is.na(all_alleles_str) && all_alleles_str != "") {
      alleles <- trimws(unlist(strsplit(all_alleles_str, "/")))
      
      # Count OL alleles
      ol_count <- sum(grepl("^OL$", alleles, ignore.case = TRUE))
      
      if (ol_count > 0) {
        if (is.null(ol_info[[marker]])) {
          ol_info[[marker]] <- list(count = 0)
        }
        ol_info[[marker]]$count <- ol_count
      }
    }
    
    # Also check Replicated_Alleles if it exists (should not have OL, but check anyway)
    if ("Replicated_Alleles" %in% names(consensus_table)) {
      replicated_str <- consensus_table$Replicated_Alleles[i]
      
      if (!is.na(replicated_str) && replicated_str != "") {
        alleles <- trimws(unlist(strsplit(replicated_str, "/")))
        
        ol_count_rep <- sum(grepl("^OL$", alleles, ignore.case = TRUE))
        
        # This should not happen, but if it does, track it
        if (ol_count_rep > 0) {
          if (is.null(ol_info[[marker]])) {
            ol_info[[marker]] <- list(count = 0)
          }
          # Take the maximum count
          ol_info[[marker]]$count <- max(ol_info[[marker]]$count, ol_count_rep)
        }
      }
    }
  }
  
  return(ol_info)
}


create_multi_person_word_document <- function(file, comparison_data_list, input, language = "en",
                                              translate_status_fn = function(x) x,
                                              translate_type_fn = function(x) x) {
  comparisons <- comparison_data_list
  req(comparisons); req(length(comparisons) > 0)
  
  doc <- read_docx()
  
  fp_n <- fp_text(font.family = "Arial", font.size = 11)
  fp_h <- fp_text(font.family = "Arial", font.size = 14, bold = TRUE)
  fp_s <- fp_text(font.family = "Arial", font.size = 12, bold = TRUE)
  
  # seitenzahlen: unten mittig, Format "1 / 2"
  ftr <- block_list(
    fpar(
      run_word_field("PAGE", prop = fp_n),
      ftext(" / ", prop = fp_n),
      run_word_field("NUMPAGES", prop = fp_n),
      fp_p = fp_par(text.align = "center")
    )
  )
  doc <- body_set_default_section(doc,
                                  prop_section(
                                    footer_default = ftr
                                  )
  )
  
  first_comp <- comparisons[[1]]
  trace_name <- attr(first_comp, "Trace_Name")
  trace_pcn  <- attr(first_comp, "Trace_PCN")
  
  strings <- if (language == "de") {
    list(title="SmarTRace: Spur vs. Person Vergleich", gen="Erstellt:", version="Version:", trace="Spur:",
         pcn="Spur PCN-Nr.:", expert="Visum:", sorted="Sortiert nach:", kit="Kit",
         status="Status:", mh="System", th="Spur", ph="Person", rh="Ergebnis",
         red="Nicht vorhandene Allele", orange="Einfach vorhandene Allele",
         comment="Kommentar:", investigated="Untersucht:")
  } else {
    list(title="SmarTRace: Trace vs. Person Comparison", gen="Generated:", version="Version:", trace="Trace:",
         pcn="Trace PCN:", expert="Expert:", sorted="Sorted by:", kit="kit",
         status="Status:", mh="System", th="Trace", ph="Person", rh="Result",
         red="Absent alleles", orange="Single-copy alleles",
         comment="Comments:", investigated="Investigated:")
  }
  
  selected_kit <- if (!is.null(input$comparison_sort_kit)) input$comparison_sort_kit else "NGMselect"
  
  # Header
  doc <- body_add_fpar(doc, fpar(ftext(strings$title, prop = fp_h)))
  doc <- body_add_fpar(doc, fpar(ftext(paste(strings$version, APP_VERSION), prop = fp_n)))
  doc <- body_add_fpar(doc, fpar(ftext(paste(strings$gen, format(Sys.time(), "%d.%m.%Y %H:%M")), prop = fp_n)))
  if (!is.null(trace_name))
    doc <- body_add_fpar(doc, fpar(ftext(paste(strings$trace, trace_name), prop = fp_n)))
  if (!is.null(trace_pcn) && !is.na(trace_pcn))
    doc <- body_add_fpar(doc, fpar(ftext(paste(strings$pcn, trace_pcn), prop = fp_n)))
  
  expert_visum <- input$expert_visum
  if (!is.null(expert_visum) && expert_visum != "")
    doc <- body_add_fpar(doc, fpar(ftext(paste(strings$expert, expert_visum), prop = fp_n)))
  doc <- body_add_fpar(doc, fpar(ftext(paste(strings$sorted, selected_kit, strings$kit), prop = fp_n)))
  
  kit_names_attr <- attr(first_comp, "Trace_Kit_Names")
  if (!is.null(kit_names_attr) && length(kit_names_attr) > 0)
    doc <- body_add_fpar(doc, fpar(ftext(paste(strings$investigated, paste(kit_names_attr, collapse = ", ")), prop = fp_n)))
  
  doc <- body_add_par(doc, "", style = "Normal")
  
  # Helper: format person display name
  fmt_person <- function(person_name, person_number, person_number_type) {
    if (is.null(person_number) || is.na(person_number) || person_number == "") return(person_name)
    if (!is.null(person_number_type) && !is.na(person_number_type) && person_number_type == "PCN-No.") {
      p <- gsub(" ", "", person_number)
      if (nchar(p) == 10) return(paste0("PCN ", substr(p,1,2), " ", substr(p,3,8), " ", substr(p,9,10)))
      if (nchar(p) >= 8)  return(paste0("PCN ", substr(p,1,2), " ", substr(p,3,nchar(p))))
      return(paste0("PCN ", person_number))
    }
    if (!is.null(person_number_type) && !is.na(person_number_type) && person_number_type != "")
      return(paste0(person_number, " (", translate_type_fn(person_number_type), ")"))
    person_number
  }
  
  for (idx in seq_along(comparisons)) {
    person_name <- names(comparisons)[idx]
    comparison  <- comparisons[[person_name]]
    
    comp_sorted <- as.data.table(copy(comparison))
    comp_sorted$Marker <- comp_sorted$System
    comp_sorted <- sort_by_kit_order(comp_sorted, selected_kit)
    comp_sorted$Marker <- NULL
    
    person_number      <- attr(comparison, "Person_Number")
    person_number_type <- attr(comparison, "Person_Number_Type")
    person_status      <- attr(comparison, "Person_Status")
    person_comments    <- attr(comparison, "Person_Comments")
    
    if (idx > 1) doc <- body_add_break(doc)
    
    doc <- body_add_fpar(doc, fpar(ftext(
      paste("Person", fmt_person(person_name, person_number, person_number_type)), prop = fp_s)))
    if (!is.null(person_status) && !is.na(person_status) && person_status != "")
      doc <- body_add_fpar(doc, fpar(ftext(paste(strings$status, translate_status_fn(person_status)), prop = fp_n)))
    if (!is.null(person_comments) && !is.na(person_comments) && person_comments != "")
      doc <- body_add_fpar(doc, fpar(ftext(paste(strings$comment, person_comments), prop = fp_n)))
    
    doc <- body_add_par(doc, "", style = "Normal")
    
    # Count red/orange
    red_count <- 0; orange_count <- 0
    for (i in seq_len(nrow(comp_sorted))) {
      p_txt <- comp_sorted$Person[i]; t_txt <- comp_sorted$Trace[i]
      if (!is.na(p_txt) && p_txt != "" && !is.na(t_txt) && t_txt != "") {
        t_all <- trimws(unlist(strsplit(gsub(" /\u2026", "", t_txt), "/")))
        t_reg <- t_all[!grepl("^\\(.*\\)$", t_all)]
        t_par <- gsub("[()]", "", t_all[grepl("^\\(.*\\)$", t_all)])
        for (a in trimws(unlist(strsplit(p_txt, "/")))) {
          if      (a %in% t_reg) {}
          else if (a %in% t_par) orange_count <- orange_count + 1
          else                   red_count    <- red_count + 1
        }
      }
    }
    
    summary_parts <- c(
      if (red_count    > 0) paste(strings$red,    red_count),
      if (orange_count > 0) paste(strings$orange, orange_count)
    )
    if (length(summary_parts) > 0) {
      doc <- body_add_fpar(doc, fpar(ftext(paste(summary_parts, collapse = ", "), prop = fp_n)))
      doc <- body_add_par(doc, "", style = "Normal")
    }
    
    # Build display table
    disp <- data.frame(
      System = as.character(comp_sorted$System),
      Trace  = as.character(comp_sorted$Trace),
      Person = as.character(comp_sorted$Person),
      stringsAsFactors = FALSE
    )
    
    # Result column
    disp$Result <- sapply(seq_len(nrow(disp)), function(i) {
      p <- disp$Person[i]; tr <- disp$Trace[i]
      if (is.na(p) || p == "" || is.na(tr) || tr == "") return("")
      t_all <- trimws(unlist(strsplit(gsub(" /\u2026", "", tr), "/")))
      t_reg <- t_all[!grepl("^\\(.*\\)$", t_all)]
      t_par <- gsub("[()]", "", t_all[grepl("^\\(.*\\)$", t_all)])
      syms  <- sapply(trimws(unlist(strsplit(p, "/"))), function(a) {
        if (a %in% t_reg) "\u2713" else if (a %in% t_par) "~" else "\u2205"
      })
      paste(syms, collapse = " ")
    })
    
    # Bold markup in Trace column
    disp$Trace <- sapply(seq_len(nrow(disp)), function(i) {
      tr <- disp$Trace[i]; p <- disp$Person[i]
      if (is.na(tr) || tr == "" || is.na(p) || p == "") return(tr)
      for (a in trimws(unlist(strsplit(p, "/")))) {
        ae <- gsub("\\.", "\\\\.", a)
        tr <- gsub(paste0("(?<![0-9.(])\\b", ae, "\\b(?![0-9.)])"), paste0("**", a, "**"), tr, perl = TRUE)
        tr <- gsub(paste0("\\(", ae, "\\)"), paste0("**(", a, ")**"), tr, perl = TRUE)
      }
      tr
    })
    
    ft <- flextable(disp)
    ft <- set_header_labels(ft, System=strings$mh, Trace=strings$th, Person=strings$ph, Result=strings$rh)
    ft <- bold(ft, part="header"); ft <- bold(ft, j=1)
    ft <- align(ft, align="left", part="all")
    ft <- width(ft, j=1, width=1.0, unit="in"); ft <- width(ft, j=2, width=2.5, unit="in")
    ft <- width(ft, j=3, width=1.8, unit="in"); ft <- width(ft, j=4, width=0.85, unit="in")
    ft <- font(ft, fontname="Arial", part="all"); ft <- fontsize(ft, size=10, part="all")
    
    fp10 <- function(bold=FALSE) fp_text(font.family="Arial", font.size=10, color="#000000", bold=bold)
    
    for (i in seq_len(nrow(disp))) {
      tv <- disp$Trace[i]
      if (grepl("\\*\\*", tv)) {
        pts    <- strsplit(tv, "\\*\\*")[[1]]
        chunks <- Filter(Negate(is.null), lapply(seq_along(pts), function(j) {
          if (pts[j] == "") return(NULL)
          as_chunk(pts[j], props = fp10(bold = (j %% 2 == 0)))
        }))
        if (length(chunks) > 0)
          ft <- compose(ft, i=i, j=2, value=do.call(as_paragraph, chunks), part="body")
      }
      if (!is.na(disp$Person[i]) && disp$Person[i] != "")
        ft <- compose(ft, i=i, j=3, value=as_paragraph(as_chunk(disp$Person[i], props=fp10())), part="body")
      if (!is.na(disp$Result[i]) && disp$Result[i] != "")
        ft <- compose(ft, i=i, j=4, value=as_paragraph(as_chunk(disp$Result[i], props=fp10())), part="body")
    }
    
    doc <- body_add_flextable(doc, ft)
    doc <- body_add_par(doc, "", style = "Normal")
  }
  
  print(doc, target = file)
}





# # Check if person alleles are in stutter position of trace alleles
# check_stutter_positions <- function(comparison_table, trace_consensus) {
#   stutter_warnings <- list()
# 
#   for (i in 1:nrow(comparison_table)) {
#     marker <- comparison_table$System[i]
#     person_text <- comparison_table$Person[i]
#     trace_text <- comparison_table$Trace[i]
#     reproduced_match <- comparison_table$Reproduced_Match[i]
# 
#     # Skip if no person alleles or no reproduced trace alleles
#     if (is.na(person_text) || person_text == "" ||
#         is.na(reproduced_match) || reproduced_match == "") {
#       next
#     }
# 
#     # Skip AMEL (not applicable for stutter)
#     if (marker == "AMEL") next
# 
#     # Get REPRODUCED trace alleles from Reproduced_Match column
#     reproduced_alleles <- trimws(unlist(strsplit(reproduced_match, "/")))
#     reproduced_alleles <- reproduced_alleles[!is.na(reproduced_alleles) & reproduced_alleles != ""]
# 
#     # Get ALL trace alleles to check for parentheses (orange)
#     trace_all_text <- gsub(" /…", "", trace_text)
#     trace_alleles <- trimws(unlist(strsplit(trace_all_text, "/")))
# 
#     # Extract alleles in parentheses (orange ones)
#     trace_parentheses <- gsub("[()]", "", trace_alleles[grepl("^\\(.*\\)$", trace_alleles)])
# 
#     # Get person alleles
#     person_alleles <- trimws(unlist(strsplit(person_text, "/")))
# 
#     # Get marker's allele list
#     if (!marker %in% names(all_alleles_per_marker)) next
#     marker_alleles <- all_alleles_per_marker[[marker]]
# 
#     # Check each person allele
#     for (person_allele in person_alleles) {
#       # Skip if this allele is in reproduced trace alleles (green/bold/normal)
#       if (person_allele %in% reproduced_alleles) next
# 
#       # Skip if this allele is in parentheses (orange)
#       if (person_allele %in% trace_parentheses) next
# 
#       # NOW we have only RED alleles - check for stutter position
# 
#       # Find index of person allele in marker list
#       person_idx <- which(marker_alleles == person_allele)
#       if (length(person_idx) == 0) next
# 
#       # Check -1 and +1 positions in the allele list
#       potential_stutters <- c()
# 
#       # Check -1 position (minus stutter: person allele is one repeat smaller)
#       if (person_idx > 1) {
#         minus_allele <- marker_alleles[person_idx - 1]
#         if (minus_allele %in% reproduced_alleles) {
#           potential_stutters <- c(potential_stutters,
#                                   paste0("minus stutter of allele ", minus_allele))
#         }
#       }
# 
#       # Check +1 position (plus stutter: person allele is one repeat larger)
#       if (person_idx < length(marker_alleles)) {
#         plus_allele <- marker_alleles[person_idx + 1]
#         if (plus_allele %in% reproduced_alleles) {
#           potential_stutters <- c(potential_stutters,
#                                   paste0("plus stutter of allele ", plus_allele))
#         }
#       }
# 
#       # If stutter position found, add warning
#       if (length(potential_stutters) > 0) {
#         if (is.null(stutter_warnings[[marker]])) {
#           stutter_warnings[[marker]] <- list()
#         }
#         stutter_warnings[[marker]][[person_allele]] <- potential_stutters
#       }
#     }
#   }
# 
#   return(stutter_warnings)
# }
