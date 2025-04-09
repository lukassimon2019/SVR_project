library(readxl)
library(pdftools)
library(qpdf)

input_dir <- "C:\\Users\\P-Simon\\Documents\\SVR\\alle_pdfs\\"
output_dir <- "C:\\Users\\P-Simon\\Documents\\SVR\\split_pdfs\\Inhaltsverzeichnis\\"

df_meta <- read_xlsx("C:\\Users\\P-Simon\\Documents\\SVR\\metadaten.xlsx")


# Define the function to split PDF
split_pdf <- function(pdf_path, start_page, end_page, output_path) {

  # Split at end_page
  pdf_subset(pdf_path, pages = start_page:end_page, output = paste0(output_path, "_inhaltsverzeichnis.pdf"))
}

# Split each PDF
apply(df_meta, 1, function(row) {
  pdf_path <- paste0(input_dir, row['pdf_name'])
  start_page <- as.numeric(row['inhaltsverzeichnis_start'])
  end_page <- as.numeric(row['inhaltsverzeichnis_ende'])
  output_path <- paste0(output_dir, tools::file_path_sans_ext(row['pdf_name']))
  
  split_pdf(pdf_path, start_page, end_page, output_path)
  #print confirmation message
  print(paste("Splitting", pdf_path, "from page", start_page, "to", end_page, "to", output_path))
}

)



