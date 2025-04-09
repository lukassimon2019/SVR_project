# library(tidyverse)
library(jsonlite)
library(dplyr)
library(readr)    # For CSV output


output_directory <- "C:\\Users\\P-Simon\\Documents\\SVR\\output\\inhaltsverzeichnis\\csv\\"
temp_directory<-"C:\\Users\\P-Simon\\Documents\\SVR\\output\\temp_store\\"

conversations <- readRDS(file = paste0(temp_directory,"inhaltsverz_json_strings.rds"))

# Hilfsoperator definieren: Gibt b zurück, wenn a NULL ist (aus rlang, aber hier sicherheitshalber definiert)
'%||%' <- function(a, b) {
  if (!is.null(a)) a else b
}


# 1. Funktion zum Parsen eines einzelnen JSON-Strings in das hierarchische Format
#    Diese Funktion kapselt die Logik aus der vorherigen Antwort.
parse_toc_json <- function(json_string) {
  
  # Sicherheitscheck für leeren oder NULL Input
  if (is.null(json_string) || !nzchar(json_string)) {
    warning("Leerer oder NULL JSON-String übergeben. Gebe leeren Data Frame zurück.", call. = FALSE)
    # Definiere leere Datenstruktur für Konsistenz
    return(data.frame(
      Ueberschrift_Eins = character(0),
      Ueberschrift_Zwei = character(0),
      Ueberschrift_Drei_Niedriger = character(0),
      Seite = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  # JSON parsen, Fehler abfangen
  data_list <- tryCatch({
    jsonlite::fromJSON(json_string, simplifyDataFrame = FALSE)
  }, error = function(e) {
    warning(paste("Fehler beim Parsen des JSON-Strings:", e$message, ". Gebe leeren Data Frame zurück."), call. = FALSE)
    return(NULL) # Signalisiert Fehler
  })
  
  # Prüfen, ob Parsen erfolgreich war und die erwartete Struktur hat
  if (is.null(data_list) || !("kapitel" %in% names(data_list)) || length(data_list$kapitel) == 0) {
    warning("Geparstes JSON ist NULL, enthält kein 'kapitel' oder 'kapitel' ist leer. Gebe leeren Data Frame zurück.", call. = FALSE)
    return(data.frame(
      Ueberschrift_Eins = character(0),
      Ueberschrift_Zwei = character(0),
      Ueberschrift_Drei_Niedriger = character(0),
      Seite = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  # Initialisiere Liste für Zeilen
  rows_list <- list()
  
  # Iteriere durch Kapitel (Ebene 1)
  for (kap in data_list$kapitel) {
    # %||% NA_character_ stellt sicher, dass wir NA bekommen, falls ein Feld fehlt
    ue1 <- kap$ueberschrift_eins %||% NA_character_
    s1 <- kap$seite %||% NA_character_
    
    # Füge Zeile für Ebene 1 hinzu
    rows_list[[length(rows_list) + 1]] <- data.frame(
      Ueberschrift_Eins = ue1,
      Ueberschrift_Zwei = NA_character_,
      Ueberschrift_Drei_Niedriger = NA_character_,
      Seite = s1,
      stringsAsFactors = FALSE
    )
    
    # Iteriere durch Ebene 2
    if (!is.null(kap$zweite_ebene) && length(kap$zweite_ebene) > 0) {
      for (ebene2 in kap$zweite_ebene) {
        ue2 <- ebene2$ueberschrift_zwei %||% NA_character_
        s2 <- ebene2$seite %||% NA_character_
        
        # Füge Zeile für Ebene 2 hinzu
        rows_list[[length(rows_list) + 1]] <- data.frame(
          Ueberschrift_Eins = ue1,
          Ueberschrift_Zwei = ue2,
          Ueberschrift_Drei_Niedriger = NA_character_,
          Seite = s2,
          stringsAsFactors = FALSE
        )
        
        # Iteriere durch Ebene 3
        if (!is.null(ebene2$dritte_ebene) && length(ebene2$dritte_ebene) > 0) {
          for (ebene3 in ebene2$dritte_ebene) {
            ue3 <- ebene3$ueberschrift_drei_niedriger %||% NA_character_
            s3 <- ebene3$seite %||% NA_character_
            
            # Füge Zeile für Ebene 3 hinzu
            rows_list[[length(rows_list) + 1]] <- data.frame(
              Ueberschrift_Eins = ue1,
              Ueberschrift_Zwei = ue2,
              Ueberschrift_Drei_Niedriger = ue3,
              Seite = s3,
              stringsAsFactors = FALSE
            )
          }
        }
      }
    }
  } # Ende der Kapitel-Schleife
  
  # Kombiniere Zeilen sicher (falls rows_list leer ist)
  if (length(rows_list) > 0) {
    final_df <- dplyr::bind_rows(rows_list)
  } else {
    # Gebe leeren DF mit korrekten Spalten zurück, falls keine Zeilen generiert wurden
    final_df <- data.frame(
      Ueberschrift_Eins = character(0),
      Ueberschrift_Zwei = character(0),
      Ueberschrift_Drei_Niedriger = character(0),
      Seite = character(0),
      stringsAsFactors = FALSE
    )
  }
  
  return(final_df)
}


# 2. Iteriere durch die 'conversations'-Liste und wende die Parse-Funktion an

# Initialisiere eine leere Liste, um die resultierenden Data Frames zu speichern
parsed_data_frames <- list()

# Iteriere über die Namen (oder Indizes) der conversations Liste
for (name in names(conversations)) {
  conv <- conversations[[name]] # Hole das aktuelle llm_message Objekt
  
  # Extrahiere den JSON-Inhalt sicher (Fehler abfangen)
  json_content <- tryCatch({
    # Annahme: Der relevante Inhalt ist immer im 3. Element der History
    #          und dort im 'content'-Slot. Passe dies ggf. an!
    if (length(conv@message_history) >= 3 && !is.null(conv@message_history[[3]]$content)) {
      conv@message_history[[3]]$content
    } else {
      warning(paste("Kein Inhalt in message_history[[3]]$content gefunden für:", name), call. = FALSE)
      NULL # Kein Inhalt gefunden
    }
  }, error = function(e) {
    warning(paste("Fehler beim Zugriff auf message_history für:", name, "-", e$message), call. = FALSE)
    NULL # Fehler beim Zugriff
  })
  
  # Parse den extrahierten JSON-String (oder NULL) mit der Funktion
  # Die Funktion parse_toc_json ist so gebaut, dass sie auch mit NULL umgehen kann
  parsed_df <- parse_toc_json(json_content)
  
  # Speichere den resultierenden Data Frame in der neuen Liste unter demselben Namen
  parsed_data_frames[[name]] <- parsed_df
  
  print(paste("Verarbeitet:", name, "- Zeilen im DataFrame:", nrow(parsed_df)))
}

# --- Code zum Speichern jedes DataFrames in der Liste als separate CSV-Datei ---

# 3. Iteriere durch die Liste der DataFrames ('parsed_data_frames')
for (name in names(parsed_data_frames)) {
  
  # Hole den aktuellen DataFrame aus der Liste
  current_df <- parsed_data_frames[[name]]
  
  # Konstruiere den vollständigen Dateipfad für die CSV-Datei
  # file.path() ist robust und funktioniert systemübergreifend.
  csv_filename <- paste0(name, ".csv") # Füge die .csv-Endung hinzu
  full_csv_path <- file.path(output_directory, csv_filename)
  
  # Schreibe den DataFrame als CSV-Datei
  # Verwende tryCatch, um Fehler beim Schreiben einer Datei abzufangen,
  # ohne die gesamte Schleife abzubrechen.
  tryCatch({
    write.csv(
      current_df,
      file = full_csv_path,
      row.names = FALSE,    # Keine R-Zeilennummern schreiben
      na = "",              # NA-Werte als leere Strings
      fileEncoding = "UTF-8" # Für gute Kompatibilität
    )
    # Optional: Bestätigung für jede gespeicherte Datei
    # print(paste("Gespeichert:", full_csv_path))
    
  }, error = function(e) {
    # Gib eine Warnung aus, wenn eine Datei nicht gespeichert werden konnte
    warning(paste("Konnte Datei nicht speichern:", full_csv_path, "- Fehler:", e$message), call. = FALSE)
  })
  
} # Ende der for-Schleife

# Optional: Gib eine abschließende Bestätigungsmeldung aus
print(paste("Speichern der DataFrames als CSV abgeschlossen im Verzeichnis:", output_directory))
