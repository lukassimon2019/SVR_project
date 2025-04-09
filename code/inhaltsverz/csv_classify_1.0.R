
output_directory <- "C:\\Users\\P-Simon\\Documents\\SVR\\output\\inhaltsverzeichnis\\csv_classified\\"
temp_directory<-"C:\\Users\\P-Simon\\Documents\\SVR\\output\\temp_store\\"
prompt_directory<-"C:\\Users\\P-Simon\\Documents\\SVR\\prompts\\"

csv_strings <- readRDS(file = paste0(temp_directory,"inhaltsverz_csv_strings.rds"))
prompt_vec <- readLines(paste0(prompt_directory,"class_prompt_csv.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


message_contents <- list()
for (csv in csv_strings) {
  conversation <- llm_message((paste0(prompt_conc_string, csv))) |>
    chat(gemini(.model = "gemini-2.0-flash-lite"))
  
  conversation_name <- names(csv_strings)[which(csv_strings == csv)]
  message_content <- conversation@message_history[[3]]$content
  message_contents[[conversation_name]] <- message_content
  
  # save to txt
  writeLines(message_content, paste0(output_directory, conversation_name, "_classified.txt"))
}

saveRDS(message_contents, file = paste0(temp_directory, "inhaltsverz_classified.rds"))