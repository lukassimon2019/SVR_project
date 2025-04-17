# Set the path to the directory containing your PDF files
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\json_incl_merge\\")
input_directory <- paste0(wd,"\\output\\inhaltsverzeichnis\\json_inhalt\\")

# Script to merge txt files based on common prefixes

# Function to extract prefix from filename (first 5 characters, e.g., "00_01")
get_prefix <- function(filename) {
  return(substr(filename, 1, 5))
}

# Get list of all txt files in the input directory
txt_files <- list.files(path = input_directory, pattern = "\\.txt$", full.names = FALSE)

# Filter out files with "message" in their names
txt_files <- txt_files[!grepl("message", txt_files)]

# Get unique prefixes
prefixes <- unique(sapply(txt_files, get_prefix))

# For each prefix, merge the corresponding files
for (prefix in prefixes) {
  # Find all files with current prefix
  files_to_merge <- txt_files[grepl(paste0("^", prefix), txt_files)]
  
  if (length(files_to_merge) > 0) {
    # Create output filename
    output_file <- paste0(output_directory, prefix, "_merged.txt")
    
    # Initialize an empty string to store merged content
    merged_content <- ""
    
    # Read and append content from each file
    for (file in files_to_merge) {
      full_path <- paste0(input_directory, file)
      file_content <- readLines(full_path, warn = FALSE)
      merged_content <- c(merged_content, file_content, "") # Add empty line between files
    }
    
    # Write merged content to output file
    writeLines(merged_content, output_file)
    
    # Print status message
    cat("Merged", length(files_to_merge), "files with prefix", prefix, "into", output_file, "\n")
  }
}

cat("Merging complete!\n")