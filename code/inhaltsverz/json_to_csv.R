library(tidyllm)

wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\csv_classified\\")
temp_directory<-paste0(wd,"\\output\\temp_store\\")
prompt_directory<-paste0(wd,"\\prompts\\")

json_strings <- readRDS(file = paste0(temp_directory,"inhaltsverz_json_strings.rds"))
prompt_vec <- readLines(paste0(prompt_directory,"json_to_csv_prompt.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


message_contents <- list()
for (json in json_strings) {
  conversation <- llm_message((paste0(prompt_conc_string, json))) |>
    chat(gemini(.model = "gemini-2.0-flash"))
  
  conversation_name <- names(json_strings)[which(json_strings == json)]
  message_content <- conversation@message_history[[3]]$content
  message_contents[[conversation_name]] <- message_content
  
  # save to txt
  writeLines(message_content, paste0(output_directory, conversation_name, "_csv.txt"))
}

saveRDS(message_contents, file = paste0(temp_directory, "inhaltsverz_csv_strings.rds"))