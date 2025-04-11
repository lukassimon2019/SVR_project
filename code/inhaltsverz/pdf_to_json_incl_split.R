library(tidyllm)
library(pdftools)


#set R system language to English
Sys.setenv(LANGUAGE = "en")

#open the R environment file
usethis::edit_r_environ()


# Set the path to the directory containing your PDF files
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\json_inhalt\\")
temp_directory<-paste0(wd,"\\output\\temp_store\\")
prompt_directory<-paste0(wd,"\\prompts\\")
pdf_directory <- paste0(wd,"\\source_pdfs\\split_pdfs\\inhaltsverzeichnis\\test\\")

#read message content from txt file C:\Users\P-Simon\Documents\SVR\prompts\inhaltsverzeichnis_prompt.txt
prompt_vec <- readLines(paste0(prompt_directory,"pdf_to_json_split_prompt.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")

# Get a list of all subdirectories (folders) within the pdf_directory
folder_names <- list.dirs(pdf_directory, full.names = FALSE, recursive = FALSE)
# Initialize an empty list to store the grouped PDF filenames
grouped_pdf_filenames <- list()
# Iterate through each folder
for (folder in folder_names) {
  current_folder_path <- file.path(pdf_directory, folder)
  pdf_files_in_folder <- list.files(current_folder_path, pattern = "\\.pdf$", full.names = FALSE)
    grouped_pdf_filenames[[folder]] <- pdf_files_in_folder
}
print(grouped_pdf_filenames)


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


all_contents <- list()

for (group_name in names(grouped_pdf_filenames)){
  member_contents <- list()
  for (member in grouped_pdf_filenames[[group_name]]){
    full_pdf_path <- file.path(pdf_directory, group_name, member)
    upload_info <- gemini_upload_file(full_pdf_path)
    #add prior json output to prompt only if is not first member (otherwise no prior output exists)
    if (length(member_contents) > 0) {
      prompt_fin <- paste(prompt_conc_string, member_contents)
    } else {
      prompt_fin <- prompt_conc_string
    }
    #send to LLM
    conversation <- llm_message(prompt_fin) |>
      chat(gemini(.model = "gemini-2.0-flash-lite", .fileid = upload_info$name), .json_schema = inhaltsverzeichnis_schema)
    member_name <- gsub("\\.pdf$", "", member)
    message_content <- conversation@message_history[[3]]$content
    member_contents[[member_name]] <- message_content
    
    writeLines(prompt_fin, paste0(output_directory, group_name,member_name, "_prompt_fin.txt"))
    writeLines(message_content, paste0(output_directory, group_name,member_name, "_json.txt"))
  }
  all_contents[[group_name]]<- member_contents
}
# Save the entire list of contents to a single RDS file
saveRDS(all_contents, file = paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))

