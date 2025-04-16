detach("package:tidyllm", unload = TRUE)
library(gemini.R)


setAPI("enter_key_here")

# Set the path to the directory containing your PDF files
wd<-getwd()
output_directory <-paste0(wd,"\\output\\inhaltsverzeichnis\\json_inhalt\\")
temp_directory<-paste0(wd,"\\output\\temp_store\\")
prompt_directory<-paste0(wd,"\\prompts\\")
pdf_directory <- paste0(wd,"\\source_pdfs\\split_pdfs\\inhaltsverzeichnis\\test\\")


#choose whether prompt 1 or 2
prompt_num<-"2"
prompt_vec <- readLines(paste0(output_directory,"prompt_incl_context_",prompt_num,".txt"))
prompt_conc_string <- paste(prompt_vec, collapse = "\n")


answer<-gemini(prompt_conc_string)


writeLines(answer, paste0(output_directory, "json_individual_raw_txt_diff_pack_",prompt_num,".txt"))
# writeLines(message, paste0(output_directory, conversation_part_name, "_message_fin_individual.txt"))
