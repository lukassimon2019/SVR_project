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

prompt_vec <- readLines(paste0(output_directory,"prompt_incl_context_1.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


# Process with Gemini API
conversation_part <- llm_message(prompt_conc_string) |>
  chat(gemini(.model = "gemini-2.0-flash"))

conversation_part_content <- conversation_part@message_history[[3]]$content

writeLines(conversation_part_content, paste0(output_directory, "07_08_individual_json_02_raw.txt"))
# writeLines(message, paste0(output_directory, conversation_part_name, "_message_fin_individual.txt"))
