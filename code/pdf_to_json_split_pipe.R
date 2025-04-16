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
  # Upload the PDF to Gemini
  upload_info <- gemini_upload_file(paste0(pdf_directory, pdf))
  
  # Process with Gemini API
  conversation_1 <- llm_message(prompt_conc_string) |>
    chat(gemini(
      .model = "gemini-2.0-flash-lite",
      .fileid = upload_info$name
    ))
  
  # Extract the response content
  reply_1 <- conversation_1|>get_reply(1)
  
  # Check if we should end the loop
  if (grepl("ende_json", reply_1)) {
    print("Ende der Konversation erreicht.")
  } else {
    print("Start zweiter run")
    conversation_2 <- conversation_1 |>
      llm_message("Stelle das json fertig. Mach mit dem json dort weiter wo du aufgehört hast, wiederhole nicht was du bereits geschrieben hast. Vergiss nicht am Ende 'ende_json' zu sagen") |>
      chat(gemini(
        .model = "gemini-2.0-flash",
        .fileid = upload_info$name
      ))
    
    # Extract the response content
    reply_2 <- conversation_2|>get_reply(2)
    
    # Check if we should end the loop
    if (grepl("ende_json", reply_2)) {
      print("Ende der Konversation erreicht.")
    } else {
      print("Start dritter run")
      conversation_3 <- conversation_2 |>
        llm_message("Stelle das json fertig. Mach mit dem json dort weiter wo du aufgehört hast, wiederhole nicht was du bereits geschrieben hast. Vergiss nicht am Ende 'ende_json' zu sagen") |>
        chat(gemini(
          .model = "gemini-2.0-flash",
          .fileid = upload_info$name
        ))
      
      reply_3 <- conversation_3|>get_reply(3)
    }
  }
}
  #   
  #     # Create a unique name for this conversation part
  #     conversation_part_name <- paste0(conversation_name, "_", run_number)
  #     
  #     # Store the content in pdf_parts
  #     pdf_parts[[run_number]] <- conversation_part_content
  #     
  #     # Write to text files for transparency
  #     writeLines(prompt_fin, paste0(output_directory, conversation_part_name, "_prompt_fin.txt"))
  #     writeLines(conversation_part_content, paste0(output_directory, conversation_part_name, "_json.txt"))
  #     print(paste0("File saved: ", conversation_part_name, "_json.txt"))
  #     
  # 
  #     
  #     # Increment run number for next iteration
  #     run_number <- run_number + 1
  #   }
  #   
  #   # Add the processed parts to the all_contents list
  #   all_contents <- readRDS(paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))
  #   all_contents[[conversation_name]] <- pdf_parts
  #   
  #   # Save the updated all_contents to RDS
  #   saveRDS(all_contents, file = paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))
  # }
  # 
  # 
  