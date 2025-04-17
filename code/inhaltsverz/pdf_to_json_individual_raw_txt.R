library(tidyllm)
# detach("package:gemini.R", unload = TRUE)


#open the R environment file
usethis::edit_r_environ()

# Set the path to the directory containing your PDF files
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\json_inhalt\\eduard_example_output\\")
temp_directory<-paste0(wd,"\\output\\temp_store\\")
prompt_directory<-paste0(wd,"\\prompts\\")
pdf_directory <- paste0(wd,"\\source_pdfs\\split_pdfs\\inhaltsverzeichnis\\test\\")


#choose whether prompt 1 or 2
prompt_num<-"1"
prompt_vec <- readLines(paste0(output_directory,"prompt_incl_context_",prompt_num,".txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


# Process with Gemini API
conversation_part <- llm_message(prompt_conc_string) |>
  chat(gemini(.model = "gemini-2.0-flash"))

conversation_part_content <- conversation_part@message_history[[3]]$content

writeLines(conversation_part_content, paste0(output_directory, "json_individual_raw_txt",prompt_num,".txt"))
# writeLines(message, paste0(output_directory, conversation_part_name, "_message_fin_individual.txt"))
