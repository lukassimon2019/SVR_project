library(tidyllm)
library(pdftools)


#set R system language to English
Sys.setenv(LANGUAGE = "en")

#open the R environment file
usethis::edit_r_environ()

# Set the path to the directory containing your PDF files
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\csv_classified\\")
temp_directory<-paste0(wd,"\\output\\temp_store\\")
prompt_directory<-paste0(wd,"\\prompts\\")
pdf_directory <- paste0(wd,"\\split_pdfs\\Inhaltsverzeichnis\\test\\")


#read message content from txt file C:\Users\P-Simon\Documents\SVR\prompts\inhaltsverzeichnis_prompt.txt
prompt_vec <- readLines(paste0(prompt_directory,"inhaltsverz_structured_output_prompt.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


# Get a list of all PDF files in the directory
pdf_path_list <- list.files(pdf_directory, pattern = "\\.pdf$", full.names = TRUE)

#only store pdf names
pdf_filenames <- lapply(pdf_path_list, basename)
print("These are the pdf filenames",names(pdf_filenames))

# Define the schema for the extracted content
inhaltsverzeichnis_schema<-tidyllm_schema(
  kapitel=field_object(
    ueberschrift_eins=field_chr("Überschrift der obersten Ebene"),
    seite=field_chr("Seitenzahl der obersten Ebene"),
    zweite_ebene=field_object(
      ueberschrift_zwei=field_chr("Überschrift der zweiten Ebene"),
      seite=field_chr("Seitenzahl der zweiten Ebene"),
      dritte_und_niedrigere_ebene=field_object(
        ueberschrift_drei_niedriger=field_chr("Überschrift der dritten oder niedrigerer Ebene"),
        seite=field_chr("Seitenzahl der dritten Ebene"),
        .vector = TRUE
      ),
      .vector = TRUE
    ),
    .vector = TRUE
  )
)


message_contents <- list()

for (pdf in pdf_filenames) {
  conversation <- llm_message(prompt_conc_string, .pdf = paste0(pdf_directory, pdf)) |>
    chat(gemini(.model = "gemini-2.0-flash-lite"), .json_schema = inhaltsverzeichnis_schema)
  
  conversation_name <- gsub("\\.pdf$", "", pdf)
  message_content <- conversation@message_history[[3]]$content
  message_contents[[conversation_name]] <- message_content
  
  # Construct output file path
  writeLines(message_content, paste0(output_directory, conversation_name, "_json.txt"))
  print(paste0("File saved: ", conversation_name, "_json.txt"))
}

# message_content <- conversations[[1]]@message_history[[3]]$content
# writeLines(message_content, paste0(output_directory, names(conversations)[1],".txt"))
     
 
# Save the list to a file
saveRDS(message_contents, file = paste0(temp_directory, "inhaltsverz_json_strings.rds"))

