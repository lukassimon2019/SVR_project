library(pdftools)
library(qpdf)

input_dir <- "C:\\Users\\P-Simon\\Documents\\SVR\\alle_pdfs"
output_dir <- file.path(input_dir, "split_pdfs")

df_meta <- read_xlsx("C:\\Users\\P-Simon\\Documents\\SVR\\metadaten.xlsx")


# Define the function to split PDF
split_pdf <- function(pdf_path, start_page, end_page, output_path) {
  pdf_length <- pdf_info(pdf_path)$pages
  
  # Split at start_page
  pdf_subset(pdf_path, pages = 1:(start_page-1), output = paste0(output_path, "_part1.pdf"))
  
  # Split at end_page
  pdf_subset(pdf_path, pages = start_page:end_page, output = paste0(output_path, "_part2.pdf"))
  
  # Remaining pages
  if (end_page < pdf_length) {
    pdf_subset(pdf_path, pages = (end_page+1):pdf_length, output = paste0(output_path, "_part3.pdf"))
  }
}


# Split each PDF
apply(df_meta, 1, function(row) {
  pdf_path <- paste0(input_dir, row['pdf_name'])
  start_page <- as.numeric(row['inhaltsverzeichnis_start'])
  end_page <- as.numeric(row['inhaltsverzeichnis_ende'])
  output_path <- paste0(output_dir, tools::file_path_sans_ext(row['pdf_name']))
  
  split_pdf(pdf_path, start_page, end_page, output_path)
})


