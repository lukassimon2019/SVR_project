library(tidyllm)
usethis::edit_r_environ()
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\csv_classified\\")
temp_directory<-paste0(wd,"\\output\\temp_store\\")
prompt_directory<-paste0(wd,"\\prompts\\")

csv_strings <- readRDS(file = paste0(temp_directory,"inhaltsverz_csv_strings.rds"))
prompt_vec <- readLines(paste0(prompt_directory,"class_prompt_csv_1.1.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


Sys.setenv(OPENAI_API_KEY = "AIzaSyB_jza8TWsNld8RcEv4GYNkza8h2OnClDQ")

message_contents <- list()
for (csv in csv_strings) {
  conversation <- llm_message((paste0(prompt_conc_string, csv))) |>
    chat(gemini(.model = "gemini-2.0-flash"))
  
  conversation_name <- names(csv_strings)[which(csv_strings == csv)]
  message_content <- conversation@message_history[[3]]$content
  message_contents[[conversation_name]] <- message_content
  
  # save to txt
  writeLines(message_content, paste0(output_directory, conversation_name, "_classified.txt"))
  print(paste(conversation_name,"sucessfully saved"))
}

saveRDS(message_contents, file = paste0(temp_directory, "inhaltsverz_classified.rds"))