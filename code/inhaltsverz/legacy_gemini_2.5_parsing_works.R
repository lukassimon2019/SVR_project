# Lade notwendige Pakete
# install.packages("jsonlite") # Falls noch nicht installiert
# install.packages("dplyr")    # Falls noch nicht installiert
library(jsonlite)
library(dplyr)

# Dein JSON-String (stelle sicher, dass er korrekt als R-String formatiert ist)
# Am besten liest du ihn aus einer Datei ein:
# json_string <- readLines("dein_json_file.json", warn = FALSE) |> paste(collapse="")
# Oder direkt hier definieren (achte auf korrekte Anführungszeichen und Escaping):
json_string <- '{
  "kapitel": [
    {
      "seite": "1",
      "ueberschrift_eins": "Erstes Kapitel: Chancen auf einen höheren Wachstumspfad",
      "zweite_ebene": [
        {
          "dritte_ebene": [
            {
              "seite": "5",
              "ueberschrift_drei": "Die voraussichtliche Entwicklung im Jahre 2001"
            }
          ],
          "seite": "1",
          "ueberschrift_zwei": "I. Solider Aufschwung"
        },
        {
          "dritte_ebene": [
            {
              "seite": "7",
              "ueberschrift_drei": "Lohnpolitik und Arbeitsmarktordnung: Den eingeschlagenen Weg fortsetzen – die neuen Herausforderungen annehmen"
            },
            {
              "seite": "8",
              "ueberschrift_drei": "Die Gesetzliche Rentenversicherung: Vor einer durchgreifenden Reform"
            },
            {
              "seite": "10",
              "ueberschrift_drei": "Gesundheitspolitik: Nach der Reform ist vor der Reform"
            },
            {
              "seite": "11",
              "ueberschrift_drei": "Finanzpolitik: Die wachstumsfreundliche Orientierung beibehalten"
            },
            {
              "seite": "13",
              "ueberschrift_drei": "Europäische Geldpolitik: Der Preisniveaustabilität verpflichtet"
            }
          ],
          "seite": "6",
          "ueberschrift_zwei": "II. Verbesserte Ausgangsbedingungen – fortdauernde Zielverfehlungen am Arbeitsmarkt"
        }
      ]
    },
    {
      "seite": "15",
      "ueberschrift_eins": "Zweites Kapitel: Die wirtschaftliche Lage im Jahre 2000",
      "zweite_ebene": [
        {
          "dritte_ebene": [
            {
              "seite": "15",
              "ueberschrift_drei": "Weiterhin kräftige Expansion in den Vereinigten Staaten"
            },
            {
              "seite": "18",
              "ueberschrift_drei": "Erholung in Japan unsicher"
            },
            {
              "seite": "20",
              "ueberschrift_drei": "Aufstrebende Volkswirtschaften im Aufwind"
            },
            {
              "seite": "26",
              "ueberschrift_drei": "Exkurs: Zur Bedeutung der Aktienpreisentwicklung"
            }
          ],
          "seite": "15",
          "ueberschrift_zwei": "I. Weltwirtschaft: Gute konjunkturelle Entwicklung"
        },
        {
          "dritte_ebene": [
            {
              "seite": "37",
              "ueberschrift_drei": "Die gesamtwirtschaftliche Entwicklung"
            },
            {
              "seite": "48",
              "ueberschrift_drei": "Die monetäre Lage im Euro-Raum"
            }
          ],
          "seite": "37",
          "ueberschrift_zwei": "II. Europäische Union: Aufschwung mit Kraft"
        },
        {
          "dritte_ebene": [
            {
              "seite": "63",
              "ueberschrift_drei": "Expansion nach klassischem Muster"
            },
            {
              "seite": "72",
              "ueberschrift_drei": "Ausdehnung des Angebotsspielraums"
            },
            {
              "seite": "75",
              "ueberschrift_drei": "Negative außenwirtschaftliche Einflüsse auf das Preisniveau"
            },
            {
              "seite": "79",
              "ueberschrift_drei": "Belebung am Arbeitsmarkt"
            },
            {
              "seite": "94",
              "ueberschrift_drei": "Öffentliche Finanzen: Erkennbare Konsolidierungsfortschritte"
            }
          ],
          "seite": "63",
          "ueberschrift_zwei": "III. Deutschland: Der Aufschwung hat sich fortgesetzt"
        },
        {
          "dritte_ebene": [
            {
              "seite": "116",
              "ueberschrift_drei": "Konvergenz und Strukturwandel"
            },
            {
              "seite": "124",
              "ueberschrift_drei": "Anhaltende Strukturprobleme am Arbeitsmarkt"
            }
          ],
          "seite": "115",
          "ueberschrift_zwei": "IV. Ostdeutschland: Zuversicht ist begründet"
        },
        {
          "dritte_ebene": [
            {
              "seite": "127",
              "ueberschrift_drei": "Neue Technologien und Produktivitätsfortschritt in den Vereinigten Staaten"
            },
            {
              "seite": "132",
              "ueberschrift_drei": "Rückstand in Deutschland"
            }
          ],
          "seite": "127",
          "ueberschrift_zwei": "V. Hoffnungsträger Neue Ökonomie?"
        },
        {
          "dritte_ebene": [
            {
              "seite": "146",
              "ueberschrift_drei": "Kriterien für die Aufnahme der Beitrittskandidaten"
            },
            {
              "seite": "147",
              "ueberschrift_drei": "Wirtschaftliche Integration der Beitrittskandidaten"
            },
            {
              "seite": "153",
              "ueberschrift_drei": "Wirtschaftspolitische Problembereiche in den Beitrittsverhandlungen"
            },
            {
              "seite": "158",
              "ueberschrift_drei": "Institutionelle Reformen der Europäischen Union"
            }
          ],
          "seite": "146",
          "ueberschrift_zwei": "VI. EU-Osterweiterung – Die Voraussetzungen schaffen"
        }
      ]
    },
    {
      "seite": "161",
      "ueberschrift_eins": "Drittes Kapitel: Die voraussichtliche Entwicklung im Jahre 2001",
      "zweite_ebene": [
        {
          "dritte_ebene": [],
          "seite": "161",
          "ueberschrift_zwei": "I. Überblick"
        },
        {
          "dritte_ebene": [],
          "seite": "161",
          "ueberschrift_zwei": "II. Ausgangslage und Annahmen der Prognose"
        },
        {
          "dritte_ebene": [],
          "seite": "164",
          "ueberschrift_zwei": "III. Das weltwirtschaftliche Umfeld"
        },
        {
          "dritte_ebene": [],
          "seite": "164",
          "ueberschrift_zwei": "IV. Die Entwicklung in Europa"
        },
        {
          "dritte_ebene": [],
          "seite": "165",
          "ueberschrift_zwei": "V. Die wirtschaftlichen Aussichten für Deutschland"
        }
      ]
    },
    {
      "seite": "174",
      "ueberschrift_eins": "Viertes Kapitel: Grundlinien der Wirtschaftspolitik",
      "zweite_ebene": [
        {
          "dritte_ebene": [],
          "seite": "174",
          "ueberschrift_zwei": "I. Verbesserte Ausgangsbedingungen – fortdauernde Zielverfehlung am Arbeitsmarkt"
        },
        {
          "dritte_ebene": [],
          "seite": "176",
          "ueberschrift_zwei": "II. Über die Aufgabenteilung und Politikmischung"
        },
        {
          "dritte_ebene": [
            {
              "seite": "181",
              "ueberschrift_drei": "Globalisierter Wettbewerb – weitere Reformen unabweisbar"
            },
            {
              "seite": "182",
              "ueberschrift_drei": "Neue Ökonomie – neue Herausforderungen"
            }
          ],
          "seite": "180",
          "ueberschrift_zwei": "III. Offensiv die Globalisierung und den technologischen Umbruch annehmen"
        },
        {
          "dritte_ebene": [],
          "seite": "186",
          "ueberschrift_zwei": "IV. Flankierung durch eine moderne Einwanderungspolitik"
        }
      ]
    },
    {
      "seite": "189",
      "ueberschrift_eins": "Fünftes Kapitel: Die Politikbereiche im Einzelnen",
      "zweite_ebene": [
        {
          "dritte_ebene": [
            {
              "seite": "189",
              "ueberschrift_drei": "Mit Zinserhöhungen auf Kurs"
            },
            {
              "seite": "190",
              "ueberschrift_drei": "Die mittelfristige Orientierung bekräftigen"
            },
            {
              "seite": "194",
              "ueberschrift_drei": "Geldwertsicherung durch Euro-Abwertung erschwert"
            },
            {
              "seite": "195",
              "ueberschrift_drei": "Exkurs: Gleichgewichtige Wechselkurse"
            }
          ],
          "seite": "189",
          "ueberschrift_zwei": "I. Europäische Geldpolitik: Der Preisniveaustabilität verpflichtet"
        },
        {
          "dritte_ebene": [
            {
              "seite": "198",
              "ueberschrift_drei": "Steuerreform 2000: Verlässliche Bedingungen sind gesetzt"
            },
            {
              "seite": "200",
              "ueberschrift_drei": "Unerledigte steuerpolitische Aufgaben"
            },
            {
              "seite": "205",
              "ueberschrift_drei": "Die ökologische Steuerreform: Den Lenkungscharakter stärken"
            },
            {
              "seite": "206",
              "ueberschrift_drei": "Konsolidierung beherzter angehen"
            },
            {
              "seite": "208",
              "ueberschrift_drei": "Reform des Finanzausgleichs"
            }
          ],
          "seite": "197",
          "ueberschrift_zwei": "II. Finanzpolitik: Die wachstumsfreundliche Orientierung beibehalten"
        },
        {
          "dritte_ebene": [
            {
              "seite": "212",
              "ueberschrift_drei": "Arbeitslosigkeit nach wie vor bedrückend"
            },
            {
              "seite": "213",
              "ueberschrift_drei": "Moderate Lohnpolitik – ein Anfang ist gemacht"
            },
            {
              "seite": "215",
              "ueberschrift_drei": "Angemessene Lohndifferenzierung – eine ständige Aufgabe"
            },
            {
              "seite": "217",
              "ueberschrift_drei": "Am Arbeitsmarkt auf die Neue Ökonomie zugehen"
            },
            {
              "seite": "221",
              "ueberschrift_drei": "Institutionelle Wege zu einer dezentraleren Lohnfindung"
            }
          ],
          "seite": "212",
          "ueberschrift_zwei": "III. Lohnpolitik: Den eingeschlagenen Weg fortsetzen – die neuen Herausforderungen annehmen"
        },
        {
          "dritte_ebene": [
            {
              "seite": "222",
              "ueberschrift_drei": "Schritte in die richtige Richtung"
            },
            {
              "seite": "225",
              "ueberschrift_drei": "Strukturelemente der Reform"
            },
            {
              "seite": "231",
              "ueberschrift_drei": "Robustheit der Ergebnisse"
            },
            {
              "seite": "233",
              "ueberschrift_drei": "Ansätze für Verbesserungen"
            }
          ],
          "seite": "222",
          "ueberschrift_zwei": "IV. Die Gesetzliche Rentenversicherung: Vor einer durchgreifenden Reform"
        },
        {
          "dritte_ebene": [
            {
              "seite": "237",
              "ueberschrift_drei": "Ziele und Befunde"
            },
            {
              "seite": "242",
              "ueberschrift_drei": "Fehlanreize und Organisationsmängel"
            },
            {
              "seite": "245",
              "ueberschrift_drei": "Reformkonzeption I: Systemwechsel"
            },
            {
              "seite": "249",
              "ueberschrift_drei": "Reformkonzeption II: Systemevolution"
            }
          ],
          "seite": "237",
          "ueberschrift_zwei": "V. Gesundheitspolitik: Nach der Reform ist vor der Reform"
        }
      ]
    }
  ]
}'

