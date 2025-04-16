library(tidyllm)
library(pdftools)


#open the R environment file
usethis::edit_r_environ()

# Set the path to the directory containing your PDF files
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\json_inhalt\\")
temp_directory<-paste0(wd,"\\output\\temp_store\\")
prompt_directory<-paste0(wd,"\\prompts\\")
pdf_directory <- paste0(wd,"\\source_pdfs\\split_pdfs\\inhaltsverzeichnis\\test\\")

#read message content from txt file C:\Users\P-Simon\Documents\SVR\prompts\inhaltsverzeichnis_prompt.txt
prompt_vec <- readLines(paste0(prompt_directory,"pdf_to_json_split_prompt_3A.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


# Get a list of all PDF files in the directory
pdf_path_list <- list.files(pdf_directory, pattern = "\\.pdf$", full.names = TRUE)

#only store pdf names
pdf_filenames <- lapply(pdf_path_list, basename)
print(paste("These are the pdf filenames",names(pdf_filenames)))


#initiate list only in beginning. Afterwards leave commented out to not delete saved RDS file
# all_contents <- list()
# saveRDS(all_contents, file = paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))


# Process each PDF file
for (pdf in pdf_filenames) {
  
  # Create conversation name by removing .pdf extension
  conversation_name <- gsub("\\.pdf$", "", pdf)
  
  # Initialize pdf_parts list for this conversation
  pdf_parts <- list()
  
  # Upload the PDF to Gemini
  upload_info <- gemini_upload_file(paste0(pdf_directory, pdf))
  
  # Start the loop for processing the PDF content
  run_number <- 1
  repeat {
    # Get previous parts if available
    previous_parts <- if (run_number > 1) {
      # Combine all previous parts
      paste(unlist(pdf_parts[1:(run_number - 1)]), collapse = " ")
    } else {
      ""
    }
    
    # Create prompt with concatenated previous parts
    prompt_fin <- paste(prompt_conc_string, previous_parts)
    
    
    # Process with Gemini API
    conversation_part <- llm_message(prompt_fin) |>
      chat(gemini(
        .model = "gemini-2.0-flash-lite", 
        .fileid = upload_info$name
      ))
    
    # Extract the response content
    conversation_part_content <- conversation_part@message_history[[3]]$content
    
    # Create a unique name for this conversation part
    conversation_part_name <- paste0(conversation_name, "_", run_number)
    
    # Store the content in pdf_parts
    pdf_parts[[run_number]] <- conversation_part_content
    
    # Write to text files for transparency
    writeLines(prompt_fin, paste0(output_directory, conversation_part_name, "_prompt_fin_upload.txt"))
    writeLines(conversation_part_content, paste0(output_directory, conversation_part_name, "_json_upload.txt"))
    print(paste0("File saved: ", conversation_part_name, "_json.txt"))
    
    # Check if we should end the loop
    if (grepl("ende_json", conversation_part_content)) {
      # Remove the end_json marker
      pdf_parts[[run_number]] <- gsub("ende_json", "", conversation_part_content)
      break
    }
    
    # Increment run number for next iteration
    run_number <- run_number + 1
  }
  
  # Add the processed parts to the all_contents list
  all_contents <- readRDS(paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))
  all_contents[[conversation_name]] <- pdf_parts
  
  # Save the updated all_contents to RDS
  saveRDS(all_contents, file = paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))
}


