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
prompt_fin <- paste(readLines(paste0(output_directory,"07_08_inhaltsverzeichnis_2_prompt_fin.txt")),collapse="")
upload_info <- gemini_upload_file(paste0(pdf_directory, "07_08_inhaltsverzeichnis1.pdf"))

# Process with Gemini API
conversation_part <- llm_message(prompt_fin) |>
  chat(gemini(
    .model = "gemini-2.0-flash", 
    .fileid = upload_info$name
  ))

conversation_part_content <- conversation_part@message_history[[3]]$content

writeLines(conversation_part_content, paste0(output_directory, "07_08_individual_json_02.txt"))
