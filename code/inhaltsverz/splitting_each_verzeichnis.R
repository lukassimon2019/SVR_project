# Define the base directory and list of PDF files
wd <- getwd()
pdf_directory <- paste0(wd, "/source_pdfs/split_pdfs/inhaltsverzeichnis/test/")
pdf_path_list <- list.files(pdf_directory, pattern = "\\.pdf$", full.names = TRUE)
pdf_filenames <- lapply(pdf_path_list, basename)

# Function to split a single PDF into 3-page chunks
split_pdf <- function(pdf_path, output_directory) {
  # Get the filename without extension
  pdf_filename_no_ext <- tools::file_path_sans_ext(basename(pdf_path))
  
  # Create a subfolder for the current PDF
  subfolder_name <- paste0(pdf_filename_no_ext, "_split")
  output_subfolder <- file.path(output_directory, subfolder_name)
  dir.create(output_subfolder, showWarnings = FALSE)
  
  # Get the number of pages in the PDF
  pdf_info <- system2("pdfinfo", args = shQuote(pdf_path), stdout = TRUE)
  pages_line <- grep("^Pages:", pdf_info, value = TRUE)
  num_pages <- as.integer(gsub("^Pages:\\s+(\\d+)$", "\\1", pages_line))
  
  if (length(num_pages) == 0 || is.na(num_pages) || num_pages <= 0) {
    cat(paste0("Could not determine the number of pages for: ", basename(pdf_path), ". Skipping.\n"))
    return()
  }
  
  # Calculate the number of 3-page chunks
  num_chunks <- ceiling(num_pages / 3)
  
  # Loop through the chunks and split the PDF
  for (i in 1:num_chunks) {
    start_page <- (i - 1) * 3 + 1
    end_page <- min(i * 3, num_pages)
    
    output_filename <- paste0(pdf_filename_no_ext, "_part_", sprintf("%03d", i), ".pdf")
    output_path <- file.path(output_subfolder, output_filename)
    
    # Construct the pdftk command
    pdftk_command <- paste0(
      "pdftk ", shQuote(pdf_path),
      " cat ", start_page, "-", end_page,
      " output ", shQuote(output_path)
    )
    
    # Execute the pdftk command
    system(pdftk_command)
    
    cat(paste0("Created: ", output_filename, " in ", subfolder_name, "\n"))
  }
  
  cat(paste0("Finished splitting: ", basename(pdf_path), "\n\n"))
}

# Loop through the list of PDF files and apply the splitting function
for (pdf_file in pdf_path_list) {
  split_pdf(pdf_file, pdf_directory)
}

cat("PDF splitting process completed.\n")