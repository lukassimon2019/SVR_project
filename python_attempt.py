import os
import google.generai as genai
from google.generai import types
from google.generai import errors
import glob
import json
import time # For potential delays if needed, though not explicitly in R version
pip install -q -U google-generativeai
# --- Configuration ---

# 1. Set up API Key (Choose ONE method)
#    Method A: Set environment variable BEFORE running the script
#    In your terminal: export GOOGLE_API_KEY='YOUR_API_KEY'
#    Method B: Pass directly (less recommended for security)
#    api_key = 'YOUR_API_KEY'
#    genai.configure(api_key=api_key)

# Ensure the GOOGLE_API_KEY environment variable is set
if not os.getenv('GOOGLE_API_KEY'):
    raise ValueError("Please set the GOOGLE_API_KEY environment variable.")

genai.configure(api_key=os.getenv('AIzaSyBoE0DmXTfMBPrtxDWhoOZKoJhM0n2CSFs'))

# Initialize the Gemini Client for the Developer API (required for file uploads)
# If you were using Vertex AI, the client initialization would be different
# and you'd need to upload files to GCS first.
client = genai.Client() # Assumes GOOGLE_API_KEY env var is set

# Define directory paths
wd = os.getcwd()
output_directory = os.path.join(wd, "output", "inhaltsverzeichnis", "json_inhalt")
temp_directory = os.path.join(wd, "output", "temp_store")
prompt_directory = os.path.join(wd, "prompts")
# Original R code had 'test' subfolder, adjust if needed
pdf_directory = os.path.join(wd, "source_pdfs", "split_pdfs", "inhaltsverzeichnis", "test")

# Create output directories if they don't exist
os.makedirs(output_directory, exist_ok=True)
os.makedirs(temp_directory, exist_ok=True)

# --- Read Prompt ---
prompt_file_path = os.path.join(prompt_directory, "pdf_to_json_split_prompt_3A.txt")
try:
    with open(prompt_file_path, 'r', encoding='utf-8') as f:
        prompt_conc_string = f.read()
except FileNotFoundError:
    raise FileNotFoundError(f"Prompt file not found at: {prompt_file_path}")

# --- List PDF Files ---
pdf_path_pattern = os.path.join(pdf_directory, "*.pdf")
pdf_path_list = glob.glob(pdf_path_pattern)

if not pdf_path_list:
    print(f"Warning: No PDF files found in {pdf_directory}")

pdf_filenames = [os.path.basename(p) for p in pdf_path_list]
print(f"Found PDF filenames: {pdf_filenames}")

# --- Load or Initialize Results ---
# Mimic the RDS persistence using a JSON file
results_file_path = os.path.join(temp_directory, "inhaltsverz_json_strings_split.json")
all_contents = {}
if os.path.exists(results_file_path):
    try:
        with open(results_file_path, 'r', encoding='utf-8') as f:
            all_contents = json.load(f)
        print(f"Loaded previous results from {results_file_path}")
    except json.JSONDecodeError:
        print(f"Warning: Could not decode JSON from {results_file_path}. Starting fresh.")
    except Exception as e:
        print(f"Warning: Error loading {results_file_path}: {e}. Starting fresh.")
else:
     print("No previous results file found. Starting fresh.")


# --- Process Each PDF File ---
model_name = 'gemini-1.5-flash-latest' # Or 'gemini-2.0-flash-001' etc. Choose a model supporting file input.

