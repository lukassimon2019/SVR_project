wd<-getwd()
prompt_directory<-paste0(wd,"\\prompts\\")
pdf_directory <- paste0(wd,"\\source_pdfs\\split_pdfs\\inhaltsverzeichnis\\test\\")


#read message content from txt file C:\Users\P-Simon\Documents\SVR\prompts\inhaltsverzeichnis_prompt.txt
prompt_vec <- readLines(paste0(prompt_directory,"pdf_to_json_split_prompt_3A.txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


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


# Specify the path to your PDF file
pdf_file <- gemini_upload_file("source_pdfs\\split_pdfs\\inhaltsverzeichnis\\test\\07_08_inhaltsverzeichnis.pdf")
# Extract text from the PDF
text <- pdf_text("source_pdfs\\split_pdfs\\inhaltsverzeichnis\\test\\07_08_inhaltsverzeichnis.pdf")
prompt<-paste0(prompt_conc_string, text)

convo <- llm_message(prompt_conc_string) |>
    chat(gemini(.model = "gemini-2.0-flash-lite", .fileid = pdf_file$name))

writeLines(convo, paste0(output_directory, conversation_part_name, "_json.txt"))
