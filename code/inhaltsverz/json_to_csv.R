library(tidyllm)

wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\csv\\")
input_directory<-paste0(wd,"\\output\\inhaltsverzeichnis\\json_incl_merge\\to_be_converted_batch\\")
prompt_directory<-paste0(wd,"\\prompts\\")

prompt_vec <- readLines(paste0(prompt_directory,"json_to_csv_prompt.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")

file_names <- list.files(path = input_directory, pattern = "\\.txt$", full.names = FALSE)


message_contents <- list()
for (file in file_names) {
  json<-paste(readLines(paste0(input_directory, file)),collapse="/n")
  conversation <- llm_message((paste0(prompt_conc_string, json))) |>
    chat(gemini(.model = "gemini-2.0-flash"))
  conversation_name <- tools::file_path_sans_ext(file)
  message_content <- conversation@message_history[[3]]$content
  message_contents[[conversation_name]] <- message_content
  
  # save to txt
  writeLines(message_content, paste0(output_directory, conversation_name, "_csv.txt"))
  print(paste(conversation_name,"stored"))
}

