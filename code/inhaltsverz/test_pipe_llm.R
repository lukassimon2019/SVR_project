library(tidyllm)
library(pdftools)


#open the R environment file
usethis::edit_r_environ()


  # Process with Gemini API
  conversation_1 <- llm_message("What is the largest city in Germany") |>
    chat(gemini())    

    conversation_2<-conversation_1 |>
      llm_message("In welchem Bundesland ist diese Stadt") |>
      chat(gemini())    
    
  
      conversation_3<-conversation_2 |>
        llm_message("Nenne eine berühmte Person aus dieser Stadt") |>
        chat(gemini())    
      
      reply_1 <- conversation_3|>get_reply(1) 
      reply_2 <- conversation_3|>get_reply(2)
      reply_3 <- conversation_3|>get_reply(3)
    
      conversation_3@message_history[[3]]$content
    #   
    #     # Create a unique name for this conversation part
    #     conversation_part_name <- paste0(conversation_name, "_", run_number)
    #     
    #     # Store the content in pdf_parts
    #     pdf_parts[[run_number]] <- conversation_part_content
    #     
    #     # Write to text files for transparency
    #     writeLines(prompt_fin, paste0(output_directory, conversation_part_name, "_prompt_fin.txt"))
    #     writeLines(conversation_part_content, paste0(output_directory, conversation_part_name, "_json.txt"))
    #     print(paste0("File saved: ", conversation_part_name, "_json.txt"))
    #     
    # 
    #     
    #     # Increment run number for next iteration
    #     run_number <- run_number + 1
    #   }
    #   
    #   # Add the processed parts to the all_contents list
    #   all_contents <- readRDS(paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))
    #   all_contents[[conversation_name]] <- pdf_parts
    #   
    #   # Save the updated all_contents to RDS
    #   saveRDS(all_contents, file = paste0(temp_directory, "inhaltsverz_json_strings_split.rds"))
    # }
    # 
    # 
    