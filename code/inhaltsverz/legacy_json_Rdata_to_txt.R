temp_directory<-"C:\\Users\\P-Simon\\Documents\\SVR\\output\\temp_store\\"
conversations <- readRDS(file = paste0(temp_directory,"inhaltsverz_json_strings.rds"))


prompt_vec<-readLines("C:\\Users\\P-Simon\\Documents\\SVR\\prompts\\prompt_1.1.txt")
prompt_single_string <- paste(prompt_vec, collapse = "\n")

for (i in seq_along(conversations)) {
  # Extract the JSON content from the message history
  json_string <- conversations[[i]]@message_history[[3]]$content
  # Get the name from the names of the conversations list
  conversation_name <- names(conversations)[i]
  conversation <- llm_message(paste0(prompt_single_string,json_string)) |>
    chat(gemini(.model = "gemini-2.0-flash-lite"))
  convo_classification[[conversation_name]] <- conversation@message_history[[3]]$content
}



json_string<-conversations[[1]]@message_history[[3]]$content
test_prompt<-paste0(prompt_single_string,json_string)


convo_classification <- list()

for (pdf in pdf_filenames) {
  conversation <- llm_message(message_content, .pdf = paste0(pdf_directory, pdf)) |>
    chat(gemini(.model = "gemini-2.0-flash-lite"), .json_schema = inhaltsverzeichnis_schema)
  # Extract the response from the llm object
  response <- conversation@message_history[[3]]$content
  conversation_name <- gsub("\\.pdf$", "", pdf)
  convo_classification[[conversation_name]] <- conversation
}

# Write the content to a file
# writeLines(content, paste0("C:\\Users\\P-Simon\\Documents\\SVR\\output\\inhaltsverzeichnis\\json_as_txt\\json_", conversation_name, ".txt"))