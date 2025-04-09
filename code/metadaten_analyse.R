# install readxl package if not already installed

# Load the readxl library
library(readxl)
library(ggplot2)

# Read the Excel file
df_meta <- read_xlsx("C:\\Users\\P-Simon\\Documents\\SVR\\metadaten.xlsx")
df_meta$anzahl_mitarbeiter <- as.numeric(as.character(df_meta$anzahl_mitarbeiter))
df_meta$gutachten_jahr <- as.numeric(substr(df_meta$gutachten_jahr, 1, 4))

#plot länge, mitarbeiter
png("C:\\Users\\P-Simon\\Documents\\SVR\\output\\metadaten\\plot_mitarbeiter_seiten_randziffern.png", width = 1200, height = 800, res = 150)
ggplot(df_meta, aes(x = gutachten_jahr, group = 1)) +
  geom_line(aes(y = anzahl_mitarbeiter, color = "anzahl_mitarbeiter"), linewidth = 1) +
  geom_line(aes(y = anzahl_seiten_hauptteil, color = "anzahl_seiten_hauptteil"), linewidth = 1) +
  geom_line(aes(y = anzahl_randziffern, color = "anzahl_randziffern"), linewidth = 1) +
  labs(
    title = "Variables by Gutachten Jahr",
    x = "Gutachten Jahr",
    y = "Value (Log Scale)",
    color = "Variables"
  ) +
  theme_minimal() +
  scale_color_manual(values = c(
    "anzahl_mitarbeiter" = "blue",
    "anzahl_seiten_hauptteil" = "red",
    "anzahl_randziffern" = "green"
  )) +
  scale_y_log10()
dev.off()


#plot bilder, tabellen, länge 
png("C:\\Users\\P-Simon\\Documents\\SVR\\output\\metadaten\\plot_abbildungen_tabellen_seiten.png", width = 1200, height = 800, res = 150)
ggplot(df_meta, aes(x = gutachten_jahr, group = 1)) +
  geom_line(aes(y = anzahl_abbildungen, color = "anzahl_abbildungen"), linewidth = 1) +
  geom_line(aes(y = anzahl_tabellen_text, color = "anzahl_tabellen_text"), linewidth = 1) +
  geom_line(aes(y = anzahl_keasten, color = "anzahl_keasten"), linewidth = 1) +
  geom_line(aes(y = anzahl_plustexte, color = "anzahl_plustexte"), linewidth = 1) +
  geom_line(aes(y = anzahl_seiten_hauptteil, color = "anzahl_seiten_hauptteil"), linewidth = 1) +
  labs(
    title = "Variables by Gutachten Jahr",
    x = "Gutachten Jahr",
    y = "Value (Log Scale)",
    color = "Variables"
  ) +
  theme_minimal() +
  scale_color_manual(values = c(
    "anzahl_abbildungen" = "blue",
    "anzahl_tabellen_text" = "darkgreen",
    "anzahl_keasten" = "darkblue",
    "anzahl_plustexte" = "turquoise",
    "anzahl_seiten_hauptteil" = "red"
  )) +
  scale_y_log10()+
  scale_x_continuous(breaks = unique(df_meta$gutachten_jahr)[seq(1, length(unique(df_meta$gutachten_jahr)), by = 5)])
dev.off()