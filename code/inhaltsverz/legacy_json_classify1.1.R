library(tidyllm)

temp_directory<-"C:\\Users\\P-Simon\\Documents\\SVR\\output\\temp_store\\"
output_directory<-"C:\\Users\\P-Simon\\Documents\\SVR\\output\\inhaltsverzeichnis\\json_classified_output\\"

conversations <- readRDS(file = paste0(temp_directory,"inhaltsverz_json_strings.rds"))


prompt_vec<-readLines("C:\\Users\\P-Simon\\Documents\\SVR\\prompts\\prompt_1.2.txt")
prompt_single_string <- paste(prompt_vec, collapse = "\n")

# Initialize an empty list to store the classification results
convo_classification <- list()

# Iterate over each conversation in the list
for (i in seq_along(conversations)) {
  conversation_name <- names(conversations)[i]
  
  if (!is.null(conversations[[i]]) && 
      length(conversations[[i]]@message_history) >= 3 && 
      !is.null(conversations[[i]]@message_history[[3]]$content)) {
    
    json_string <- conversations[[i]]@message_history[[3]]$content
    
    # Write the original json string to a file.
    # output_file_original <- file.path("C:", "Users", "P-Simon", "Documents", "SVR", paste0(conversation_name, "_original.txt"))
    # writeLines(json_string, output_file_original)
    
    tryCatch({
      conversation <- llm_message(paste0(prompt_single_string, json_string)) |>
        chat(gemini(.model = "gemini-2.0-flash-lite"))
      
      if (!is.null(conversation) && 
          length(conversation@message_history) >= 3 && 
          !is.null(conversation@message_history[[3]]$content)) {
        
        convo_classification[[conversation_name]] <- conversation@message_history[[3]]$content
        
        # delete
        # output_file_llm <- file.path("C:", "Users", "P-Simon", "Documents", "SVR", paste0(conversation_name, "_llm_output.txt"))
        # writeLines(conversation@message_history[[3]]$content, output_file_llm)
        # Write the LLM output to a file.
        writeLines(conversation@message_history[[3]]$content, paste0(output_directory, conversation_name, "_llm_output.txt"))
        
      } else {
        warning(paste("LLM chat result for", conversation_name, "did not have expected structure."))
        convo_classification[[conversation_name]] <- "LLM chat result error"
      }
    }, error = function(e) {
      warning(paste("Error processing", conversation_name, ":", e$message))
      convo_classification[[conversation_name]] <- paste("Error:", e$message)
    })
  } else {
    warning(paste("Conversation", conversation_name, "did not have expected structure."))
    convo_classification[[conversation_name]] <- "Conversation structure error"
  }
}

# Optional: Save the results to an RDS file
saveRDS(convo_classification,paste0(temp_directory, "convo_classification_results.rds"))