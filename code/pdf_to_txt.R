# Load the pdftools package
library(pdftools)

#open the R environment file
usethis::edit_r_environ()

# Set the path to the directory containing your PDF files
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\txt\\")
pdf_directory <- paste0(wd,"\\source_pdfs\\split_pdfs\\inhaltsverzeichnis\\batch_to_be_processed")



# Get a list of all PDF files in the directory
pdf_files <- list.files(pdf_directory, pattern = "\\.pdf$", full.names = TRUE)


# Check if any PDF files were found
if (length(pdf_files) == 0) {
  cat("No PDF files found in the specified directory.\n")
} else {
  # Loop through each PDF file and extract the text
  for (pdf_file in pdf_files) {
    # Read the text from the PDF file
    text <- pdf_text(pdf_file)
    
    # Print the name of the PDF file
    cat(sprintf("Extracting text from: %s\n", basename(pdf_file))) # basename extracts only the file name
    
    # Create a filename for the output text file
    txt_filename <- paste0(tools::file_path_sans_ext(basename(pdf_file)), ".txt")
    output_file_path <- file.path(output_directory, txt_filename) # Save in the same directory as the PDFs
    
    # Write the extracted text to a file
    file_conn <- file(output_file_path, "w") # Open a file connection for writing
    for (page in seq_along(text)) {
      writeLines(sprintf("Page %d:\n%s\n", page, text[page]), con = file_conn) # Write to the file
    }
    close(file_conn) # Close the file connection
    
    cat(sprintf("Text saved to: %s\n", output_file_path)) # Inform the user
  }
}