# Parse JSON zu einer verschachtelten Liste
# simplifyDataFrame = FALSE ist wichtig, damit wir die Listenstruktur behalten
data_list <- jsonlite::fromJSON(json_string, simplifyDataFrame = FALSE)

# Initialisiere eine leere Liste, um die Zeilen des Data Frames zu sammeln
rows_list <- list()

# Iteriere durch die Kapitel (Ebene 1)
for (kap in data_list$kapitel) {
  # Extrahiere Infos der Ebene 1
  ue1 <- kap$ueberschrift_eins
  s1 <- kap$seite
  
  # Füge Zeile für Ebene 1 hinzu
  rows_list[[length(rows_list) + 1]] <- data.frame(
    Ueberschrift_Eins = ue1,
    Ueberschrift_Zwei = NA_character_, # Platzhalter für Ebene 2
    Ueberschrift_Drei = NA_character_, # Platzhalter für Ebene 3
    Seite = s1,
    stringsAsFactors = FALSE
  )
  
  # Iteriere durch die zweite Ebene, falls vorhanden
  if (!is.null(kap$zweite_ebene) && length(kap$zweite_ebene) > 0) {
    for (ebene2 in kap$zweite_ebene) {
      # Extrahiere Infos der Ebene 2
      ue2 <- ebene2$ueberschrift_zwei
      s2 <- ebene2$seite
      
      # Füge Zeile für Ebene 2 hinzu
      rows_list[[length(rows_list) + 1]] <- data.frame(
        Ueberschrift_Eins = ue1, # Wiederhole Ebene 1 Info
        Ueberschrift_Zwei = ue2,
        Ueberschrift_Drei = NA_character_, # Platzhalter für Ebene 3
        Seite = s2,
        stringsAsFactors = FALSE
      )
      
      # Iteriere durch die dritte Ebene, falls vorhanden
      if (!is.null(ebene2$dritte_ebene) && length(ebene2$dritte_ebene) > 0) {
        for (ebene3 in ebene2$dritte_ebene) {
          # Extrahiere Infos der Ebene 3
          ue3 <- ebene3$ueberschrift_drei
          s3 <- ebene3$seite
          
          # Füge Zeile für Ebene 3 hinzu
          rows_list[[length(rows_list) + 1]] <- data.frame(
            Ueberschrift_Eins = ue1, # Wiederhole Ebene 1 Info
            Ueberschrift_Zwei = ue2, # Wiederhole Ebene 2 Info
            Ueberschrift_Drei = ue3,
            Seite = s3,
            stringsAsFactors = FALSE
          )
        }
      }
    }
  }
}

# Kombiniere alle gesammelten Zeilen zu einem einzigen Data Frame
final_df <- dplyr::bind_rows(rows_list)

output_file_path <- "C:\\Users\\P-Simon\\Documents\\SVR\\my_dataframe_new.csv"
write.csv(
  final_df,
  file = output_file_path,
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

# Zeige das Ergebnis an
print(final_df)

# Optional: Speichere als CSV
# write.csv(final_df, "inhaltsverzeichnis.csv", row.names = FALSE, na = "")