for pdf_filename in pdf_filenames:
    full_pdf_path = os.path.join(pdf_directory, pdf_filename)
    conversation_name = os.path.splitext(pdf_filename)[0] # Remove .pdf extension

    # Skip if already processed in a previous run (based on loaded data)
    if conversation_name in all_contents:
        print(f"Skipping '{pdf_filename}' as results already exist for '{conversation_name}'.")
        continue

    print(f"\n--- Processing: {pdf_filename} ---")

    pdf_parts = [] # List to store JSON string parts for the current PDF
    uploaded_file = None # To keep track of the file object for deletion

    try:
        # --- Upload the PDF to Gemini ---
        # Note: Files are only supported in the Gemini Developer API.
        print(f"Uploading {pdf_filename}...")
        # Use display_name to help identify the file in the API if needed
        uploaded_file = client.files.upload(
            file=full_pdf_path,
            display_name=pdf_filename
        )
        print(f"Uploaded successfully. File name: {uploaded_file.name}, URI: {uploaded_file.uri}")

        # --- Loop for processing PDF content iteratively ---
        run_number = 1
        while True:
            print(f"Processing part {run_number} for {pdf_filename}...")

            # --- Prepare Prompt ---
            previous_parts_content = ""
            if run_number > 1:
                # Combine all previous JSON parts obtained so far
                previous_parts_content = "\n".join(pdf_parts) # Join with newline, adjust if needed

            # Append previous parts to the main prompt
            # Ensure there's a clear separation or instruction for the model
            prompt_fin = f"{prompt_conc_string}\n\n--- Previously Extracted Parts (if any) ---\n{previous_parts_content}\n\n--- Continue Extraction ---"
            # Or simply: prompt_fin = f"{prompt_conc_string}\n{previous_parts_content}" depending on the prompt's design

            # --- Generate Content with Gemini API ---
            # Contents should be a list containing the prompt and the file reference
            request_contents = [prompt_fin, uploaded_file] # Pass prompt string and file object

            try:
                response = client.models.generate_content(
                    model=model_name,
                    contents=request_contents,
                    # Add safety settings, generation config if needed (e.g., temperature)
                    # config=types.GenerateContentConfig(...)
                )

                # --- Extract Response ---
                # Check if the response has text content
                if not response.candidates or not response.candidates[0].content.parts:
                     conversation_part_content = ""
                     print("Warning: Received empty response from API.")
                     # Decide how to handle empty responses: break, retry, log?
                     # For now, we'll store empty and check for end marker later
                else:
                    conversation_part_content = response.text # Simplest way to get text

                # --- Save Intermediate Files ---
                conversation_part_name = f"{conversation_name}_{run_number}"
                prompt_output_path = os.path.join(output_directory, f"{conversation_part_name}_prompt_fin.txt")
                json_output_path = os.path.join(output_directory, f"{conversation_part_name}_json.txt")

                with open(prompt_output_path, 'w', encoding='utf-8') as f:
                    f.write(prompt_fin)
                with open(json_output_path, 'w', encoding='utf-8') as f:
                    f.write(conversation_part_content)
                print(f"Saved intermediate files: {conversation_part_name}_prompt_fin.txt, {conversation_part_name}_json.txt")

                # --- Check for End Marker ---
                if "ende_json" in conversation_part_content:
                    print("Found 'ende_json' marker. Finalizing this PDF.")
                    # Remove the end marker before storing
                    final_part_content = conversation_part_content.replace("ende_json", "").strip()
                    if final_part_content: # Avoid adding empty strings if marker was the only content
                         pdf_parts.append(final_part_content)
                    break # Exit the inner while loop for this PDF
                else:
                    # Store the content (without end marker)
                    if conversation_part_content: # Avoid adding empty strings
                        pdf_parts.append(conversation_part_content.strip())
                    # Check for potential infinite loops (e.g., max runs)
                    if run_number >= 10: # Safety break after 10 parts
                        print("Warning: Reached maximum parts limit (10). Stopping processing for this PDF.")
                        break

                # Increment run number for the next iteration
                run_number += 1
                # Optional: Add a small delay if hitting rate limits
                # time.sleep(1)

            except errors.APIError as e:
                print(f"Error during Gemini API call for {pdf_filename} (Part {run_number}): {e}")
                # Decide how to handle API errors: retry, skip PDF, stop script?
                break # Stop processing this PDF on API error
            except Exception as e:
                print(f"An unexpected error occurred during content generation for {pdf_filename} (Part {run_number}): {e}")
                break # Stop processing this PDF on other errors

        # --- Store Final Results for this PDF ---
        all_contents[conversation_name] = pdf_parts
        print(f"Finished processing {pdf_filename}. Stored {len(pdf_parts)} parts.")

        # --- Save Updated Results to JSON File (mimics saveRDS) ---
        try:
            with open(results_file_path, 'w', encoding='utf-8') as f:
                json.dump(all_contents, f, indent=4) # Use indent for readability
            print(f"Saved updated results to {results_file_path}")
        except Exception as e:
            print(f"Error saving results to {results_file_path}: {e}")

    except errors.APIError as e:
        print(f"Error uploading file {pdf_filename}: {e}")
        # Continue to the next PDF
    except FileNotFoundError:
        print(f"Error: PDF file not found at {full_pdf_path}. Skipping.")
        # Continue to the next PDF
    except Exception as e:
        print(f"An unexpected error occurred processing {pdf_filename}: {e}")
        # Optionally decide whether to continue or stop
    finally:
        # --- Clean up uploaded file ---
        if uploaded_file:
            try:
                print(f"Deleting uploaded file: {uploaded_file.name}")
                client.files.delete(name=uploaded_file.name)
                print("File deleted successfully.")
            except errors.APIError as e:
                print(f"Error deleting file {uploaded_file.name}: {e}")
            except Exception as e:
                 print(f"An unexpected error occurred during file deletion for {uploaded_file.name}: {e}")


print("\n--- Script Finished ---")